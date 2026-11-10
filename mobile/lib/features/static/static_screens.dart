import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/local_store.dart';
import '../../app/settings.dart';
import '../../app/theme.dart';
import '../../app/ui_components.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final t = AppStrings(settings.language);
    return Scaffold(
      body: ArenaBackdrop(
        child: Column(
          children: [
            _PageHeader(
              title: t.get('settings'),
              subtitle: 'Make the arena feel like yours',
              icon: Icons.tune_rounded,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  const _SectionLabel('LANGUAGE'),
                  const SizedBox(height: 10),
                  GlassPanel(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _LanguageButton(
                            label: 'English',
                            flag: 'EN',
                            selected: settings.language == 'en',
                            onTap: () => controller.update(
                              settings.copyWith(language: 'en'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LanguageButton(
                            label: 'हिन्दी',
                            flag: 'हि',
                            selected: settings.language == 'hi',
                            onTap: () => controller.update(
                              settings.copyWith(language: 'hi'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('SOUND & FEEDBACK'),
                  const SizedBox(height: 10),
                  GlassPanel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingTile(
                          title: t.get('music'),
                          subtitle: 'Ambient lobby and match music',
                          icon: Icons.music_note_rounded,
                          color: ArenaTheme.purple,
                          value: settings.music,
                          onChanged: (value) => controller.update(
                            settings.copyWith(music: value),
                          ),
                        ),
                        _line(),
                        _SettingTile(
                          title: t.get('sfx'),
                          subtitle: 'Dice, movement and victory cues',
                          icon: Icons.graphic_eq_rounded,
                          color: ArenaTheme.gold,
                          value: settings.sfx,
                          onChanged: (value) =>
                              controller.update(settings.copyWith(sfx: value)),
                        ),
                        _line(),
                        _SettingTile(
                          title: t.get('haptics'),
                          subtitle: 'Tactile feedback for every move',
                          icon: Icons.vibration_rounded,
                          color: ArenaTheme.mint,
                          value: settings.haptics,
                          onChanged: (value) => controller.update(
                            settings.copyWith(haptics: value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('GAMEPLAY'),
                  const SizedBox(height: 10),
                  GlassPanel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingTile(
                          title: t.get('reduced'),
                          subtitle: 'Shorter and simpler transitions',
                          icon: Icons.motion_photos_off_rounded,
                          color: ArenaTheme.sky,
                          value: settings.reducedMotion,
                          onChanged: (value) => controller.update(
                            settings.copyWith(reducedMotion: value),
                          ),
                        ),
                        const Divider(height: 1, indent: 68),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(13, 11, 14, 11),
                          child: Row(
                            children: [
                              GradientIcon(
                                icon: Icons.auto_awesome_motion_rounded,
                                colors: [ArenaTheme.coral, ArenaTheme.purple],
                                size: 42,
                                iconSize: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Smart auto-move',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Always on when only one piece can move',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: ArenaTheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ArenaPill(
                                icon: Icons.check_rounded,
                                label: 'ON',
                                color: ArenaTheme.mint,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const GlassPanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.accessibility_new_rounded,
                          color: ArenaTheme.gold,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Every essential game event has a visual cue. Audio and vibration are always optional.',
                            style: TextStyle(
                              fontSize: 12,
                              color: ArenaTheme.muted,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
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

  Widget _line() => Divider(
    height: 1,
    indent: 68,
    color: Colors.white.withValues(alpha: .07),
  );
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title, subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 8, 20, 20),
    child: Row(
      children: [
        IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        GradientIcon(
          icon: icon,
          colors: const [ArenaTheme.purple, ArenaTheme.sky],
          size: 46,
          iconSize: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: ArenaTheme.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
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

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });
  final String label, flag;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? ArenaTheme.purple : Colors.transparent,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Text(
                flag,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, size: 18),
          ],
        ),
      ),
    ),
  );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(13, 11, 11, 11),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: ArenaTheme.muted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeTrackColor: color,
          activeThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});
  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  var selected = 0;
  static const lessons = [
    (
      title: 'Roll to enter',
      body: 'A six brings a token out of your yard and earns another roll.',
      icon: Icons.casino_rounded,
      color: ArenaTheme.coral,
      value: 6,
    ),
    (
      title: 'Race the track',
      body: 'Move clockwise by the exact dice value. Only highlighted tokens are legal.',
      icon: Icons.route_rounded,
      color: ArenaTheme.sky,
      value: 4,
    ),
    (
      title: 'Capture smart',
      body: 'Land on an opponent to send it back—unless the cell carries a safe star.',
      icon: Icons.gps_fixed_rounded,
      color: ArenaTheme.mint,
      value: 3,
    ),
    (
      title: 'Finish exactly',
      body: 'You need the exact number to enter home. Finish all active tokens to win.',
      icon: Icons.emoji_events_rounded,
      color: ArenaTheme.gold,
      value: 1,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final lesson = lessons[selected];
    return Scaffold(
      body: ArenaBackdrop(
        child: Column(
          children: [
            const _PageHeader(
              title: 'How to play',
              subtitle: 'Four ideas. One timeless game.',
              icon: Icons.school_rounded,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          key: ValueKey(selected),
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                lesson.color.withValues(alpha: .55),
                                ArenaTheme.navy,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: lesson.color.withValues(alpha: .6),
                            ),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ArenaPill(
                                  icon: Icons.menu_book_rounded,
                                  label: 'LESSON ${selected + 1} OF 4',
                                  color: lesson.color,
                                ),
                              ),
                              const Spacer(),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: .06,
                                      ),
                                      border: Border.all(
                                        color: Colors.white12,
                                        width: 18,
                                      ),
                                    ),
                                  ),
                                  DiceMark(
                                    size: 92,
                                    color: lesson.color,
                                    value: lesson.value,
                                  ),
                                  Positioned(
                                    right: 32,
                                    bottom: 28,
                                    child: GradientIcon(
                                      icon: lesson.icon,
                                      colors: [
                                        lesson.color,
                                        lesson.color.withValues(alpha: .55),
                                      ],
                                      size: 48,
                                      iconSize: 23,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                lesson.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                lesson.body,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: selected == 0
                              ? null
                              : () => setState(() => selected--),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < lessons.length; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: i == selected ? 24 : 7,
                                  height: 7,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: i == selected
                                        ? lesson.color
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: selected == lessons.length - 1
                              ? () => context.pop()
                              : () => setState(() => selected++),
                          icon: Icon(
                            selected == lessons.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ArenaBackdrop(
      child: Column(
        children: [
          const _PageHeader(
            title: 'Your statistics',
            subtitle: 'Every match leaves a story',
            icon: Icons.insights_rounded,
          ),
          Expanded(
            child: FutureBuilder<Map<String, int>>(
              future: LocalStore.instance.stats(),
              builder: (_, snapshot) {
                final stats = snapshot.data ?? const {};
                final matches = stats['matches'] ?? 0;
                final wins = stats['wins'] ?? 0;
                final losses = stats['losses'] ?? 0;
                final rate = matches == 0 ? 0 : (wins * 100 / matches).round();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 28),
                  children: [
                    Container(
                      height: 190,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [ArenaTheme.purple, Color(0xFF3C308C)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: ArenaTheme.purple.withValues(alpha: .3),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ArenaPill(
                                  icon: Icons.workspace_premium_rounded,
                                  label: 'PLAYER RECORD',
                                  color: ArenaTheme.gold,
                                ),
                                const Spacer(),
                                Text(
                                  '$rate%',
                                  style: const TextStyle(
                                    fontSize: 50,
                                    height: .9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'WIN RATE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.6,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DiceMark(
                            size: 96,
                            value: matches == 0 ? 1 : (matches % 6) + 1,
                            color: ArenaTheme.gold,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.18,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _StatCard(
                          label: 'MATCHES',
                          value: '$matches',
                          icon: Icons.sports_esports_rounded,
                          color: ArenaTheme.sky,
                        ),
                        _StatCard(
                          label: 'VICTORIES',
                          value: '$wins',
                          icon: Icons.emoji_events_rounded,
                          color: ArenaTheme.gold,
                        ),
                        _StatCard(
                          label: 'LOSSES',
                          value: '$losses',
                          icon: Icons.flag_rounded,
                          color: ArenaTheme.coral,
                        ),
                        _StatCard(
                          label: 'TOTAL MOVES',
                          value: '${stats['moves'] ?? 0}',
                          icon: Icons.route_rounded,
                          color: ArenaTheme.mint,
                        ),
                      ],
                    ),
                    if (matches == 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 18),
                        child: GlassPanel(
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: ArenaTheme.gold,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your journey begins with the first roll. Play a match to bring these cards to life.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ArenaTheme.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 29,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: ArenaTheme.muted,
          ),
        ),
      ],
    ),
  );
}
