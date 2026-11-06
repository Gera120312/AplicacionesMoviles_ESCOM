import '../models/game_models.dart';
import '../models/save_models.dart';

class GameSaveValidator {
  const GameSaveValidator();

  void validate(GameSnapshot snapshot) {
    if (snapshot.schemaVersion != 1) {
      throw const FormatException('Versión de partida no soportada.');
    }
    if (snapshot.id.trim().isEmpty || snapshot.id.length > 120) {
      throw const FormatException('Identificador de partida inválido.');
    }
    if (snapshot.name.trim().isEmpty || snapshot.name.length > 120) {
      throw const FormatException('Nombre de partida inválido.');
    }
    if (snapshot.totalRounds != snapshot.level.rounds ||
        snapshot.round < 1 ||
        snapshot.round > snapshot.totalRounds) {
      throw const FormatException('Ronda inconsistente.');
    }
    if (snapshot.score < 0 ||
        snapshot.elapsedSeconds < 0 ||
        snapshot.remainingSeconds < 0 ||
        snapshot.hints < 0 ||
        snapshot.attempts < 0) {
      throw const FormatException('Estadísticas negativas.');
    }
    final board = snapshot.board;
    if (board.size != snapshot.level.size ||
        board.tiles.length != board.size * board.size ||
        board.solution.isEmpty ||
        board.solution.any(
          (index) => index < 0 || index >= board.tiles.length,
        ) ||
        snapshot.selectedPath.any(
          (index) => index < 0 || index >= board.tiles.length,
        )) {
      throw const FormatException('Tablero incompleto o inconsistente.');
    }
    if (snapshot.selectedPath.toSet().length != snapshot.selectedPath.length) {
      throw const FormatException('La ruta seleccionada contiene repetidos.');
    }
    if (board.solution.toSet().length != board.solution.length ||
        board.tiles.any(
          (tile) => tile.index < 0 || tile.index >= board.tiles.length,
        )) {
      throw const FormatException('Índices de tablero inválidos.');
    }
    for (var index = 1; index < board.solution.length; index++) {
      if (!GameGeneratorAdapter.adjacent(
        board.solution[index - 1],
        board.size,
      ).contains(board.solution[index])) {
        throw const FormatException('La solución no es continua.');
      }
    }
    if (board.solution.any((index) => board.tiles[index].blocked)) {
      throw const FormatException('La solución usa una casilla bloqueada.');
    }
    final solutionSum = board.solution.fold<int>(
      0,
      (sum, index) => sum + board.tiles[index].value,
    );
    if (solutionSum != board.target) {
      throw const FormatException('El objetivo no coincide con la solución.');
    }
    if (snapshot.selectedPath.any((index) => board.tiles[index].blocked)) {
      throw const FormatException('La ruta usa una casilla bloqueada.');
    }
    for (var index = 1; index < snapshot.selectedPath.length; index++) {
      if (!GameGeneratorAdapter.adjacent(
        snapshot.selectedPath[index - 1],
        board.size,
      ).contains(snapshot.selectedPath[index])) {
        throw const FormatException('La ruta seleccionada no es continua.');
      }
    }
    if (snapshot.status == GameStatus.playing &&
        snapshot.remainingSeconds == 0) {
      throw const FormatException('Estado activo con tiempo agotado.');
    }
  }
}

class GameGeneratorAdapter {
  static List<int> adjacent(int index, int size) {
    final row = index ~/ size;
    final column = index % size;
    return <int>[
      if (row > 0) index - size,
      if (row < size - 1) index + size,
      if (column > 0) index - 1,
      if (column < size - 1) index + 1,
    ];
  }
}
