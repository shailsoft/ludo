import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/audio_service.dart';
import '../../app/local_store.dart';
import '../../app/settings.dart';
import '../../game_ai/bot.dart';
import '../../game_core/game_core.dart';

final gameProvider = NotifierProvider<GameController, GameState?>(
  GameController.new,
);

class GameController extends Notifier<GameState?> {
  final _random = Random();
  var moveCount = 0;
  @override
  GameState? build() => null;
  void start({
    required int playerCount,
    required bool versusBots,
    required RuleProfile rules,
    BotDifficulty difficulty = BotDifficulty.medium,
  }) {
    final players = List.generate(
      playerCount,
      (i) => Player(
        id: 'p$i',
        name: i == 0 ? 'You' : (versusBots ? 'Bot $i' : 'Player ${i + 1}'),
        color: PlayerColor.values[i],
        type: versusBots && i > 0 ? PlayerType.bot : PlayerType.human,
        difficulty: difficulty,
      ),
    );
    state = GameState.newGame(
      gameId: const Uuid().v4(),
      players: players,
      rules: rules,
    );
    moveCount = 0;
    _saveAndRunBot();
  }

  Future<bool> resume() async {
    state = await LocalStore.instance.loadGame();
    if (state != null) _runBotIfNeeded();
    return state != null;
  }

  void roll() {
    final s = state;
    if (s != null && s.phase == GamePhase.waitingForRoll) {
      _apply(RollDice(s.activePlayer.id, _random.nextInt(6) + 1));
    }
  }

  void move(String tokenId) {
    final s = state;
    if (s != null && s.phase == GamePhase.waitingForMove) {
      moveCount++;
      _apply(MoveToken(s.activePlayer.id, tokenId));
    }
  }

  void _apply(GameAction action) {
    final result = RulesEngine.applyAction(state!, action);
    state = result.state;
    final settings = ref.read(settingsProvider);
    final eventTypes = result.events.map((event) => event.type).toSet();
    final effect = eventTypes.contains(GameEventType.matchFinished)
        ? 'win'
        : eventTypes.contains(GameEventType.captured)
        ? 'capture'
        : action is RollDice
        ? 'roll'
        : 'move';
    AudioService.instance.effect(effect, enabled: settings.sfx);
    if (settings.haptics) {
      if (effect == 'capture' || effect == 'win') {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    _saveAndRunBot();
  }

  void _saveAndRunBot() {
    final s = state;
    if (s == null) return;
    if (s.phase == GamePhase.finished) {
      LocalStore.instance.recordResult(
        won: s.winnerPlayerId == s.players.first.id,
        moves: moveCount,
      );
      LocalStore.instance.clearGame();
    } else {
      LocalStore.instance.saveGame(s);
      _runBotIfNeeded();
    }
  }

  Future<void> _runBotIfNeeded() async {
    final s = state;
    if (s == null ||
        s.activePlayer.type != PlayerType.bot ||
        s.phase == GamePhase.finished) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (state?.activePlayer.id != s.activePlayer.id) return;
    if (state!.phase == GamePhase.waitingForRoll) {
      _apply(RollDice(state!.activePlayer.id, _random.nextInt(6) + 1));
    } else {
      final token = LudoBot(random: _random)
          .chooseToken(state!, state!.activePlayer.difficulty);
      if (token != null) move(token);
    }
  }
}
