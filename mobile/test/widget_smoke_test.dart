import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_arena/app/settings.dart';
import 'package:ludo_arena/features/game/board_view.dart';
import 'package:ludo_arena/game_core/game_core.dart';

void main() {
  testWidgets('board renders at small and large phone widths', (tester) async {
    final state = GameState.newGame(
      gameId: 'widget',
      players: const [
        Player(id: 'r', name: 'Red player', color: PlayerColor.red),
        Player(id: 'g', name: 'Green player', color: PlayerColor.green),
        Player(id: 'y', name: 'Yellow player', color: PlayerColor.yellow),
        Player(id: 'b', name: 'Blue player', color: PlayerColor.blue),
      ],
      rules: RuleProfile.quick,
      createdAtUtc: DateTime.utc(2026),
    );
    for (final size in [const Size(320, 640), const Size(430, 932)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BoardView(state: state, onTokenTap: (_) {}),
            ),
          ),
        ),
      );
      expect(find.byType(BoardView), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.binding.setSurfaceSize(null);
  });

  test('board geometry has exactly 52 unique cells', () {
    expect(BoardGeometry.track, hasLength(52));
    expect(BoardGeometry.track.toSet(), hasLength(52));
  });

  test('critical navigation strings exist in English and Hindi', () {
    for (final language in ['en', 'hi']) {
      final strings = AppStrings(language);
      for (final key in [
        'title',
        'play',
        'computer',
        'tutorial',
        'settings',
        'roll',
        'winner',
      ]) {
        expect(strings.get(key), isNot(key));
      }
    }
  });
}
