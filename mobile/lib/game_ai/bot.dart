import 'dart:math';

import '../game_core/game_core.dart';

class LudoBot {
  LudoBot({Random? random}) : _random = random ?? Random();
  final Random _random;

  String? chooseToken(GameState state, BotDifficulty difficulty) {
    final legal = RulesEngine.legalMoves(state);
    if (legal.isEmpty) return null;
    if (difficulty == BotDifficulty.easy) {
      return legal[_random.nextInt(legal.length)].id;
    }
    final scored =
        legal
            .map(
              (token) =>
                  (token: token, score: _score(state, token, difficulty)),
            )
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    return scored.first.token.id;
  }

  int _score(GameState state, Token token, BotDifficulty difficulty) {
    final destination = token.isInYard ? 0 : token.steps + state.pendingRoll!;
    var score = destination + (token.isInYard ? 20 : 0);
    if (destination == LudoBoard.finishProgress) score += 100;
    if (destination < 52) {
      final square = LudoBoard.absoluteTrackIndex(
        state.activePlayer.color,
        destination,
      );
      for (final opponent in state.tokens.where(
        (t) => t.playerId != token.playerId && t.isOnTrack,
      )) {
        final owner = state.players.firstWhere(
          (p) => p.id == opponent.playerId,
        );
        final opponentSquare = LudoBoard.absoluteTrackIndex(
          owner.color,
          opponent.steps,
        );
        if (!state.rules.safeSquares.contains(square) &&
            opponentSquare == square) {
          score += 60;
        }
        if (difficulty == BotDifficulty.hard) {
          final danger = (square - opponentSquare + 52) % 52;
          if (danger >= 1 && danger <= 6) score -= 18;
        }
      }
      if (difficulty == BotDifficulty.hard &&
          state.rules.safeSquares.contains(square)) {
        score += 15;
      }
    }
    return score;
  }
}
