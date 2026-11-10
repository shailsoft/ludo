import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/theme.dart';
import '../../app/ui_components.dart';
import '../../game_core/game_core.dart';
import '../game/game_controller.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key, required this.versusBots});
  final bool versusBots;
  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  var players = 2;
  var quick = false;
  var difficulty = BotDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings(ref.watch(settingsProvider).language);
    return Scaffold(
      body: ArenaBackdrop(
        child: Column(
          children: [
            _TopBar(
              title: widget.versusBots ? t.get('computer') : t.get('play'),
              onBack: context.pop,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  Text(
                    'Build your table',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the pace, seats, and challenge. Fair dice—always.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 26),
                  const _Label('MATCH STYLE'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _RuleCard(
                          selected: !quick,
                          title: t.get('classic'),
                          detail: '4 TOKENS',
                          caption: 'The complete strategy game',
                          icon: Icons.grid_view_rounded,
                          color: ArenaTheme.purple,
                          onTap: () => setState(() => quick = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RuleCard(
                          selected: quick,
                          title: t.get('quick'),
                          detail: '2 TOKENS',
                          caption: 'Fast, focused, fierce',
                          icon: Icons.bolt_rounded,
                          color: ArenaTheme.gold,
                          onTap: () => setState(() => quick = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _Label('NUMBER OF SEATS'),
                  const SizedBox(height: 10),
                  GlassPanel(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        for (var count = 2; count <= 4; count++)
                          Expanded(
                            child: _CountButton(
                              count: count,
                              selected: players == count,
                              onTap: () => setState(() => players = count),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _SeatPreview(
                      key: ValueKey('${widget.versusBots}-$players'),
                      count: players,
                      bots: widget.versusBots,
                    ),
                  ),
                  if (widget.versusBots) ...[
                    const SizedBox(height: 26),
                    const _Label('BOT DIFFICULTY'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final level in BotDifficulty.values)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: level == BotDifficulty.hard ? 0 : 8,
                              ),
                              child: _DifficultyChip(
                                level: level,
                                selected: difficulty == level,
                                onTap: () => setState(() => difficulty = level),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  _RulesSummary(quick: quick),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ArenaTheme.purple.withValues(alpha: .3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(gameProvider.notifier)
                            .start(
                              playerCount: players,
                              versusBots: widget.versusBots,
                              rules: quick
                                  ? RuleProfile.quick
                                  : RuleProfile.classic,
                              difficulty: difficulty,
                            );
                        context.go('/game');
                      },
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: Text(t.get('start').toUpperCase()),
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 8, 20, 16),
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const ArenaPill(
          icon: Icons.verified_user_rounded,
          label: 'OFFLINE',
          color: ArenaTheme.mint,
        ),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: ArenaTheme.muted,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.6,
    ),
  );
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.selected,
    required this.title,
    required this.detail,
    required this.caption,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final bool selected;
  final String title, detail, caption;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    decoration: BoxDecoration(
      gradient: selected
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: .72),
                color.withValues(alpha: .3),
              ],
            )
          : null,
      color: selected ? null : Colors.white.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: selected
            ? color.withValues(alpha: .9)
            : Colors.white.withValues(alpha: .1),
        width: selected ? 1.8 : 1,
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: color.withValues(alpha: .2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ]
          : null,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GradientIcon(
                    icon: icon,
                    colors: [color, color.withValues(alpha: .62)],
                    size: 45,
                    iconSize: 21,
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected ? Colors.white : Colors.white24,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                caption,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  color: Colors.white.withValues(alpha: .65),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final int count;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Material(
      color: selected ? ArenaTheme.purple : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Column(
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                count == 2
                    ? 'DUEL'
                    : count == 3
                    ? 'TRIO'
                    : 'PARTY',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: selected ? Colors.white70 : ArenaTheme.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SeatPreview extends StatelessWidget {
  const _SeatPreview({super.key, required this.count, required this.bots});
  final int count;
  final bool bots;
  static const colors = [
    ArenaTheme.coral,
    ArenaTheme.mint,
    ArenaTheme.gold,
    ArenaTheme.sky,
  ];
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < count; i++)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == count - 1 ? 0 : 7),
            child: Column(
              children: [
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors[i].withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: colors[i].withValues(alpha: .35)),
                  ),
                  child: Center(
                    child: Icon(
                      i > 0 && bots
                          ? Icons.smart_toy_rounded
                          : Icons.person_rounded,
                      color: colors[i],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  i == 0
                      ? 'YOU'
                      : bots
                      ? 'BOT $i'
                      : 'PLAYER ${i + 1}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: ArenaTheme.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.level,
    required this.selected,
    required this.onTap,
  });
  final BotDifficulty level;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      BotDifficulty.easy => ArenaTheme.mint,
      BotDifficulty.medium => ArenaTheme.gold,
      BotDifficulty.hard => ArenaTheme.coral,
    };
    return Material(
      color: selected
          ? color.withValues(alpha: .2)
          : Colors.white.withValues(alpha: .05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : Colors.white.withValues(alpha: .08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                switch (level) {
                  BotDifficulty.easy => Icons.sentiment_satisfied_alt_rounded,
                  BotDifficulty.medium => Icons.psychology_rounded,
                  BotDifficulty.hard => Icons.local_fire_department_rounded,
                },
                color: color,
                size: 21,
              ),
              const SizedBox(height: 5),
              Text(
                level.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RulesSummary extends StatelessWidget {
  const _RulesSummary({required this.quick});
  final bool quick;
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const GradientIcon(
              icon: Icons.rule_rounded,
              colors: [ArenaTheme.violet, ArenaTheme.sky],
              size: 42,
              iconSize: 21,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quick ? 'Quick rules' : 'Classic rules',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    quick
                        ? 'Finish both tokens to win'
                        : 'Bring all four tokens home',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ArenaTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ArenaPill(
              icon: Icons.casino_rounded,
              label: '6 TO ENTER',
              color: ArenaTheme.gold,
            ),
            ArenaPill(
              icon: Icons.gps_fixed_rounded,
              label: 'SAFE STARS',
              color: ArenaTheme.mint,
            ),
            ArenaPill(
              icon: Icons.flag_rounded,
              label: 'EXACT FINISH',
              color: ArenaTheme.sky,
            ),
          ],
        ),
      ],
    ),
  );
}
