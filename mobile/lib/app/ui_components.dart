import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

class ArenaBackdrop extends StatelessWidget {
  const ArenaBackdrop({super.key, required this.child, this.safeArea = true});
  final Widget child;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: ArenaTheme.pageGradient),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: .38,
              child: Image.asset(
                'assets/images/arena_board_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33212A58),
                    Color(0x99101635),
                    Color(0x44101635),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -110,
          right: -80,
          child: _Glow(
            size: 260,
            color: ArenaTheme.purple.withValues(alpha: .25),
          ),
        ),
        Positioned(
          top: 320,
          left: -130,
          child: _Glow(size: 280, color: ArenaTheme.sky.withValues(alpha: .12)),
        ),
        Positioned(
          bottom: -120,
          right: -80,
          child: _Glow(
            size: 260,
            color: ArenaTheme.coral.withValues(alpha: .11),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _DotPainter())),
        ),
        Positioned.fill(child: child),
      ],
    );
    return ColoredBox(
      color: ArenaTheme.ink,
      child: safeArea ? SafeArea(child: content) : content,
    );
  }
}

class ArenaGameTabs extends StatelessWidget {
  const ArenaGameTabs({
    super.key,
    required this.snakesSelected,
    required this.onLudo,
    required this.onSnakes,
  });

  final bool snakesSelected;
  final VoidCallback onLudo;
  final VoidCallback onSnakes;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xCC111833),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: Colors.white.withValues(alpha: .12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .22),
          blurRadius: 18,
          offset: const Offset(0, 9),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: _ArenaGameTab(
            selected: !snakesSelected,
            icon: Icons.grid_view_rounded,
            label: 'LUDO',
            color: ArenaTheme.coral,
            onTap: onLudo,
          ),
        ),
        Expanded(
          child: _ArenaGameTab(
            selected: snakesSelected,
            icon: Icons.route_rounded,
            label: 'SAANP-SEEDHI',
            color: ArenaTheme.mint,
            onTap: onSnakes,
          ),
        ),
      ],
    ),
  );
}

class _ArenaGameTab extends StatelessWidget {
  const _ArenaGameTab({
    required this.selected,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: .92),
                    color.withValues(alpha: .55),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(13),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: .24), blurRadius: 14)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? Colors.white : ArenaTheme.muted,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : ArenaTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 25)],
    ),
  );
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .035);
    for (double y = 24; y < size.height; y += 28) {
      for (
        double x = 20 + ((y ~/ 28).isEven ? 0 : 14);
        x < size.width;
        x += 28
      ) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.color,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? Colors.white.withValues(alpha: .075),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: .11)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .18),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: child,
  );
}

class GradientIcon extends StatelessWidget {
  const GradientIcon({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 52,
    this.iconSize = 26,
  });
  final IconData icon;
  final List<Color> colors;
  final double size;
  final double iconSize;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(size * .32),
      boxShadow: [
        BoxShadow(
          color: colors.last.withValues(alpha: .3),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Icon(icon, size: iconSize, color: Colors.white),
  );
}

class ArenaPill extends StatelessWidget {
  const ArenaPill({
    super.key,
    required this.icon,
    required this.label,
    this.color = ArenaTheme.gold,
  });
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class DiceMark extends StatelessWidget {
  const DiceMark({
    super.key,
    this.size = 56,
    this.color = ArenaTheme.gold,
    this.value = 5,
  });
  final double size;
  final Color color;
  final int value;
  @override
  Widget build(BuildContext context) {
    final points = switch (value.clamp(1, 6)) {
      1 => const [Alignment.center],
      2 => const [Alignment.topLeft, Alignment.bottomRight],
      3 => const [Alignment.topLeft, Alignment.center, Alignment.bottomRight],
      4 => const [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      5 => const [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.center,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      _ => const [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.centerLeft,
        Alignment.centerRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
    };
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFEDEBFF)],
        ),
        borderRadius: BorderRadius.circular(size * .25),
        border: Border.all(color: Colors.white, width: size * .035),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          for (final point in points)
            Align(
              alignment: point,
              child: Container(
                width: size * .13,
                height: size * .13,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-.35, -.35),
                    colors: [color.withValues(alpha: .72), color],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .28),
                      blurRadius: 2,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LudoOrbit extends StatelessWidget {
  const LudoOrbit({super.key, required this.animation, this.size = 190});
  final Animation<double> animation;
  final double size;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (_, _) => SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .68,
            height: size * .68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .08),
                width: 18,
              ),
            ),
          ),
          Transform.rotate(
            angle: animation.value * math.pi * 2,
            child: Stack(
              children: [
                _token(Alignment.topCenter, ArenaTheme.coral),
                _token(Alignment.centerRight, ArenaTheme.mint),
                _token(Alignment.bottomCenter, ArenaTheme.gold),
                _token(Alignment.centerLeft, ArenaTheme.sky),
              ],
            ),
          ),
          Transform.rotate(
            angle: -animation.value * math.pi * .14,
            child: const DiceMark(size: 74, value: 5),
          ),
        ],
      ),
    ),
  );

  Widget _token(Alignment alignment, Color color) => Align(
    alignment: alignment,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: .5), blurRadius: 15),
        ],
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .65),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}
