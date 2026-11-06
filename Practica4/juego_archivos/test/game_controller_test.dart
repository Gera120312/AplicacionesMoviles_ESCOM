import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:juego_archivos/controllers/game_controller.dart';
import 'package:juego_archivos/models/game_models.dart';
import 'package:juego_archivos/services/game_generator.dart';

void main() {
  group('GameGenerator', () {
    test('genera tableros reproducibles con una solución alcanzable', () {
      final first = GameGenerator(random: Random(7)).generate(GameLevel.basic);
      final second = GameGenerator(random: Random(7)).generate(GameLevel.basic);

      expect(
        first.tiles.map((tile) => tile.value).toList(),
        second.tiles.map((tile) => tile.value).toList(),
      );
      expect(first.solution, second.solution);
      expect(
        first.solution
            .map((index) => first.tiles[index].value)
            .reduce((a, b) => a + b),
        first.target,
      );
      for (var i = 1; i < first.solution.length; i++) {
        expect(
          GameGenerator.adjacent(first.solution[i - 1], first.size),
          contains(first.solution[i]),
        );
      }
    });

    test('mantiene bloqueadas cinco casillas fuera de la solución', () {
      final board = GameGenerator(random: Random(3))
          .generate(GameLevel.advanced);

      expect(board.tiles.where((tile) => tile.blocked), hasLength(5));
      expect(
        board.solution.every((index) => !board.tiles[index].blocked),
        isTrue,
      );
    });
  });

  group('GameController', () {
    test('valida una ruta, suma puntos y avanza la ronda', () {
      final controller = GameController(
        level: GameLevel.basic,
        soundsEnabled: false,
        animationsEnabled: false,
        seed: 11,
      );
      addTearDown(controller.dispose);

      for (final index in controller.board.solution) {
        controller.select(index);
      }

      expect(controller.check(), isTrue);
      expect(controller.score, greaterThan(100));
      expect(controller.round, 2);
      expect(controller.attempts, 1);
      expect(controller.moves.last.type, MoveType.roundCompleted);
    });

    test('penaliza rutas incorrectas y permite deshacer y limpiar', () {
      final controller = GameController(
        level: GameLevel.basic,
        soundsEnabled: false,
        animationsEnabled: false,
        seed: 11,
      );
      addTearDown(controller.dispose);

      controller.select(controller.board.solution.first);
      final neighbor = GameGenerator.adjacent(
        controller.board.solution.first,
        controller.level.size,
      ).first;
      controller.select(neighbor);
      controller.undo();
      expect(controller.selected, hasLength(1));
      controller.clearRoute();
      expect(controller.selected, isEmpty);
      expect(controller.check(), isFalse);
      expect(controller.score, 0);
      expect(controller.feedback, contains('incorrecta'));
    });

    test('aplica la penalización de pista y pausa el temporizador', () {
      final controller = GameController(
        level: GameLevel.basic,
        soundsEnabled: false,
        animationsEnabled: false,
        seed: 11,
      );
      addTearDown(controller.dispose);

      controller.hint();
      expect(controller.hints, 1);
      expect(controller.score, 0);
      expect(controller.highlightedHint, controller.board.solution.first);

      controller.pause();
      expect(controller.status, GameStatus.paused);
      controller.resume();
      expect(controller.status, GameStatus.playing);
    });
  });
}
