import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_arena/features/snakes/snakes_engine.dart';

void main() {
  group('Saanp-Seedhi rules', () {
    test('normal rolls advance the piece', () {
      expect(SnakesRules.advance(10, 5), 15);
    });

    test('an exact roll is required to reach 100', () {
      expect(SnakesRules.advance(98, 3), 98);
      expect(SnakesRules.advance(98, 2), 100);
    });

    test('ladders move upward and snakes move downward', () {
      expect(SnakesRules.resolveJump(2), 23);
      expect(SnakesRules.resolveJump(99), 76);
    });

    test('ordinary cells have no jump', () {
      expect(SnakesRules.resolveJump(50), 50);
    });
  });
}
