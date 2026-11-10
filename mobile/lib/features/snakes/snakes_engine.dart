class SnakesRules {
  const SnakesRules._();

  static const Map<int, int> ladders = {
    2: 23,
    7: 29,
    18: 41,
    27: 56,
    36: 64,
    51: 72,
    62: 81,
    78: 96,
  };

  static const Map<int, int> snakes = {
    99: 76,
    94: 69,
    87: 24,
    74: 53,
    68: 48,
    59: 34,
    43: 17,
    32: 9,
  };

  static int advance(int position, int roll) {
    final next = position + roll;
    return next > 100 ? position : next;
  }

  static int resolveJump(int position) =>
      ladders[position] ?? snakes[position] ?? position;

  static bool isLadder(int position) => ladders.containsKey(position);
}
