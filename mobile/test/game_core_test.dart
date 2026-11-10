import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_arena/game_ai/bot.dart';
import 'package:ludo_arena/game_core/game_core.dart';

const red = Player(id: 'red', name: 'Red', color: PlayerColor.red);
const green = Player(id: 'green', name: 'Green', color: PlayerColor.green);

GameState game({RuleProfile rules = RuleProfile.classic}) => GameState.newGame(
  gameId: 'test',
  players: const [red, green],
  rules: rules,
  createdAtUtc: DateTime.utc(2026),
);

GameState positioned(
  GameState state, {
  required Map<String, int> steps,
  GamePhase phase = GamePhase.waitingForRoll,
  int? roll,
  int activePlayerIndex = 0,
  int consecutiveSixes = 0,
}) => GameState(
  gameId: state.gameId,
  players: state.players,
  tokens: state.tokens
      .map((t) => steps.containsKey(t.id) ? t.copyWith(steps: steps[t.id]) : t)
      .toList(),
  rules: state.rules,
  phase: phase,
  pendingRoll: roll,
  activePlayerIndex: activePlayerIndex,
  consecutiveSixes: consecutiveSixes,
  createdAtUtc: state.createdAtUtc,
);

void main() {
  group('canonical board', () {
    test('each color rotates around the same 52-cell track', () {
      expect(LudoBoard.absoluteTrackIndex(PlayerColor.red, 0), 0);
      expect(LudoBoard.absoluteTrackIndex(PlayerColor.green, 0), 13);
      expect(LudoBoard.absoluteTrackIndex(PlayerColor.yellow, 0), 26);
      expect(LudoBoard.absoluteTrackIndex(PlayerColor.blue, 0), 39);
      expect(LudoBoard.absoluteTrackIndex(PlayerColor.blue, 13), 0);
    });
  });

  group('entry and movement', () {
    test('yard tokens cannot move without an opening roll', () {
      expect(RulesEngine.legalMovesForRoll(game(), red.id, 5), isEmpty);
    });

    test('six unlocks all yard tokens', () {
      final state = game();
      expect(RulesEngine.legalMovesForRoll(state, red.id, 6), hasLength(4));
      final rolled = RulesEngine.applyAction(
        state,
        const RollDice('red', 6),
      ).state;
      final moved = RulesEngine.applyAction(
        rolled,
        const MoveToken('red', 'red-t0'),
      ).state;
      expect(moved.tokens.first.steps, 0);
      expect(moved.activePlayer.id, red.id);
      expect(moved.phase, GamePhase.waitingForRoll);
    });

    test('standard movement enters home lane and exact finish is required', () {
      final atEntrance = positioned(game(), steps: {'red-t0': 51});
      expect(RulesEngine.legalMovesForRoll(atEntrance, red.id, 2), isNotEmpty);
      final nearHome = positioned(game(), steps: {'red-t0': 56});
      expect(RulesEngine.legalMovesForRoll(nearHome, red.id, 1), isNotEmpty);
      expect(RulesEngine.legalMovesForRoll(nearHome, red.id, 2), isEmpty);
    });

    test('same-color stacking does not block movement', () {
      final state = positioned(game(), steps: {'red-t0': 10, 'red-t1': 10});
      expect(
        RulesEngine.legalMovesForRoll(state, red.id, 2).map((t) => t.id),
        containsAll(['red-t0', 'red-t1']),
      );
    });
  });

  group('capture and safe squares', () {
    test('landing on a normal square captures opponents', () {
      final state = positioned(
        game(),
        steps: {'red-t0': 4, 'green-t0': 44},
        phase: GamePhase.waitingForMove,
        roll: 1,
      );
      final result = RulesEngine.applyAction(
        state,
        const MoveToken('red', 'red-t0'),
      );
      expect(
        result.state.tokens.firstWhere((t) => t.id == 'green-t0').steps,
        -1,
      );
      expect(
        result.events.map((e) => e.type),
        contains(GameEventType.captured),
      );
    });

    test('safe squares prohibit capture', () {
      final state = positioned(
        game(),
        steps: {'red-t0': 7, 'green-t0': 47},
        phase: GamePhase.waitingForMove,
        roll: 1,
      );
      final result = RulesEngine.applyAction(
        state,
        const MoveToken('red', 'red-t0'),
      );
      expect(
        result.state.tokens.firstWhere((t) => t.id == 'green-t0').steps,
        47,
      );
      expect(
        result.events.map((e) => e.type),
        isNot(contains(GameEventType.captured)),
      );
    });
  });

  group('turns and victory', () {
    test('no legal move advances the turn', () {
      final next = RulesEngine.applyAction(
        game(),
        const RollDice('red', 2),
      ).state;
      expect(next.activePlayer.id, green.id);
      expect(next.phase, GamePhase.waitingForRoll);
    });

    test('six gives an extra roll and third six is forfeited', () {
      var state = RulesEngine.applyAction(
        game(),
        const RollDice('red', 6),
      ).state;
      state = RulesEngine.applyAction(
        state,
        const MoveToken('red', 'red-t0'),
      ).state;
      state = RulesEngine.applyAction(state, const RollDice('red', 6)).state;
      state = RulesEngine.applyAction(
        state,
        const MoveToken('red', 'red-t0'),
      ).state;
      final result = RulesEngine.applyAction(state, const RollDice('red', 6));
      expect(result.state.activePlayer.id, green.id);
      expect(result.state.consecutiveSixes, 0);
      expect(
        result.events.map((e) => e.type),
        contains(GameEventType.thirdSixForfeited),
      );
    });

    test('inactive player and duplicate roll are rejected', () {
      expect(
        () => RulesEngine.applyAction(game(), const RollDice('green', 6)),
        throwsA(isA<InvalidGameAction>()),
      );
      final pending = RulesEngine.applyAction(
        game(),
        const RollDice('red', 6),
      ).state;
      expect(
        () => RulesEngine.applyAction(pending, const RollDice('red', 2)),
        throwsA(isA<InvalidGameAction>()),
      );
    });

    test('Classic needs four tokens while Quick needs two', () {
      final classic = positioned(
        game(),
        steps: {'red-t0': 57, 'red-t1': 57, 'red-t2': 57, 'red-t3': 56},
        phase: GamePhase.waitingForMove,
        roll: 1,
      );
      expect(
        RulesEngine.applyAction(
          classic,
          const MoveToken('red', 'red-t3'),
        ).state.phase,
        GamePhase.finished,
      );
      final quick = positioned(
        game(rules: RuleProfile.quick),
        steps: {'red-t0': 57, 'red-t1': 56},
        phase: GamePhase.waitingForMove,
        roll: 1,
      );
      expect(
        RulesEngine.applyAction(
          quick,
          const MoveToken('red', 'red-t1'),
        ).state.winnerPlayerId,
        red.id,
      );
    });

    test('finished game rejects more actions', () {
      final almost = positioned(
        game(rules: RuleProfile.quick),
        steps: {'red-t0': 57, 'red-t1': 56},
        phase: GamePhase.waitingForMove,
        roll: 1,
      );
      final finished = RulesEngine.applyAction(
        almost,
        const MoveToken('red', 'red-t1'),
      ).state;
      expect(
        () => RulesEngine.applyAction(finished, const RollDice('red', 1)),
        throwsA(isA<InvalidGameAction>()),
      );
    });
  });

  group('variants and persistence', () {
    test('opening on 1 and optional capture extra turn work', () {
      const rules = RuleProfile(
        id: 'variant',
        tokensPerPlayer: 2,
        openingRolls: {1, 6},
        extraTurnOnCapture: true,
      );
      expect(
        RulesEngine.legalMovesForRoll(game(rules: rules), red.id, 1),
        hasLength(2),
      );
      final capture = positioned(
        game(rules: rules),
        steps: {'red-t0': 4, 'green-t0': 44},
        phase: GamePhase.waitingForMove,
        roll: 1,
      );
      expect(
        RulesEngine.applyAction(
          capture,
          const MoveToken('red', 'red-t0'),
        ).state.activePlayer.id,
        red.id,
      );
    });

    test('optional home bonus grants an extra turn', () {
      const rules = RuleProfile(
        id: 'home-bonus',
        tokensPerPlayer: 2,
        openingRolls: {6},
        extraTurnOnHome: true,
      );
      final state = positioned(
        game(rules: rules),
        steps: {'red-t0': 56},
        phase: GamePhase.waitingForMove,
        roll: 1,
      );
      final next = RulesEngine.applyAction(
        state,
        const MoveToken('red', 'red-t0'),
      ).state;
      expect(next.activePlayer.id, red.id);
      expect(next.phase, GamePhase.waitingForRoll);
    });

    test('pending roll survives JSON round trip', () {
      final pending = RulesEngine.applyAction(
        game(),
        const RollDice('red', 6),
      ).state;
      final restored = GameState.decode(pending.encode());
      expect(restored.pendingRoll, 6);
      expect(restored.phase, GamePhase.waitingForMove);
      expect(restored.toJson(), pending.toJson());
    });

    test('unsupported schemas are safely rejected', () {
      final json = game().toJson()..['schemaVersion'] = 99;
      expect(() => GameState.fromJson(json), throwsFormatException);
    });
  });

  group('bots', () {
    test(
      'all difficulties return only legal moves and seeded Easy repeats',
      () {
        final pending = RulesEngine.applyAction(
          game(),
          const RollDice('red', 6),
        ).state;
        final legal = RulesEngine.legalMoves(pending).map((t) => t.id).toSet();
        for (final difficulty in BotDifficulty.values) {
          expect(
            legal,
            contains(
              LudoBot(random: Random(7)).chooseToken(pending, difficulty),
            ),
          );
        }
        expect(
          LudoBot(random: Random(42)).chooseToken(pending, BotDifficulty.easy),
          LudoBot(random: Random(42)).chooseToken(pending, BotDifficulty.easy),
        );
      },
    );
  });
}
