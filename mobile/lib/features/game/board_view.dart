import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game_core/game_core.dart';

class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.state, required this.onTokenTap});
  final GameState state;
  final ValueChanged<String> onTokenTap;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: LayoutBuilder(
      builder: (_, box) {
        return GestureDetector(
          onTapUp: (d) {
            final cell = box.maxWidth / 15;
            String? found;
            var best = cell * .65;
            for (final token in RulesEngine.legalMoves(state)) {
              final p = BoardGeometry.tokenPoint(state, token, cell);
              final distance = (p - d.localPosition).distance;
              if (distance < best) {
                best = distance;
                found = token.id;
              }
            }
            if (found != null) onTokenTap(found);
          },
          child: Semantics(
            label: 'Ludo board. ${state.activePlayer.name} turn.',
            child: CustomPaint(painter: BoardPainter(state)),
          ),
        );
      },
    ),
  );
}

abstract final class BoardGeometry {
  static const track = <(int, int)>[
    (6, 1),
    (6, 2),
    (6, 3),
    (6, 4),
    (6, 5),
    (5, 6),
    (4, 6),
    (3, 6),
    (2, 6),
    (1, 6),
    (0, 6),
    (0, 7),
    (0, 8),
    (1, 8),
    (2, 8),
    (3, 8),
    (4, 8),
    (5, 8),
    (6, 9),
    (6, 10),
    (6, 11),
    (6, 12),
    (6, 13),
    (6, 14),
    (7, 14),
    (8, 14),
    (8, 13),
    (8, 12),
    (8, 11),
    (8, 10),
    (8, 9),
    (9, 8),
    (10, 8),
    (11, 8),
    (12, 8),
    (13, 8),
    (14, 8),
    (14, 7),
    (14, 6),
    (13, 6),
    (12, 6),
    (11, 6),
    (10, 6),
    (9, 6),
    (8, 5),
    (8, 4),
    (8, 3),
    (8, 2),
    (8, 1),
    (8, 0),
    (7, 0),
    (6, 0),
  ];
  static Offset tokenPoint(GameState state, Token token, double cell) {
    final player = state.players.firstWhere((p) => p.id == token.playerId);
    (double, double) grid;
    if (token.isInYard) {
      final index = state
          .tokensFor(token.playerId)
          .indexWhere((t) => t.id == token.id);
      const yard = <PlayerColor, List<(double, double)>>{
        PlayerColor.red: [(1.8, 1.8), (4.2, 1.8), (1.8, 4.2), (4.2, 4.2)],
        PlayerColor.green: [(10.8, 1.8), (13.2, 1.8), (10.8, 4.2), (13.2, 4.2)],
        PlayerColor.yellow: [
          (10.8, 10.8),
          (13.2, 10.8),
          (10.8, 13.2),
          (13.2, 13.2),
        ],
        PlayerColor.blue: [(1.8, 10.8), (4.2, 10.8), (1.8, 13.2), (4.2, 13.2)],
      };
      grid = yard[player.color]![index % 4];
    } else if (token.isOnTrack) {
      final c = track[LudoBoard.absoluteTrackIndex(player.color, token.steps)];
      grid = (c.$2 + .5, c.$1 + .5);
    } else {
      final n = (token.steps - 51).clamp(1, 6).toDouble();
      grid = switch (player.color) {
        PlayerColor.red => (n + .5, 7.5),
        PlayerColor.green => (7.5, n + .5),
        PlayerColor.yellow => (14.5 - n, 7.5),
        PlayerColor.blue => (7.5, 14.5 - n),
      };
    }
    final siblings = state.tokens
        .where(
          (t) =>
              t.id != token.id &&
              t.playerId == token.playerId &&
              t.steps == token.steps,
        )
        .toList();
    final offset = siblings.isEmpty
        ? 0.0
        : (state.tokensFor(token.playerId).indexOf(token).isEven ? -.13 : .13);
    return Offset((grid.$1 + offset) * cell, (grid.$2 + offset) * cell);
  }
}

class BoardPainter extends CustomPainter {
  BoardPainter(this.state);
  final GameState state;
  static const colors = <PlayerColor, Color>{
    PlayerColor.red: Color(0xFFFF596D),
    PlayerColor.green: Color(0xFF34CFA0),
    PlayerColor.yellow: Color(0xFFFFBF3F),
    PlayerColor.blue: Color(0xFF48A9FF),
  };
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;
    final line = Paint()
      ..color = const Color(0xFFD9D5E3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .55;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      Paint()..color = const Color(0xFFF5F1FA),
    );
    void fillRect(int row, int col, Color color) {
      final r = Rect.fromLTWH(col * cell, row * cell, cell, cell).deflate(.45);
      final rr = RRect.fromRectAndRadius(r, Radius.circular(cell * .09));
      canvas.drawRRect(rr, Paint()..color = color);
      canvas.drawRRect(rr, line);
    }

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
    );
    void yard(double left, double top, PlayerColor color) {
      final outer = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left * cell,
          top * cell,
          6 * cell,
          6 * cell,
        ).deflate(cell * .14),
        Radius.circular(cell * .38),
      );
      canvas.drawRRect(
        outer,
        Paint()..color = colors[color]!.withValues(alpha: .92),
      );
      final inner = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (left + 1.05) * cell,
          (top + 1.05) * cell,
          3.9 * cell,
          3.9 * cell,
        ),
        Radius.circular(cell * .55),
      );
      canvas.drawRRect(inner, Paint()..color = const Color(0xFFF9F7FC));
      canvas.drawRRect(
        inner,
        Paint()
          ..color = colors[color]!.withValues(alpha: .15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * .12,
      );
    }

    yard(0, 0, PlayerColor.red);
    yard(9, 0, PlayerColor.green);
    yard(9, 9, PlayerColor.yellow);
    yard(0, 9, PlayerColor.blue);
    for (final c in BoardGeometry.track) {
      fillRect(c.$1, c.$2, const Color(0xFFFEFCFF));
    }
    for (var i = 1; i <= 6; i++) {
      fillRect(7, i, colors[PlayerColor.red]!.withValues(alpha: .82));
      fillRect(i, 7, colors[PlayerColor.green]!.withValues(alpha: .82));
      fillRect(7, 14 - i, colors[PlayerColor.yellow]!.withValues(alpha: .82));
      fillRect(14 - i, 7, colors[PlayerColor.blue]!.withValues(alpha: .82));
    }
    fillRect(6, 1, colors[PlayerColor.red]!);
    fillRect(1, 8, colors[PlayerColor.green]!);
    fillRect(8, 13, colors[PlayerColor.yellow]!);
    fillRect(13, 6, colors[PlayerColor.blue]!);
    void triangle(List<Offset> points, PlayerColor color) {
      final p = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        p.lineTo(point.dx, point.dy);
      }
      p.close();
      canvas.drawPath(p, Paint()..color = colors[color]!);
    }

    final c = Offset(7.5 * cell, 7.5 * cell);
    triangle([
      Offset(6 * cell, 6 * cell),
      Offset(9 * cell, 6 * cell),
      c,
    ], PlayerColor.green);
    triangle([
      Offset(9 * cell, 6 * cell),
      Offset(9 * cell, 9 * cell),
      c,
    ], PlayerColor.yellow);
    triangle([
      Offset(9 * cell, 9 * cell),
      Offset(6 * cell, 9 * cell),
      c,
    ], PlayerColor.blue);
    triangle([
      Offset(6 * cell, 9 * cell),
      Offset(6 * cell, 6 * cell),
      c,
    ], PlayerColor.red);
    for (final safe in state.rules.safeSquares) {
      final c = BoardGeometry.track[safe];
      final p = Offset((c.$2 + .5) * cell, (c.$1 + .5) * cell);
      final star = Path();
      for (var i = 0; i < 10; i++) {
        final angle = -1.5708 + i * 3.14159 / 5;
        final radius = cell * (i.isEven ? .25 : .11);
        final point = Offset(
          p.dx + radius * math.cos(angle),
          p.dy + radius * math.sin(angle),
        );
        if (i == 0) {
          star.moveTo(point.dx, point.dy);
        } else {
          star.lineTo(point.dx, point.dy);
        }
      }
      star.close();
      canvas.drawPath(star, Paint()..color = const Color(0xFF4F4676));
    }
    final legal = RulesEngine.legalMoves(state).map((t) => t.id).toSet();
    void drawPawn(Offset center, Color color, bool highlighted) {
      if (highlighted) {
        canvas.drawCircle(
          center,
          cell * .45,
          Paint()..color = color.withValues(alpha: .25),
        );
        canvas.drawCircle(
          center,
          cell * .38,
          Paint()
            ..color = color.withValues(alpha: .8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.7,
        );
      }

      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(0, cell * .29),
          width: cell * .66,
          height: cell * .2,
        ),
        Paint()..color = Colors.black.withValues(alpha: .25),
      );

      final baseRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(0, cell * .19),
          width: cell * .64,
          height: cell * .24,
        ),
        Radius.circular(cell * .12),
      );
      canvas.drawRRect(baseRect, Paint()..color = Colors.white);
      final colorBase = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(0, cell * .17),
          width: cell * .54,
          height: cell * .16,
        ),
        Radius.circular(cell * .08),
      );
      canvas.drawRRect(colorBase, Paint()..color = color);

      final cone = Path()
        ..moveTo(center.dx, center.dy - cell * .35)
        ..quadraticBezierTo(
          center.dx - cell * .08,
          center.dy - cell * .18,
          center.dx - cell * .23,
          center.dy + cell * .13,
        )
        ..quadraticBezierTo(
          center.dx,
          center.dy + cell * .25,
          center.dx + cell * .23,
          center.dy + cell * .13,
        )
        ..quadraticBezierTo(
          center.dx + cell * .08,
          center.dy - cell * .18,
          center.dx,
          center.dy - cell * .35,
        )
        ..close();
      canvas.drawShadow(cone, Colors.black.withValues(alpha: .45), 3, false);
      canvas.drawPath(cone, Paint()..color = color);

      final band = Path()
        ..moveTo(center.dx - cell * .15, center.dy - cell * .02)
        ..quadraticBezierTo(
          center.dx,
          center.dy + cell * .04,
          center.dx + cell * .15,
          center.dy - cell * .02,
        )
        ..lineTo(center.dx + cell * .11, center.dy + cell * .07)
        ..quadraticBezierTo(
          center.dx,
          center.dy + cell * .12,
          center.dx - cell * .11,
          center.dy + cell * .07,
        )
        ..close();
      canvas.drawPath(
        band,
        Paint()..color = Colors.white.withValues(alpha: .72),
      );
      canvas.drawCircle(
        center - Offset(cell * .035, cell * .25),
        cell * .055,
        Paint()..color = Colors.white.withValues(alpha: .65),
      );
    }

    for (final token in state.tokens) {
      final player = state.players.firstWhere((p) => p.id == token.playerId);
      final p = BoardGeometry.tokenPoint(state, token, cell);
      drawPawn(p, colors[player.color]!, legal.contains(token.id));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      oldDelegate.state.revision != state.revision;
}
