import 'game_models.dart';

enum SaveFormat { txt, json, xml }

enum SaveCategory { practice, bestScore, pending, completed }

extension SaveFormatX on SaveFormat {
  String get extensionName => name;

  String get label => switch (this) {
    SaveFormat.txt => 'TXT',
    SaveFormat.json => 'JSON',
    SaveFormat.xml => 'XML',
  };

  static SaveFormat fromName(String value) => SaveFormat.values.firstWhere(
    (format) => format.name == value.toLowerCase(),
    orElse: () => throw const FormatException('Formato no soportado.'),
  );
}

extension SaveCategoryX on SaveCategory {
  String get label => switch (this) {
    SaveCategory.practice => 'Práctica',
    SaveCategory.bestScore => 'Mejor puntuación',
    SaveCategory.pending => 'Pendiente',
    SaveCategory.completed => 'Completada',
  };
}

class SaveSettings {
  const SaveSettings({
    required this.accent,
    required this.brightness,
    required this.sounds,
    required this.animations,
  });

  final String accent;
  final String brightness;
  final bool sounds;
  final bool animations;

  Map<String, Object> toMap() => <String, Object>{
    'accent': accent,
    'brightness': brightness,
    'sounds': sounds,
    'animations': animations,
  };

  factory SaveSettings.fromMap(Map<String, Object?> map) => SaveSettings(
    accent: _string(map, 'accent'),
    brightness: _string(map, 'brightness'),
    sounds: _bool(map, 'sounds'),
    animations: _bool(map, 'animations'),
  );
}

class GameSnapshot {
  const GameSnapshot({
    required this.id,
    required this.schemaVersion,
    required this.name,
    required this.level,
    required this.board,
    required this.selectedPath,
    required this.round,
    required this.totalRounds,
    required this.score,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.status,
    required this.createdAt,
    required this.modifiedAt,
    required this.settings,
    required this.moves,
    required this.hints,
    required this.attempts,
    required this.category,
    required this.tags,
  });

  final String id;
  final int schemaVersion;
  final String name;
  final GameBoard board;
  final GameLevel level;
  final List<int> selectedPath;
  final int round;
  final int totalRounds;
  final int score;
  final int elapsedSeconds;
  final int remainingSeconds;
  final GameStatus status;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final SaveSettings settings;
  final List<GameMove> moves;
  final int hints;
  final int attempts;
  final SaveCategory category;
  final List<String> tags;

  Map<String, Object> toMap() => <String, Object>{
    'schemaVersion': schemaVersion,
    'app': 'ruta_de_sumas',
    'id': id,
    'name': name,
    'level': level.difficulty.name,
    'round': round,
    'totalRounds': totalRounds,
    'score': score,
    'elapsedSeconds': elapsedSeconds,
    'remainingSeconds': remainingSeconds,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'hints': hints,
    'attempts': attempts,
    'category': category.name,
    'tags': tags,
    'board': <String, Object>{
      'size': board.size,
      'target': board.target,
      'solution': board.solution,
      'tiles': board.tiles
          .map(
            (tile) => <String, Object>{
              'index': tile.index,
              'value': tile.value,
              'blocked': tile.blocked,
            },
          )
          .toList(),
    },
    'selectedPath': selectedPath,
    'settings': settings.toMap(),
    'moveHistory': moves
        .map(
          (move) => <String, Object?>{
            'type': move.type.name,
            'order': move.order,
            'tileIndex': move.tileIndex,
            'points': move.points,
          },
        )
        .toList(),
  };

  factory GameSnapshot.fromMap(Map<String, Object?> map) {
    if (map['app'] != 'ruta_de_sumas') {
      throw const FormatException('El archivo no pertenece a Ruta de Sumas.');
    }
    final difficulty = Difficulty.values.firstWhere(
      (value) => value.name == _string(map, 'level'),
      orElse: () => throw const FormatException('Nivel desconocido.'),
    );
    final level = difficulty == Difficulty.basic
        ? GameLevel.basic
        : GameLevel.advanced;
    final boardMap = _map(map, 'board');
    final tileMaps = _list(boardMap, 'tiles');
    final tiles = tileMaps.map((item) {
      final tile = _asMap(item);
      return GameTile(
        index: _int(tile, 'index'),
        value: _int(tile, 'value'),
        blocked: _bool(tile, 'blocked'),
      );
    }).toList();
    final moveMaps = _list(map, 'moveHistory');
    final moves = moveMaps.map((item) {
      final move = _asMap(item);
      final type = MoveType.values.firstWhere(
        (value) => value.name == _string(move, 'type'),
        orElse: () => throw const FormatException('Movimiento desconocido.'),
      );
      return GameMove(
        type: type,
        order: _int(move, 'order'),
        tileIndex: move['tileIndex'] == null ? null : _int(move, 'tileIndex'),
        points: move['points'] == null ? null : _int(move, 'points'),
      );
    }).toList();
    return GameSnapshot(
      id: _string(map, 'id'),
      schemaVersion: _int(map, 'schemaVersion'),
      name: _string(map, 'name'),
      level: level,
      board: GameBoard(
        size: _int(boardMap, 'size'),
        target: _int(boardMap, 'target'),
        solution: _intList(boardMap, 'solution'),
        tiles: tiles,
      ),
      selectedPath: _intList(map, 'selectedPath'),
      round: _int(map, 'round'),
      totalRounds: _int(map, 'totalRounds'),
      score: _int(map, 'score'),
      elapsedSeconds: _int(map, 'elapsedSeconds'),
      remainingSeconds: _int(map, 'remainingSeconds'),
      status: GameStatus.values.firstWhere(
        (value) => value.name == _string(map, 'status'),
        orElse: () => throw const FormatException('Estado desconocido.'),
      ),
      createdAt: DateTime.parse(_string(map, 'createdAt')),
      modifiedAt: DateTime.parse(_string(map, 'modifiedAt')),
      settings: SaveSettings.fromMap(_map(map, 'settings')),
      moves: moves,
      hints: _int(map, 'hints'),
      attempts: _int(map, 'attempts'),
      category: SaveCategory.values.firstWhere(
        (value) => value.name == _string(map, 'category'),
        orElse: () => throw const FormatException('Categoría desconocida.'),
      ),
      tags: _stringList(map, 'tags'),
    );
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  throw const FormatException('Se esperaba un objeto.');
}

String _string(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Campo "$key" inválido.');
  }
  return value;
}

int _int(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! int) throw FormatException('Campo "$key" inválido.');
  return value;
}

bool _bool(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! bool) throw FormatException('Campo "$key" inválido.');
  return value;
}

Map<String, Object?> _map(Map<String, Object?> map, String key) {
  final value = map[key];
  return _asMap(value);
}

List<Object?> _list(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! List) throw FormatException('Campo "$key" inválido.');
  return value.cast<Object?>();
}

List<int> _intList(Map<String, Object?> map, String key) {
  final values = _list(map, key);
  if (values.any((value) => value is! int)) {
    throw FormatException('Campo "$key" inválido.');
  }
  return values.cast<int>();
}

List<String> _stringList(Map<String, Object?> map, String key) {
  final values = _list(map, key);
  if (values.any((value) => value is! String)) {
    throw FormatException('Campo "$key" inválido.');
  }
  return values.cast<String>();
}
