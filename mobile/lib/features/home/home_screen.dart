import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/local_store.dart';
import '../../app/settings.dart';
import '../../app/theme.dart';
import '../../app/ui_components.dart';
import '../game/game_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit;
  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings(ref.watch(settingsProvider).language);
    return Scaffold(
      body: ArenaBackdrop(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
              sliver: SliverList.list(
                children: [
                  _Header(
                    title: t.get('title'),
                    onSettings: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 14),
                  ArenaGameTabs(
                    snakesSelected: false,
                    onLudo: () {},
                    onSnakes: () => context.push('/snakes'),
                  ),
                  const SizedBox(height: 18),
                  _HeroCard(animation: _orbit),
                  const SizedBox(height: 18),
                  FutureBuilder<bool>(
                    future: LocalStore.instance.hasSavedGame(),
                    builder: (_, snapshot) => snapshot.data == true
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ResumeCard(
                              label: t.get('resume'),
                              onTap: () async {
                                if (await ref
                                        .read(gameProvider.notifier)
                                        .resume() &&
                                    context.mounted) {
                                  context.go('/game');
                                }
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeCard(
                          eyebrow: 'LOCAL PARTY',
                          title: t.get('play'),
                          detail: '2–4 players',
                          icon: Icons.groups_rounded,
                          colors: const [ArenaTheme.coral, Color(0xFFD43A78)],
                          onTap: () => context.push('/setup/friends'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModeCard(
                          eyebrow: 'SOLO PLAY',
                          title: t.get('computer'),
                          detail: 'Smart opponents',
                          icon: Icons.smart_toy_rounded,
                          colors: const [ArenaTheme.mint, Color(0xFF168E91)],
                          onTap: () => context.push('/setup/bots'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ComingSoonCard(label: t.get('online')),
                  const SizedBox(height: 22),
                  const _SectionLabel(label: 'YOUR CLUBHOUSE'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _UtilityCard(
                          icon: Icons.school_rounded,
                          label: t.get('tutorial'),
                          color: ArenaTheme.gold,
                          onTap: () => context.push('/tutorial'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _UtilityCard(
                          icon: Icons.insights_rounded,
                          label: t.get('stats'),
                          color: ArenaTheme.sky,
                          onTap: () => context.push('/stats'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onSettings});
  final String title;
  final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const GradientIcon(
        icon: Icons.casino_rounded,
        colors: [ArenaTheme.gold, Color(0xFFFF8A3D)],
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELCOME BACK',
              style: TextStyle(
                color: ArenaTheme.gold.withValues(alpha: .9),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      IconButton(onPressed: onSettings, icon: const Icon(Icons.tune_rounded)),
    ],
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.animation});
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => Container(
    height: 238,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6B4EFF), Color(0xFF3B2E8E)],
      ),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: ArenaTheme.purple.withValues(alpha: .32),
          blurRadius: 34,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -45,
          top: -36,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .06),
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: -5,
          child: LudoOrbit(animation: animation, size: 190),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ArenaPill(
                icon: Icons.auto_awesome_rounded,
                label: 'THE CLASSIC, REIMAGINED',
                color: Colors.white,
              ),
              const Spacer(),
              const SizedBox(
                width: 190,
                child: Text(
                  'Make your move.',
                  style: TextStyle(
                    fontSize: 32,
                    height: .98,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Roll. Race. Rule the board.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const DiceMark(size: 50, value: 4, color: ArenaTheme.purple),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Your board is waiting',
                    style: TextStyle(color: ArenaTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: ArenaTheme.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.icon,
    required this.colors,
    required this.onTap,
  });
  final String eyebrow, title, detail;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.first.withValues(alpha: .92), colors.last],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: .23),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.white.withValues(alpha: .7),
                ),
              ],
            ),
            const Spacer(),
            Text(
              eyebrow,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                color: Colors.white.withValues(alpha: .72),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                height: 1.06,
                fontWeight: FontWeight.w900,
                letterSpacing: -.4,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: .72),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        GradientIcon(
          icon: Icons.language_rounded,
          colors: [ArenaTheme.sky.withValues(alpha: .9), ArenaTheme.violet],
          size: 46,
          iconSize: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              const Text(
                'Private rooms • Matchmaking',
                style: TextStyle(fontSize: 12, color: ArenaTheme.muted),
              ),
            ],
          ),
        ),
        const ArenaPill(
          icon: Icons.schedule_rounded,
          label: 'SOON',
          color: ArenaTheme.gold,
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: ArenaTheme.muted,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.7,
    ),
  );
}

class _UtilityCard extends StatelessWidget {
  const _UtilityCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        radius: 20,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: ArenaTheme.muted,
            ),
          ],
        ),
      ),
    ),
  );
}
