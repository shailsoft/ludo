import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../game_core/game_core.dart';

class LocalStore {
  LocalStore._();
  static final instance = LocalStore._();
  Database? _db;

  Future<void> open() async {
    final root = await getDatabasesPath();
    _db = await openDatabase(
      path.join(root, 'ludo_arena.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE saved_match (slot INTEGER PRIMARY KEY CHECK(slot=1), payload TEXT NOT NULL, updated_utc TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE stats (key TEXT PRIMARY KEY, value INTEGER NOT NULL)',
        );
      },
    );
  }

  Future<void> saveGame(GameState state) async => _db!.insert('saved_match', {
    'slot': 1,
    'payload': state.encode(),
    'updated_utc': DateTime.now().toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.replace);
  Future<GameState?> loadGame() async {
    final rows = await _db!.query('saved_match', where: 'slot = 1');
    if (rows.isEmpty) return null;
    try {
      return GameState.decode(rows.single['payload']! as String);
    } on FormatException {
      return null;
    }
  }

  Future<void> clearGame() => _db!.delete('saved_match', where: 'slot = 1');
  Future<bool> hasSavedGame() async =>
      (await _db!.query('saved_match', columns: ['slot'], limit: 1)).isNotEmpty;
  Future<Map<String, String>> loadSettings() async => {
    for (final row in await _db!.query('settings'))
      row['key']! as String: row['value']! as String,
  };
  Future<void> saveSetting(String key, Object value) => _db!.insert(
    'settings',
    {'key': key, 'value': '$value'},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  Future<void> recordResult({required bool won, required int moves}) async {
    for (final entry in {
      'matches': 1,
      if (won) 'wins': 1,
      if (!won) 'losses': 1,
      'moves': moves,
    }.entries) {
      await _db!.rawInsert(
        'INSERT INTO stats(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=value+?',
        [entry.key, entry.value, entry.value],
      );
    }
  }

  Future<Map<String, int>> stats() async => {
    for (final row in await _db!.query('stats'))
      row['key']! as String: row['value']! as int,
  };
}
