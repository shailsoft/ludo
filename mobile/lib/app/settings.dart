import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_store.dart';

class AppSettings {
  const AppSettings({
    this.language = 'en',
    this.music = true,
    this.sfx = true,
    this.haptics = true,
    this.reducedMotion = false,
    this.autoMove = false,
  });
  final String language;
  final bool music;
  final bool sfx;
  final bool haptics;
  final bool reducedMotion;
  final bool autoMove;
  AppSettings copyWith({
    String? language,
    bool? music,
    bool? sfx,
    bool? haptics,
    bool? reducedMotion,
    bool? autoMove,
  }) => AppSettings(
    language: language ?? this.language,
    music: music ?? this.music,
    sfx: sfx ?? this.sfx,
    haptics: haptics ?? this.haptics,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    autoMove: autoMove ?? this.autoMove,
  );
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    Future(() async {
      final d = await LocalStore.instance.loadSettings();
      state = AppSettings(
        language: d['language'] ?? 'en',
        music: d['music'] != 'false',
        sfx: d['sfx'] != 'false',
        haptics: d['haptics'] != 'false',
        reducedMotion: d['reducedMotion'] == 'true',
        autoMove: d['autoMove'] == 'true',
      );
    });
    return const AppSettings();
  }

  void update(AppSettings next) {
    state = next;
    LocalStore.instance
      ..saveSetting('language', next.language)
      ..saveSetting('music', next.music)
      ..saveSetting('sfx', next.sfx)
      ..saveSetting('haptics', next.haptics)
      ..saveSetting('reducedMotion', next.reducedMotion)
      ..saveSetting('autoMove', next.autoMove);
  }
}

class AppStrings {
  const AppStrings(this.language);
  final String language;
  String get(String key) =>
      language == 'hi' ? (_hi[key] ?? _en[key] ?? key) : (_en[key] ?? key);
  static const _en = <String, String>{
    'title': 'Ludo Arena',
    'play': 'Play with Friends',
    'computer': 'Play vs Computer',
    'tutorial': 'How to Play',
    'settings': 'Settings',
    'stats': 'Statistics',
    'resume': 'Resume Game',
    'classic': 'Classic',
    'quick': 'Quick',
    'players': 'Players',
    'start': 'Start Match',
    'roll': 'ROLL DICE',
    'pause': 'Pause',
    'home': 'Home',
    'winner': 'Winner!',
    'language': 'Language',
    'music': 'Music',
    'sfx': 'Sound effects',
    'haptics': 'Haptics',
    'reduced': 'Reduced motion',
    'automove': 'Auto-move when only one choice',
    'online': 'Online coming later',
  };
  static const _hi = <String, String>{
    'title': 'लूडो एरीना',
    'play': 'दोस्तों के साथ खेलें',
    'computer': 'कंप्यूटर के विरुद्ध',
    'tutorial': 'कैसे खेलें',
    'settings': 'सेटिंग्स',
    'stats': 'आँकड़े',
    'resume': 'खेल जारी रखें',
    'classic': 'क्लासिक',
    'quick': 'क्विक',
    'players': 'खिलाड़ी',
    'start': 'खेल शुरू करें',
    'roll': 'पासा फेंकें',
    'pause': 'रोकें',
    'home': 'होम',
    'winner': 'विजेता!',
    'language': 'भाषा',
    'music': 'संगीत',
    'sfx': 'ध्वनि प्रभाव',
    'haptics': 'कंपन',
    'reduced': 'कम गति',
    'automove': 'एक चाल हो तो स्वतः चलें',
    'online': 'ऑनलाइन जल्द आ रहा है',
  };
}
