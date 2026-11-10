import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui_components.dart';
import 'snakes_engine.dart';

class SnakesScreen extends StatefulWidget {
  const SnakesScreen({super.key});

  @override
  State<SnakesScreen> createState() => _SnakesScreenState();
}

class _SnakesScreenState extends State<SnakesScreen> {
  final _random = math.Random();
  final _positions = <int>[0, 0];
  var _turn = 0;
  var _dice = 1;
  var _rolling = false;
  int? _winner;
  var _message = 'Roll the dice • Reach 100 first';

  Future<void> _roll() async {
    if (_rolling || _winner != null) return;
    setState(() {
      _rolling = true;
      _message = _turn == 0 ? 'Your dice is rolling…' : 'Bot is rolling…';
    });

    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (!mounted) return;
    final roll = _random.nextInt(6) + 1;
    final start = _positions[_turn];
    final landed = SnakesRules.advance(start, roll);
    setState(() {
      _dice = roll;
      _positions[_turn] = landed;
      _message = landed == start && start + roll > 100
          ? 'Exact roll needed to reach 100'
          : '${_turn == 0 ? 'You' : 'Bot'} rolled $roll';
    });

    await Future<void>.delayed(const Duration(milliseconds: 430));
    if (!mounted) return;
    final jumped = SnakesRules.resolveJump(landed);
    if (jumped != landed) {
      final ladder = SnakesRules.isLadder(landed);
      setState(() {
        _positions[_turn] = jumped;
        _message = ladder
            ? 'Ladder! ${landed.toString()} → ${jumped.toString()}'
            : 'Snake! ${landed.toString()} → ${jumped.toString()}';
      });
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
    }

    if (_positions[_turn] == 100) {
      setState(() {
        _winner = _turn;
        _rolling = false;
        _message = _turn == 0
            ? 'You conquered the board!'
            : 'Bot wins this round';
      });
      return;
    }

    setState(() {
      _turn = 1 - _turn;
      _rolling = false;
      _message = _turn == 0 ? 'Your turn • Roll the dice' : 'Bot is thinking…';
    });
    if (_turn == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 750));
      if (mounted && _turn == 1 && _winner == null) _roll();
    }
  }

  void _newGame() => setState(() {
    _positions
      ..clear()
      ..addAll([0, 0]);
    _turn = 0;
    _dice = 1;
    _rolling = false;
    _winner = null;
    _message = 'Roll the dice • Reach 100 first';
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ArenaBackdrop(
      child: Column(
        children: [
          _SnakesHeader(onBack: () => context.go('/')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: ArenaGameTabs(
              snakesSelected: true,
              onLudo: () => context.go('/'),
              onSnakes: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: _RaceChip(
                    name: 'YOU',
                    position: _positions[0],
                    active: _turn == 0 && _winner == null,
                    color: ArenaTheme.coral,
                    icon: Icons.person_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RaceChip(
                    name: 'BOT',
                    position: _positions[1],
                    active: _turn == 1 && _winner == null,
                    color: ArenaTheme.mint,
                    icon: Icons.smart_toy_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                color: const Color(0x8A0B1230),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: .08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .32),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final size = math.min(
                        constraints.maxWidth - 18,
                        constraints.maxHeight - 34,
                      );
                      return Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: size,
                          height: size,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF57D8B3), Color(0xFF7357F6)],
                            ),
                            borderRadius: BorderRadius.circular(27),
                            border: Border.all(color: Colors.white24),
                            boxShadow: [
                              BoxShadow(
                                color: ArenaTheme.mint.withValues(alpha: .2),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomPaint(
                              painter: SnakesBoardPainter(
                                positions: List<int>.from(_positions),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Positioned(
                    left: 18,
                    top: 12,
                    child: ArenaPill(
                      icon: Icons.flag_rounded,
                      label: 'CLIMB TO 100',
                      color: ArenaTheme.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _SnakesConsole(
            dice: _dice,
            message: _message,
            rolling: _rolling,
            isHumanTurn: _turn == 0,
            winner: _winner,
            onRoll: _roll,
            onReset: _newGame,
          ),
        ],
      ),
    ),
  );
}

class _SnakesHeader extends StatelessWidget {
  const _SnakesHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const GradientIcon(
          icon: Icons.route_rounded,
          colors: [ArenaTheme.mint, Color(0xFF188F91)],
          size: 43,
          iconSize: 21,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SNAKE & LADDER',
                style: TextStyle(
                  color: ArenaTheme.mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'Saanp-Seedhi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const ArenaPill(
          icon: Icons.people_alt_rounded,
          label: '2 PLAYERS',
          color: ArenaTheme.sky,
        ),
      ],
    ),
  );
}

class _RaceChip extends StatelessWidget {
  const _RaceChip({
    required this.name,
    required this.position,
    required this.active,
    required this.color,
    required this.icon,
  });
  final String name;
  final int position;
  final bool active;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: active
          ? color.withValues(alpha: .22)
          : Colors.white.withValues(alpha: .05),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: active ? color : Colors.white12,
        width: active ? 1.5 : 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                position == 0 ? 'START' : 'CELL $position',
                style: TextStyle(
                  color: active ? color : ArenaTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SnakesConsole extends StatelessWidget {
  const _SnakesConsole({
    required this.dice,
    required this.message,
    required this.rolling,
    required this.isHumanTurn,
    required this.winner,
    required this.onRoll,
    required this.onReset,
  });
  final int dice;
  final String message;
  final bool rolling;
  final bool isHumanTurn;
  final int? winner;
  final VoidCallback onRoll;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 10, 14, 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xDB222746),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: ArenaTheme.mint.withValues(alpha: .35)),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 24),
      ],
    ),
    child: Row(
      children: [
        AnimatedRotation(
          turns: rolling ? .5 : 0,
          duration: const Duration(milliseconds: 360),
          child: DiceMark(size: 54, value: dice, color: ArenaTheme.mint),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                winner == null
                    ? (isHumanTurn ? 'Your turn' : 'Bot turn')
                    : 'Round complete',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                message,
                style: const TextStyle(color: ArenaTheme.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: winner != null
              ? onReset
              : (isHumanTurn && !rolling ? onRoll : null),
          style: FilledButton.styleFrom(
            minimumSize: const Size(112, 50),
            backgroundColor: winner != null ? ArenaTheme.gold : ArenaTheme.mint,
            foregroundColor: winner != null ? ArenaTheme.ink : Colors.white,
          ),
          child: Text(
            winner != null ? 'NEW GAME' : (rolling ? 'ROLLING…' : 'ROLL DICE'),
          ),
        ),
      ],
    ),
  );
}

class SnakesBoardPainter extends CustomPainter {
  const SnakesBoardPainter({required this.positions});
  final List<int> positions;

  static const _cream = Color(0xFFF8F5F0);
  static const _navy = Color(0xFF22284B);

  Offset _centerFor(int number, double cell) {
    final index = number - 1;
    final rowFromBottom = index ~/ 10;
    final slot = index % 10;
    final column = rowFromBottom.isEven ? slot : 9 - slot;
    final row = 9 - rowFromBottom;
    return Offset((column + .5) * cell, (row + .5) * cell);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 10;
    canvas.drawRect(Offset.zero & size, Paint()..color = _cream);
    final cellPaint = Paint();
    for (var number = 1; number <= 100; number++) {
      final center = _centerFor(number, cell);
      final row = (center.dy / cell).floor();
      final column = (center.dx / cell).floor();
      final special =
          SnakesRules.ladders.containsKey(number) ||
          SnakesRules.snakes.containsKey(number);
      cellPaint.color = special
          ? (SnakesRules.isLadder(number)
                ? const Color(0xFFDDF8EA)
                : const Color(0xFFFFE1E8))
          : ((row + column).isEven
                ? const Color(0xFFF9F6F1)
                : const Color(0xFFEDE9F6));
      canvas.drawRect(
        Rect.fromLTWH(column * cell, row * cell, cell, cell),
        cellPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(column * cell, row * cell, cell, cell),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7
          ..color = _navy.withValues(alpha: .12),
      );
      final text = TextPainter(
        text: TextSpan(
          text: '$number',
          style: TextStyle(
            color: _navy.withValues(alpha: .72),
            fontSize: cell * .23,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        Offset(center.dx - cell * .42, center.dy - cell * .42),
      );
    }

    for (final entry in SnakesRules.ladders.entries) {
      _drawLadder(
        canvas,
        _centerFor(entry.key, cell),
        _centerFor(entry.value, cell),
        cell,
      );
    }
    for (final entry in SnakesRules.snakes.entries) {
      _drawSnake(
        canvas,
        _centerFor(entry.key, cell),
        _centerFor(entry.value, cell),
        cell,
      );
    }
    _drawTokens(canvas, cell);
  }

  void _drawLadder(Canvas canvas, Offset from, Offset to, double cell) {
    final vector = to - from;
    final distance = vector.distance;
    final normal =
        Offset(-vector.dy / distance, vector.dx / distance) * (cell * .13);
    final rail = Paint()
      ..color = const Color(0xFFFFB62D)
      ..strokeWidth = cell * .075
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from + normal, to + normal, rail);
    canvas.drawLine(from - normal, to - normal, rail);
    final rungs = math.max(3, (distance / (cell * .48)).floor());
    for (var i = 0; i <= rungs; i++) {
      final point = Offset.lerp(from, to, i / rungs)!;
      canvas.drawLine(
        point - normal,
        point + normal,
        rail..strokeWidth = cell * .055,
      );
    }
  }

  void _drawSnake(Canvas canvas, Offset head, Offset tail, double cell) {
    final vector = tail - head;
    final distance = vector.distance;
    final normal = Offset(-vector.dy / distance, vector.dx / distance);
    final path = Path()..moveTo(head.dx, head.dy);
    const segments = 22;
    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final base = Offset.lerp(head, tail, t)!;
      final wave = math.sin(t * math.pi * 5) * cell * .22;
      final point = base + normal * wave;
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE94A72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * .18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: .28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * .045
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      head,
      cell * .15,
      Paint()..color = const Color(0xFFFF5C7E),
    );
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      head + Offset(-cell * .045, -cell * .035),
      cell * .028,
      eyePaint,
    );
    canvas.drawCircle(
      head + Offset(cell * .045, -cell * .035),
      cell * .028,
      eyePaint,
    );
  }

  void _drawTokens(Canvas canvas, double cell) {
    const colors = [ArenaTheme.coral, ArenaTheme.mint];
    for (var i = 0; i < positions.length; i++) {
      final position = positions[i];
      if (position == 0) continue;
      var center = _centerFor(position, cell);
      if (positions.length > 1 && positions[0] == positions[1]) {
        center += Offset(i == 0 ? -cell * .14 : cell * .14, 0);
      }
      canvas.drawCircle(
        center + Offset(0, cell * .08),
        cell * .21,
        Paint()..color = Colors.black.withValues(alpha: .28),
      );
      canvas.drawCircle(center, cell * .2, Paint()..color = Colors.white);
      canvas.drawCircle(center, cell * .15, Paint()..color = colors[i]);
      canvas.drawCircle(
        center - Offset(cell * .045, cell * .055),
        cell * .045,
        Paint()..color = Colors.white.withValues(alpha: .72),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SnakesBoardPainter oldDelegate) =>
      oldDelegate.positions[0] != positions[0] ||
      oldDelegate.positions[1] != positions[1];
}
