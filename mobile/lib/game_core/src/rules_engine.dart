import 'board.dart';
import 'models.dart';

abstract final class RulesEngine {
  static List<Token> legalMoves(GameState state) {
    final roll = state.pendingRoll;
    if (state.phase != GamePhase.waitingForMove || roll == null) {
      return const [];
    }
    return legalMovesForRoll(state, state.activePlayer.id, roll);
  }

  static List<Token> legalMovesForRoll(
    GameState state,
    String playerId,
    int roll,
  ) => state
      .tokensFor(playerId)
      .where((token) => _canMove(token, roll, state.rules))
      .toList(growable: false);

  static bool _canMove(Token token, int roll, RuleProfile rules) {
    if (roll < 1 || roll > 6 || token.isFinished) return false;
    if (token.isInYard) return rules.openingRolls.contains(roll);
    return token.steps + roll <= LudoBoard.finishProgress;
  }

  static TransitionResult applyAction(GameState state, GameAction action) {
    if (state.phase == GamePhase.finished) {
      throw const InvalidGameAction('The match is already finished.');
    }
    if (action.playerId != state.activePlayer.id) {
      throw const InvalidGameAction('Only the active player may act.');
    }
    return switch (action) {
      RollDice() => _roll(state, action),
      MoveToken() => _move(state, action),
    };
  }

  static TransitionResult _roll(GameState state, RollDice action) {
    if (state.phase != GamePhase.waitingForRoll) {
      throw const InvalidGameAction(
        'A token move must resolve the pending roll.',
      );
    }
    if (action.value < 1 || action.value > 6) {
      throw const InvalidGameAction('Dice value must be from 1 to 6.');
    }
    final sixes = action.value == 6 ? state.consecutiveSixes + 1 : 0;
    final events = <GameEvent>[
      GameEvent(
        GameEventType.rolled,
        playerId: action.playerId,
        value: action.value,
      ),
    ];
    if (state.rules.penalizeThirdSix && sixes == 3) {
      events.add(
        GameEvent(GameEventType.thirdSixForfeited, playerId: action.playerId),
      );
      return _advanceTurn(state, events);
    }
    final legal = legalMovesForRoll(state, action.playerId, action.value);
    if (legal.isEmpty) {
      events.add(
        GameEvent(GameEventType.noLegalMove, playerId: action.playerId),
      );
      if (action.value == 6 && state.rules.extraTurnOnSix) {
        return TransitionResult(
          state.copyWith(
            consecutiveSixes: sixes,
            revision: state.revision + 1,
            clearPendingRoll: true,
          ),
          List.unmodifiable(events),
        );
      }
      return _advanceTurn(state, events);
    }
    return TransitionResult(
      state.copyWith(
        phase: GamePhase.waitingForMove,
        pendingRoll: action.value,
        consecutiveSixes: sixes,
        revision: state.revision + 1,
      ),
      List.unmodifiable(events),
    );
  }

  static TransitionResult _move(GameState state, MoveToken action) {
    if (state.phase != GamePhase.waitingForMove || state.pendingRoll == null) {
      throw const InvalidGameAction('Roll before selecting a token.');
    }
    final legal = legalMoves(state);
    final index = state.tokens.indexWhere(
      (token) => token.id == action.tokenId,
    );
    if (index == -1 || !legal.any((token) => token.id == action.tokenId)) {
      throw const InvalidGameAction('That token is not a legal move.');
    }
    final moving = state.tokens[index];
    final nextSteps = moving.isInYard ? 0 : moving.steps + state.pendingRoll!;
    final tokens = [...state.tokens];
    tokens[index] = moving.copyWith(steps: nextSteps);
    final events = <GameEvent>[
      GameEvent(
        moving.isInYard ? GameEventType.tokenEntered : GameEventType.tokenMoved,
        playerId: action.playerId,
        tokenId: action.tokenId,
        value: state.pendingRoll,
      ),
    ];
    var captured = false;
    if (nextSteps < LudoBoard.trackLength) {
      final player = state.players.firstWhere((p) => p.id == action.playerId);
      final square = LudoBoard.absoluteTrackIndex(player.color, nextSteps);
      if (!state.rules.safeSquares.contains(square)) {
        for (var i = 0; i < tokens.length; i++) {
          final opponent = tokens[i];
          if (opponent.playerId == action.playerId || !opponent.isOnTrack) {
            continue;
          }
          final opponentPlayer = state.players.firstWhere(
            (p) => p.id == opponent.playerId,
          );
          if (LudoBoard.absoluteTrackIndex(
                opponentPlayer.color,
                opponent.steps,
              ) ==
              square) {
            tokens[i] = opponent.copyWith(steps: -1);
            captured = true;
            events.add(
              GameEvent(
                GameEventType.captured,
                playerId: action.playerId,
                tokenId: opponent.id,
              ),
            );
          }
        }
      }
    }
    final reachedHome = nextSteps == LudoBoard.finishProgress;
    if (reachedHome) {
      events.add(
        GameEvent(
          GameEventType.reachedHome,
          playerId: action.playerId,
          tokenId: action.tokenId,
        ),
      );
    }
    final won = tokens
        .where((t) => t.playerId == action.playerId)
        .every((t) => t.isFinished);
    if (won) {
      events.add(
        GameEvent(GameEventType.matchFinished, playerId: action.playerId),
      );
      return TransitionResult(
        state.copyWith(
          tokens: tokens,
          phase: GamePhase.finished,
          winnerPlayerId: action.playerId,
          clearPendingRoll: true,
          revision: state.revision + 1,
        ),
        List.unmodifiable(events),
      );
    }
    final extraTurn =
        (state.pendingRoll == 6 && state.rules.extraTurnOnSix) ||
        (captured && state.rules.extraTurnOnCapture) ||
        (reachedHome && state.rules.extraTurnOnHome);
    if (extraTurn) {
      return TransitionResult(
        state.copyWith(
          tokens: tokens,
          phase: GamePhase.waitingForRoll,
          clearPendingRoll: true,
          revision: state.revision + 1,
        ),
        List.unmodifiable(events),
      );
    }
    return _advanceTurn(state.copyWith(tokens: tokens), events);
  }

  static TransitionResult _advanceTurn(
    GameState state,
    List<GameEvent> events,
  ) {
    final nextIndex = (state.activePlayerIndex + 1) % state.players.length;
    events.add(
      GameEvent(
        GameEventType.turnChanged,
        playerId: state.players[nextIndex].id,
      ),
    );
    return TransitionResult(
      state.copyWith(
        activePlayerIndex: nextIndex,
        phase: GamePhase.waitingForRoll,
        clearPendingRoll: true,
        consecutiveSixes: 0,
        revision: state.revision + 1,
      ),
      List.unmodifiable(events),
    );
  }
}
