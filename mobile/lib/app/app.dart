import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/game/game_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/splash_screen.dart';
import '../features/setup/setup_screen.dart';
import '../features/snakes/snakes_screen.dart';
import '../features/static/static_screens.dart';
import 'settings.dart';
import 'theme.dart';
import 'audio_service.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(path: '/', name: 'home', builder: (_, _) => const HomeScreen()),
    GoRoute(
      path: '/setup/:kind',
      name: 'setup',
      builder: (_, s) =>
          SetupScreen(versusBots: s.pathParameters['kind'] == 'bots'),
    ),
    GoRoute(path: '/game', name: 'game', builder: (_, _) => const GameScreen()),
    GoRoute(
      path: '/snakes',
      name: 'snakes',
      builder: (_, _) => const SnakesScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, _) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      name: 'tutorial',
      builder: (_, _) => const TutorialScreen(),
    ),
    GoRoute(
      path: '/stats',
      name: 'stats',
      builder: (_, _) => const StatsScreen(),
    ),
  ],
);

class LudoArenaApp extends ConsumerWidget {
  const LudoArenaApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final settings = ref.watch(settingsProvider);
    AudioService.instance.sync(settings);
    return MaterialApp.router(
      title: language == 'hi' ? 'लूडो एरीना' : 'Ludo Arena',
      debugShowCheckedModeBanner: false,
      theme: ArenaTheme.light,
      routerConfig: _router,
    );
  }
}
