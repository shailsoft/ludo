import 'dart:convert';

enum PlayerColor { red, green, yellow, blue }

enum PlayerType { human, bot }

enum BotDifficulty { easy, medium, hard }

enum GamePhase { waitingForRoll, waitingForMove, finished }

enum GameEventType {
  rolled,
  tokenEntered,
  tokenMoved,
  captured,
  reachedHome,
  noLegalMove,
  thirdSixForfeited,
  turnChanged,
  matchFinished,
}

class RuleProfile {
  const RuleProfile({
    required this.id,
    required this.tokensPerPlayer,
    required this.openingRolls,
    this.extraTurnOnSix = true,
    this.penalizeThirdSix = true,
    this.extraTurnOnCapture = false,
    this.extraTurnOnHome = false,
    this.safeSquares = const {0, 8, 13, 21, 26, 34, 39, 47},
  });

  static const classic = RuleProfile(
    id: 'classic',
    tokensPerPlayer: 4,
    openingRolls: {6},
  );
  static const quick = RuleProfile(
    id: 'quick',
    tokensPerPlayer: 2,
    openingRolls: {6},
  );

  final String id;
  final int tokensPerPlayer;
  final Set<int> openingRolls;
  final bool extraTurnOnSix;
  final bool penalizeThirdSix;
  final bool extraTurnOnCapture;
  final bool extraTurnOnHome;
  final Set<int> safeSquares;

  Map<String, Object?> toJson() => {
    'id': id,
    'tokensPerPlayer': tokensPerPlayer,
    'openingRolls': openingRolls.toList()..sort(),
    'extraTurnOnSix': extraTurnOnSix,
    'penalizeThirdSix': penalizeThirdSix,
    'extraTurnOnCapture': extraTurnOnCapture,
    'extraTurnOnHome': extraTurnOnHome,
    'safeSquares': safeSquares.toList()..sort(),
  };

  factory RuleProfile.fromJson(Map<String, Object?> json) => RuleProfile(
    id: json['id']! as String,
    tokensPerPlayer: json['tokensPerPlayer']! as int,
    openingRolls: Set<int>.from(json['openingRolls']! as List),
    extraTurnOnSix: json['extraTurnOnSix']! as bool,
    penalizeThirdSix: json['penalizeThirdSix']! as bool,
    extraTurnOnCapture: json['extraTurnOnCapture']! as bool,
    extraTurnOnHome: json['extraTurnOnHome']! as bool,
    safeSquares: Set<int>.from(json['safeSquares']! as List),
  );
}

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.type = PlayerType.human,
    this.difficulty = BotDifficulty.medium,
  });
  final String id;
  final String name;
  final PlayerColor color;
  final PlayerType type;
  final BotDifficulty difficulty;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color.name,
    'type': type.name,
    'difficulty': difficulty.name,
  };
  factory Player.fromJson(Map<String, Object?> json) => Player(
    id: json['id']! as String,
    name: json['name']! as String,
    color: PlayerColor.values.byName(json['color']! as String),
    type: PlayerType.values.byName(json['type']! as String),
    difficulty: BotDifficulty.values.byName(json['difficulty']! as String),
  );
}

class Token {
  const Token({required this.id, required this.playerId, this.steps = -1});
  final String id;
  final String playerId;
  final int steps;
  bool get isInYard => steps == -1;
  bool get isOnTrack => steps >= 0 && steps < 52;
  bool get isInHomeLane => steps >= 52 && steps < 57;
  bool get isFinished => steps == 57;
  Token copyWith({int? steps}) =>
      Token(id: id, playerId: playerId, steps: steps ?? this.steps);
  Map<String, Object?> toJson() => {
    'id': id,
    'playerId': playerId,
    'steps': steps,
  };
  factory Token.fromJson(Map<String, Object?> json) => Token(
    id: json['id']! as String,
    playerId: json['playerId']! as String,
    steps: json['steps']! as int,
  );
}

class GameState {
  const GameState({
    required this.gameId,
    required this.players,
    required this.tokens,
    required this.rules,
    this.activePlayerIndex = 0,
    this.phase = GamePhase.waitingForRoll,
    this.pendingRoll,
    this.consecutiveSixes = 0,
    this.winnerPlayerId,
    this.revision = 0,
    this.createdAtUtc,
  });

  factory GameState.newGame({
    required String gameId,
    required List<Player> players,
    RuleProfile rules = RuleProfile.classic,
    int openingPlayerIndex = 0,
    DateTime? createdAtUtc,
  }) {
    if (players.length < 2 || players.length > 4) {
      throw ArgumentError.value(
        players.length,
        'players',
        'must contain 2–4 players',
      );
    }
    if (players.map((p) => p.id).toSet().length != players.length ||
        players.map((p) => p.color).toSet().length != players.length) {
      throw ArgumentError('Player IDs and colors must be unique.');
    }
    if (openingPlayerIndex < 0 || openingPlayerIndex >= players.length) {
      throw RangeError.index(openingPlayerIndex, players, 'openingPlayerIndex');
    }
    return GameState(
      gameId: gameId,
      players: List.unmodifiable(players),
      tokens: List.unmodifiable([
        for (final player in players)
          for (var i = 0; i < rules.tokensPerPlayer; i++)
            Token(id: '${player.id}-t$i', playerId: player.id),
      ]),
      rules: rules,
      activePlayerIndex: openingPlayerIndex,
      createdAtUtc: (createdAtUtc ?? DateTime.now().toUtc()).toUtc(),
    );
  }

  final String gameId;
  final List<Player> players;
  final List<Token> tokens;
  final RuleProfile rules;
  final int activePlayerIndex;
  final GamePhase phase;
  final int? pendingRoll;
  final int consecutiveSixes;
  final String? winnerPlayerId;
  final int revision;
  final DateTime? createdAtUtc;
  Player get activePlayer => players[activePlayerIndex];
  List<Token> tokensFor(String playerId) =>
      tokens.where((t) => t.playerId == playerId).toList(growable: false);

  GameState copyWith({
    List<Token>? tokens,
    int? activePlayerIndex,
    GamePhase? phase,
    int? pendingRoll,
    bool clearPendingRoll = false,
    int? consecutiveSixes,
    String? winnerPlayerId,
    int? revision,
  }) => GameState(
    gameId: gameId,
    players: players,
    tokens: List.unmodifiable(tokens ?? this.tokens),
    rules: rules,
    activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
    phase: phase ?? this.phase,
    pendingRoll: clearPendingRoll ? null : (pendingRoll ?? this.pendingRoll),
    consecutiveSixes: consecutiveSixes ?? this.consecutiveSixes,
    winnerPlayerId: winnerPlayerId ?? this.winnerPlayerId,
    revision: revision ?? this.revision,
    createdAtUtc: createdAtUtc,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'gameId': gameId,
    'players': players.map((p) => p.toJson()).toList(),
    'tokens': tokens.map((t) => t.toJson()).toList(),
    'rules': rules.toJson(),
    'activePlayerIndex': activePlayerIndex,
    'phase': phase.name,
    'pendingRoll': pendingRoll,
    'consecutiveSixes': consecutiveSixes,
    'winnerPlayerId': winnerPlayerId,
    'revision': revision,
    'createdAtUtc': createdAtUtc?.toIso8601String(),
  };
  String encode() => jsonEncode(toJson());
  factory GameState.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Unsupported saved-game schema.');
    }
    return GameState(
      gameId: json['gameId']! as String,
      players: (json['players']! as List)
          .map((e) => Player.fromJson(Map<String, Object?>.from(e as Map)))
          .toList(),
      tokens: (json['tokens']! as List)
          .map((e) => Token.fromJson(Map<String, Object?>.from(e as Map)))
          .toList(),
      rules: RuleProfile.fromJson(
        Map<String, Object?>.from(json['rules']! as Map),
      ),
      activePlayerIndex: json['activePlayerIndex']! as int,
      phase: GamePhase.values.byName(json['phase']! as String),
      pendingRoll: json['pendingRoll'] as int?,
      consecutiveSixes: json['consecutiveSixes']! as int,
      winnerPlayerId: json['winnerPlayerId'] as String?,
      revision: json['revision']! as int,
      createdAtUtc: json['createdAtUtc'] == null
          ? null
          : DateTime.parse(json['createdAtUtc']! as String).toUtc(),
    );
  }
  factory GameState.decode(String encoded) =>
      GameState.fromJson(Map<String, Object?>.from(jsonDecode(encoded) as Map));
}

sealed class GameAction {
  const GameAction(this.playerId);
  final String playerId;
}

class RollDice extends GameAction {
  const RollDice(super.playerId, this.value);
  final int value;
}

class MoveToken extends GameAction {
  const MoveToken(super.playerId, this.tokenId);
  final String tokenId;
}

class GameEvent {
  const GameEvent(this.type, {this.playerId, this.tokenId, this.value});
  final GameEventType type;
  final String? playerId;
  final String? tokenId;
  final int? value;
}

class TransitionResult {
  const TransitionResult(this.state, this.events);
  final GameState state;
  final List<GameEvent> events;
}

class InvalidGameAction implements Exception {
  const InvalidGameAction(this.message);
  final String message;
  @override
  String toString() => 'InvalidGameAction: $message';
}
