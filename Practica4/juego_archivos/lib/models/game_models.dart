enum Difficulty { basic, advanced }

enum GameStatus { playing, paused, won, lost }

enum MoveType { select, undo, clear, correct, incorrect, hint, roundCompleted }

class GameLevel {
  const GameLevel({
    required this.difficulty,
    required this.name,
    required this.size,
    required this.minValue,
    required this.maxValue,
    required this.routeLengthMin,
    required this.routeLengthMax,
    required this.rounds,
    required this.seconds,
    required this.blockedTiles,
  });

  final Difficulty difficulty;
  final String name;
  final int size;
  final int minValue;
  final int maxValue;
  final int routeLengthMin;
  final int routeLengthMax;
  final int rounds;
  final int seconds;
  final int blockedTiles;

  static const basic = GameLevel(
    difficulty: Difficulty.basic,
    name: 'Básico',
    size: 4,
    minValue: 1,
    maxValue: 9,
    routeLengthMin: 2,
    routeLengthMax: 3,
    rounds: 5,
    seconds: 120,
    blockedTiles: 0,
  );
  static const advanced = GameLevel(
    difficulty: Difficulty.advanced,
    name: 'Avanzado',
    size: 5,
    minValue: 1,
    maxValue: 15,
    routeLengthMin: 3,
    routeLengthMax: 4,
    rounds: 8,
    seconds: 180,
    blockedTiles: 5,
  );
}

class GameTile {
  const GameTile({
    required this.index,
    required this.value,
    this.blocked = false,
  });

  final int index;
  final int value;
  final bool blocked;
}

class GameMove {
  const GameMove({
    required this.type,
    required this.order,
    this.tileIndex,
    this.points,
  });

  final MoveType type;
  final int order;
  final int? tileIndex;
  final int? points;
}

class GameBoard {
  const GameBoard({
    required this.size,
    required this.tiles,
    required this.target,
    required this.solution,
  });

  final int size;
  final List<GameTile> tiles;
  final int target;
  final List<int> solution;
}

class GameResult {
  const GameResult({
    required this.won,
    required this.level,
    required this.score,
    required this.elapsedSeconds,
    required this.roundsCompleted,
    required this.attempts,
    required this.hints,
  });

  final bool won;
  final GameLevel level;
  final int score;
  final int elapsedSeconds;
  final int roundsCompleted;
  final int attempts;
  final int hints;
}
