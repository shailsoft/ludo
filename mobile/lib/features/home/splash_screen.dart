import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui_components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    Future<void>.delayed(const Duration(milliseconds: 1450), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ArenaBackdrop(
      safeArea: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LudoOrbit(animation: _controller, size: 210),
            const SizedBox(height: 28),
            const Text(
              'LUDO',
              style: TextStyle(
                fontSize: 48,
                height: .9,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            const Text(
              'ARENA',
              style: TextStyle(
                color: ArenaTheme.gold,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 9,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 96,
              child: LinearProgressIndicator(
                minHeight: 3,
                borderRadius: BorderRadius.circular(9),
                backgroundColor: Colors.white10,
                color: ArenaTheme.gold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
