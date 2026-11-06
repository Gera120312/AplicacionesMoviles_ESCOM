import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:juego_archivos/controllers/game_controller.dart';
import 'package:juego_archivos/models/game_models.dart';
import 'package:juego_archivos/models/save_models.dart';
import 'package:juego_archivos/services/game_save_validator.dart';
import 'package:juego_archivos/services/game_serialization_service.dart';
import 'package:juego_archivos/services/game_storage_service.dart';

void main() {
  late GameSnapshot snapshot;
  const serializer = GameSerializationService();

  setUp(() {
    final controller = GameController(
      level: GameLevel.advanced,
      soundsEnabled: false,
      animationsEnabled: false,
      seed: 21,
    );
    controller.select(controller.board.solution.first);
    controller.pause();
    snapshot = controller.snapshot(
      id: 'test-save',
      name: 'Nombre | con símbolos',
      settings: const SaveSettings(
        accent: 'azul',
        brightness: 'dark',
        sounds: false,
        animations: true,
      ),
      category: SaveCategory.pending,
      tags: const <String>['avance', 'prueba'],
    );
    controller.dispose();
  });

  for (final format in SaveFormat.values) {
    test('conserva el estado al serializar ${format.label}', () {
      final content = serializer.encode(snapshot, format);
      final restored = serializer.decode(content, format);

      expect(restored.id, snapshot.id);
      expect(restored.name, snapshot.name);
      expect(restored.level.difficulty, snapshot.level.difficulty);
      expect(restored.board.target, snapshot.board.target);
      expect(restored.board.tiles.length, snapshot.board.tiles.length);
      expect(
        restored.board.tiles.map((tile) => tile.value).toList(),
        snapshot.board.tiles.map((tile) => tile.value).toList(),
      );
      expect(restored.board.solution, snapshot.board.solution);
      expect(restored.selectedPath, snapshot.selectedPath);
      expect(restored.score, snapshot.score);
      expect(restored.remainingSeconds, snapshot.remainingSeconds);
      expect(restored.status, GameStatus.paused);
      expect(restored.settings.toMap(), snapshot.settings.toMap());
      expect(restored.moves.length, snapshot.moves.length);
      expect(restored.category, SaveCategory.pending);
      expect(restored.tags, snapshot.tags);
    });
  }

  test('rechaza contenido vacío y corrupto', () {
    expect(
      () => serializer.decode('', SaveFormat.json),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => serializer.decode('{not-json', SaveFormat.json),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => serializer.decode('<gameSave>', SaveFormat.xml),
      throwsA(isA<FormatException>()),
    );
  });

  test('persiste archivos privados y evita sobrescritura', () async {
    final root = await Directory.systemTemp.createTemp('ruta_de_sumas_test_');
    addTearDown(() => root.delete(recursive: true));
    final storage = GameStorageService(rootDirectory: root);

    await storage.save(snapshot, SaveFormat.json);
    final files = await storage.list();
    expect(files, hasLength(1));
    expect(files.single.snapshot.name, snapshot.name);
    expect(
      () => storage.save(snapshot, SaveFormat.json),
      throwsA(isA<FileSystemException>()),
    );

    await storage.saveRecovery(snapshot);
    final recovery = await storage.readRecovery();
    expect(recovery?.snapshot.selectedPath, snapshot.selectedPath);
    await storage.deleteRecovery();
    expect(await storage.hasRecovery(), isFalse);
  });

  test('valida versiones incompatibles', () {
    final invalid = GameSnapshot(
      id: snapshot.id,
      schemaVersion: 2,
      name: snapshot.name,
      level: snapshot.level,
      board: snapshot.board,
      selectedPath: snapshot.selectedPath,
      round: snapshot.round,
      totalRounds: snapshot.totalRounds,
      score: snapshot.score,
      elapsedSeconds: snapshot.elapsedSeconds,
      remainingSeconds: snapshot.remainingSeconds,
      status: snapshot.status,
      createdAt: snapshot.createdAt,
      modifiedAt: snapshot.modifiedAt,
      settings: snapshot.settings,
      moves: snapshot.moves,
      hints: snapshot.hints,
      attempts: snapshot.attempts,
      category: snapshot.category,
      tags: snapshot.tags,
    );
    expect(
      () => const GameSaveValidator().validate(invalid),
      throwsA(isA<FormatException>()),
    );
  });

  test('restaura una partida pausada sin generar otro tablero', () {
    final controller = GameController(
      level: snapshot.level,
      soundsEnabled: false,
      animationsEnabled: false,
      snapshot: snapshot,
    );
    addTearDown(controller.dispose);

    expect(controller.status, GameStatus.paused);
    expect(controller.board.target, snapshot.board.target);
    expect(controller.board.solution, snapshot.board.solution);
    expect(controller.selected, snapshot.selectedPath);
    expect(controller.remainingSeconds, snapshot.remainingSeconds);
  });
}
