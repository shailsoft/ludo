import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/theme.dart';
import '../../app/ui_components.dart';
import '../../game_core/game_core.dart';
import 'board_view.dart';
import 'game_controller.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final t = AppStrings(settings.language);
    if (state == null) {
      return Scaffold(
        body: ArenaBackdrop(
          child: Center(
            child: FilledButton(
              onPressed: () => context.go('/'),
              child: Text(t.get('home')),
            ),
          ),
        ),
      );
    }

    final legal = RulesEngine.legalMoves(state);
    if (state.phase == GamePhase.waitingForMove &&
        legal.length == 1 &&
        state.activePlayer.type == PlayerType.human) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(gameProvider.notifier).move(legal.single.id),
      );
    }
    final activeColor = BoardPainter.colors[state.activePlayer.color]!;

    return Scaffold(
      body: ArenaBackdrop(
        child: Column(
          children: [
            _GameHeader(state: state, onPause: () => _pause(context, t)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: ArenaGameTabs(
                snakesSelected: false,
                onLudo: () {},
                onSnakes: () => context.push('/snakes'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  for (final player in state.players)
                    Expanded(
                      child: _PlayerChip(player: player, state: state),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: .78,
                    colors: [
                      activeColor.withValues(alpha: .18),
                      ArenaTheme.ink.withValues(alpha: .08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .05),
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: _BoardStagePainter()),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final boardSize = constraints.maxWidth
                            .clamp(0, constraints.maxHeight - 20)
                            .toDouble();
                        return Center(
                          child: Container(
                            width: boardSize,
                            height: boardSize,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  activeColor.withValues(alpha: .9),
                                  ArenaTheme.purple.withValues(alpha: .72),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(27),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: .25),
                                  blurRadius: 38,
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .52),
                                  blurRadius: 30,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: BoardView(
                                state: state,
                                onTokenTap: (id) =>
                                    ref.read(gameProvider.notifier).move(id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 16,
                      top: 12,
                      child: ArenaPill(
                        icon: Icons.auto_awesome_rounded,
                        label: legal.length == 1 ? 'AUTO MOVE' : 'ARENA BOARD',
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: settings.reducedMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, .12), end: Offset.zero)
                      .animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              ),
              child: state.phase == GamePhase.finished
                  ? _ResultPanel(
                      key: const ValueKey('result'),
                      state: state,
                      t: t,
                    )
                  : _TurnConsole(
                      key: ValueKey(
                        '${state.activePlayer.id}-${state.phase}-${state.revision}',
                      ),
                      state: state,
                      t: t,
                      onRoll: () => ref.read(gameProvider.notifier).roll(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pause(BuildContext context, AppStrings t) =>
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) => Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF29345F), Color(0xFF171D39)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white12),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                const GradientIcon(
                  icon: Icons.pause_rounded,
                  colors: [ArenaTheme.purple, ArenaTheme.sky],
                  size: 62,
                  iconSize: 30,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Match paused',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Your progress is already safe.',
                  style: TextStyle(color: ArenaTheme.muted),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('RESUME MATCH'),
                ),
                const SizedBox(height: 9),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.go('/');
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: Text('SAVE & ${t.get('home').toUpperCase()}'),
                ),
              ],
            ),
          ),
        ),
      );
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({required this.state, required this.onPause});
  final GameState state;
  final VoidCallback onPause;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
    child: Row(
      children: [
        const GradientIcon(
          icon: Icons.casino_rounded,
          colors: [ArenaTheme.gold, Color(0xFFFF8D45)],
          size: 43,
          iconSize: 21,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.rules.id == 'quick' ? 'QUICK MATCH' : 'CLASSIC MATCH',
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: ArenaTheme.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Round ${state.revision + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        ArenaPill(
          icon: Icons.people_alt_rounded,
          label: '${state.players.length} PLAYERS',
          color: ArenaTheme.sky,
        ),
        const SizedBox(width: 8),
        IconButton(onPressed: onPause, icon: const Icon(Icons.pause_rounded)),
      ],
    ),
  );
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.player, required this.state});
  final Player player;
  final GameState state;
  @override
  Widget build(BuildContext context) {
    final active = player.id == state.activePlayer.id;
    final color = BoardPainter.colors[player.color]!;
    final finished = state
        .tokensFor(player.id)
        .where((token) => token.isFinished)
        .length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: .2)
            : Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color : Colors.white.withValues(alpha: .06),
          width: active ? 1.6 : 1,
        ),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: .2), blurRadius: 14)]
            : null,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  player.type == PlayerType.bot
                      ? Icons.smart_toy_rounded
                      : Icons.person_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              if (active)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: ArenaTheme.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: active ? Colors.white : Colors.white60,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < state.rules.tokensPerPlayer; i++)
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: i < finished ? color : Colors.white12,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TurnConsole extends StatelessWidget {
  const _TurnConsole({
    super.key,
    required this.state,
    required this.t,
    required this.onRoll,
  });
  final GameState state;
  final AppStrings t;
  final VoidCallback onRoll;
  @override
  Widget build(BuildContext context) {
    final color = BoardPainter.colors[state.activePlayer.color]!;
    final waiting = state.phase == GamePhase.waitingForRoll;
    final human = state.activePlayer.type == PlayerType.human;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: .23),
            Colors.white.withValues(alpha: .07),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedRotation(
            turns: state.revision / 4,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            child: DiceMark(
              size: 61,
              value: state.pendingRoll ?? 5,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  human
                      ? "${state.activePlayer.name}'s turn"
                      : '${state.activePlayer.name} is thinking…',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  waiting
                      ? (human
                            ? 'Tap roll and trust your luck'
                            : 'Preparing the dice')
                      : (human
                            ? 'Pick one of the glowing tokens'
                            : 'Choosing the best move'),
                  style: const TextStyle(fontSize: 12, color: ArenaTheme.muted),
                ),
              ],
            ),
          ),
          if (waiting && human) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onRoll,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(82, 52),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(
                t.get('roll'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ] else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                waiting ? Icons.hourglass_top_rounded : Icons.touch_app_rounded,
                color: color,
                size: 19,
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({super.key, required this.state, required this.t});
  final GameState state;
  final AppStrings t;
  @override
  Widget build(BuildContext context) {
    final winner = state.players.firstWhere(
      (player) => player.id == state.winnerPlayerId,
    );
    final color = BoardPainter.colors[winner.color]!;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: .42),
            ArenaTheme.purple.withValues(alpha: .34),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: .65)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: ArenaTheme.gold,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ArenaTheme.gold.withValues(alpha: .35),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: ArenaTheme.ink,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.get('winner').toUpperCase(),
                  style: const TextStyle(
                    color: ArenaTheme.gold,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  winner.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.go('/'),
            style: FilledButton.styleFrom(minimumSize: const Size(75, 50)),
            child: Text(t.get('home')),
          ),
        ],
      ),
    );
  }
}

class _BoardStagePainter extends CustomPainter {
  const _BoardStagePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .045);
    for (var radius = 70.0; radius < size.longestSide * .65; radius += 38) {
      canvas.drawCircle(center, radius, ring);
    }
    final dot = Paint()..color = Colors.white.withValues(alpha: .045);
    for (double y = 18; y < size.height; y += 24) {
      for (double x = 18; x < size.width; x += 24) {
        canvas.drawCircle(Offset(x, y), 1.15, dot);
      }
    }
    final corner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .035);
    canvas.drawLine(const Offset(24, 54), const Offset(24, 24), corner);
    canvas.drawLine(const Offset(24, 24), const Offset(54, 24), corner);
    canvas.drawLine(
      Offset(size.width - 24, size.height - 54),
      Offset(size.width - 24, size.height - 24),
      corner,
    );
    canvas.drawLine(
      Offset(size.width - 24, size.height - 24),
      Offset(size.width - 54, size.height - 24),
      corner,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
