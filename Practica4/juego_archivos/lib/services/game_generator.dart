import 'dart:math';

import '../models/game_models.dart';

class GameGenerator {
  GameGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  GameBoard generate(GameLevel level) {
    final count = level.size * level.size;
    final solution = _route(level);
    final blocked = <int>{};
    while (blocked.length < level.blockedTiles) {
      final index = _random.nextInt(count);
      if (!solution.contains(index)) blocked.add(index);
    }
    final tiles = List.generate(
      count,
      (index) => GameTile(
        index: index,
        value:
            level.minValue +
            _random.nextInt(level.maxValue - level.minValue + 1),
        blocked: blocked.contains(index),
      ),
    );
    final target = solution.fold<int>(
      0,
      (sum, index) => sum + tiles[index].value,
    );
    return GameBoard(
      size: level.size,
      tiles: tiles,
      target: target,
      solution: solution,
    );
  }

  List<int> _route(GameLevel level) {
    final length =
        level.routeLengthMin +
        _random.nextInt(level.routeLengthMax - level.routeLengthMin + 1);
    final route = <int>[_random.nextInt(level.size * level.size)];
    while (route.length < length) {
      final neighbors = adjacent(
        route.last,
        level.size,
      ).where((index) => !route.contains(index)).toList();
      if (neighbors.isEmpty) return _route(level);
      route.add(neighbors[_random.nextInt(neighbors.length)]);
    }
    return route;
  }

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
