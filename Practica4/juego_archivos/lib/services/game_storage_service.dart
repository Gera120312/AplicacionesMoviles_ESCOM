import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/save_models.dart';
import 'game_save_validator.dart';
import 'game_serialization_service.dart';

class SavedGameFile {
  const SavedGameFile({
    required this.file,
    required this.snapshot,
    required this.format,
  });

  final File file;
  final GameSnapshot snapshot;
  final SaveFormat format;

  String get fileName => file.path.split(Platform.pathSeparator).last;
  int get size => file.lengthSync();
}

class GameStorageService {
  GameStorageService({
    this._rootDirectory,
    GameSerializationService? serialization,
    GameSaveValidator? validator,
  }) : _serialization = serialization ?? const GameSerializationService(),
       _validator = validator ?? const GameSaveValidator();

  final Directory? _rootDirectory;
  final GameSerializationService _serialization;
  final GameSaveValidator _validator;

  Future<Directory> _savesDirectory() async {
    final root = _rootDirectory ?? await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}${Platform.pathSeparator}saves');
    await directory.create(recursive: true);
    return directory;
  }

  Future<Directory> _recoveryDirectory() async {
    final root = _rootDirectory ?? await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}recovery',
    );
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> save(GameSnapshot snapshot, SaveFormat format) async {
    _validator.validate(snapshot);
    final directory = await _savesDirectory();
    final target = File(
      '${directory.path}${Platform.pathSeparator}${_safeId(snapshot.id)}.${format.extensionName}',
    );
    if (await target.exists()) {
      throw const FileSystemException(
        'Ya existe una partida con ese identificador.',
      );
    }
    return _writeAtomically(target, _serialization.encode(snapshot, format));
  }

  Future<File> saveRecovery(GameSnapshot snapshot) async {
    _validator.validate(snapshot);
    final directory = await _recoveryDirectory();
    return _writeAtomically(
      File('${directory.path}${Platform.pathSeparator}autosave.json'),
      _serialization.encode(snapshot, SaveFormat.json),
    );
  }

  Future<bool> hasRecovery() async => (await _recoveryFile()).exists();

  Future<SavedGameFile?> readRecovery() async {
    final file = await _recoveryFile();
    if (!await file.exists()) return null;
    return _readFile(file);
  }

  Future<void> deleteRecovery() async {
    final file = await _recoveryFile();
    if (await file.exists()) await file.delete();
  }

  Future<List<SavedGameFile>> list() async {
    final directory = await _savesDirectory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where(
          (file) => const <String>[
            '.json',
            '.xml',
            '.txt',
          ].contains(_extension(file.path)),
        )
        .toList();
    final result = <SavedGameFile>[];
    for (final file in files) {
      try {
        result.add(await _readFile(file));
      } on FormatException {
        // A corrupt external file should not hide valid saved games.
      }
    }
    return result;
  }

  Future<SavedGameFile> read(File file) => _readFile(file);

  Future<SavedGameFile> importFile(File file) async {
    final content = await file.readAsString();
    final format = _serialization.detect(content);
    final source = _serialization.decode(content, format);
    final snapshot = GameSnapshot(
      id: 'import-${DateTime.now().microsecondsSinceEpoch}',
      schemaVersion: source.schemaVersion,
      name: source.name,
      level: source.level,
      board: source.board,
      selectedPath: source.selectedPath,
      round: source.round,
      totalRounds: source.totalRounds,
      score: source.score,
      elapsedSeconds: source.elapsedSeconds,
      remainingSeconds: source.remainingSeconds,
      status: source.status,
      createdAt: source.createdAt,
      modifiedAt: DateTime.now(),
      settings: source.settings,
      moves: source.moves,
      hints: source.hints,
      attempts: source.attempts,
      category: source.category,
      tags: source.tags,
    );
    final savedFile = await save(snapshot, format);
    return SavedGameFile(file: savedFile, snapshot: snapshot, format: format);
  }

  Future<void> delete(SavedGameFile saved) async {
    if (await saved.file.exists()) await saved.file.delete();
  }

  Future<SavedGameFile> rename(SavedGameFile saved, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 120) {
      throw const FormatException('Nombre inválido.');
    }
    return updateMetadata(saved, name: trimmed);
  }

  Future<SavedGameFile> updateMetadata(
    SavedGameFile saved, {
    String? name,
    SaveCategory? category,
    List<String>? tags,
  }) async {
    final updated = GameSnapshot(
      id: saved.snapshot.id,
      schemaVersion: saved.snapshot.schemaVersion,
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : saved.snapshot.name,
      level: saved.snapshot.level,
      board: saved.snapshot.board,
      selectedPath: saved.snapshot.selectedPath,
      round: saved.snapshot.round,
      totalRounds: saved.snapshot.totalRounds,
      score: saved.snapshot.score,
      elapsedSeconds: saved.snapshot.elapsedSeconds,
      remainingSeconds: saved.snapshot.remainingSeconds,
      status: saved.snapshot.status,
      createdAt: saved.snapshot.createdAt,
      modifiedAt: DateTime.now(),
      settings: saved.snapshot.settings,
      moves: saved.snapshot.moves,
      hints: saved.snapshot.hints,
      attempts: saved.snapshot.attempts,
      category: category ?? saved.snapshot.category,
      tags: tags ?? saved.snapshot.tags,
    );
    await _writeAtomically(
      saved.file,
      _serialization.encode(updated, saved.format),
    );
    return SavedGameFile(
      file: saved.file,
      snapshot: updated,
      format: saved.format,
    );
  }

  Future<SavedGameFile> _readFile(File file) async {
    final content = await file.readAsString();
    final format = _formatFromExtension(file.path);
    final snapshot = _serialization.decode(content, format);
    _validator.validate(snapshot);
    return SavedGameFile(file: file, snapshot: snapshot, format: format);
  }

  Future<File> _recoveryFile() async {
    final directory = await _recoveryDirectory();
    return File('${directory.path}${Platform.pathSeparator}autosave.json');
  }

  Future<File> _writeAtomically(File target, String content) async {
    final temporary = File('${target.path}.tmp');
    try {
      await temporary.writeAsString(content, flush: true);
      return await temporary.rename(target.path);
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
  }

  String _safeId(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  String _extension(String path) =>
      path.substring(path.lastIndexOf('.')).toLowerCase();

  SaveFormat _formatFromExtension(String path) =>
      SaveFormatX.fromName(_extension(path).substring(1));
}
