import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import '../models/file_entry.dart';

abstract interface class FileStorageService {
  Future<FileEntry> privateRoot();
  Future<List<FileEntry>> listDirectory(FileEntry directory);
  Future<FileEntry?> pickFile();
  Future<FileEntry?> pickDirectory();
  Future<Uint8List> readBytes(FileEntry entry);
  Future<void> createDirectory(FileEntry parent, String name);
  Future<void> importFile(FileEntry parent, FileEntry selected);
  Future<bool> isAccessible(FileEntry entry);
  Future<FileEntry> copy(FileEntry source, FileEntry destinationDirectory);
  Future<FileEntry> move(FileEntry source, FileEntry destinationDirectory);
  Future<FileEntry> rename(FileEntry entry, String newName);
  Future<void> delete(FileEntry entry);
}

class FileStorageException implements Exception {
  const FileStorageException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class LocalFileStorageService implements FileStorageService {
  LocalFileStorageService({this._privateDirectory});

  static const MethodChannel _authorizedChannel = MethodChannel(
    'mx.ipn.escom/authorized_documents',
  );

  Directory? _privateDirectory;

  Future<Directory> _documentsDirectory() async {
    return _privateDirectory ??= await getApplicationDocumentsDirectory();
  }

  @override
  Future<FileEntry> privateRoot() async {
    final directory = await _documentsDirectory();
    return _entryForDirectory(directory, FileSource.privateStorage);
  }

  @override
  Future<List<FileEntry>> listDirectory(FileEntry directory) async {
    if (_isAuthorizedUri(directory.path)) {
      try {
        final items = await _authorizedChannel
            .invokeListMethod<Map<Object?, Object?>>(
              'listDirectory',
              <String, Object>{'uri': directory.path},
            );
        return (items ?? <Map<Object?, Object?>>[]).map((item) {
          final map = Map<String, Object?>.fromEntries(
            item.entries.map((entry) => MapEntry('${entry.key}', entry.value)),
          );
          final modifiedMillis = map['modified'] as int?;
          return FileEntry(
            name: map['name'] as String? ?? 'Sin nombre',
            type: fileTypeForName(
              map['name'] as String? ?? 'Sin nombre',
              isDirectory: map['isDirectory'] as bool? ?? false,
            ),
            path: map['uri'] as String? ?? '',
            source: FileSource.externalDirectory,
            size: map['size'] as int?,
            modified: modifiedMillis == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(modifiedMillis),
            parentPath: directory.path,
            mimeType: map['mimeType'] as String?,
          );
        }).toList();
      } on PlatformException catch (error) {
        throw FileStorageException(
          error.message ?? 'No se pudo leer la carpeta autorizada.',
          cause: error,
        );
      }
    }
    final target = _directoryFor(directory);
    if (target == null) {
      throw const FileStorageException(
        'Esta carpeta usa un identificador externo que no está disponible como ruta local.',
      );
    }
    try {
      final entries = <FileEntry>[];
      await for (final entity in target.list(followLinks: false)) {
        final stat = await entity.stat();
        final isDirectory = entity is Directory;
        entries.add(
          FileEntry(
            name: _nameOf(entity.path),
            type: fileTypeForName(
              _nameOf(entity.path),
              isDirectory: isDirectory,
            ),
            path: entity.path,
            source: directory.source,
            size: isDirectory ? null : stat.size,
            modified: stat.modified,
            created: stat.changed,
            parentPath: target.path,
            mimeType: isDirectory ? null : lookupMimeType(entity.path),
          ),
        );
      }
      return entries;
    } on FileSystemException catch (error) {
      throw FileStorageException('No se pudo leer la carpeta.', cause: error);
    }
  }

  @override
  Future<FileEntry?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final path = file.path;
    if (path == null && file.bytes == null) {
      throw const FileStorageException(
        'El selector no proporcionó una referencia legible al documento.',
      );
    }
    final bytes = file.bytes ?? await _readPath(path!);
    return FileEntry(
      name: file.name,
      type: fileTypeForName(file.name),
      path: path ?? 'selected://${file.name}',
      source: FileSource.externalFile,
      size: file.size,
      bytes: bytes,
      mimeType: lookupMimeType(file.name),
    );
  }

  @override
  Future<FileEntry?> pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return null;
    if (path.startsWith('content://')) {
      return FileEntry(
        name: _nameOf(path),
        type: FileEntryType.folder,
        path: path,
        source: FileSource.externalDirectory,
      );
    }
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw const FileStorageException(
        'La carpeta seleccionada ya no está disponible.',
      );
    }
    return _entryForDirectory(directory, FileSource.externalDirectory);
  }

  @override
  Future<Uint8List> readBytes(FileEntry entry) async {
    if (entry.bytes != null) return entry.bytes!;
    if (_isAuthorizedUri(entry.path)) {
      try {
        final bytes = await _authorizedChannel.invokeMethod<Uint8List>(
          'readBytes',
          <String, Object>{'uri': entry.path},
        );
        if (bytes == null) {
          throw const FileStorageException('El proveedor no devolvió datos.');
        }
        return bytes;
      } on PlatformException catch (error) {
        throw FileStorageException(
          error.message ?? 'No se pudo leer el documento autorizado.',
          cause: error,
        );
      }
    }
    final file = _fileFor(entry);
    if (file == null) {
      throw const FileStorageException(
        'No es posible leer este documento externo sin su URI autorizada.',
      );
    }
    try {
      return await file.readAsBytes();
    } on FileSystemException catch (error) {
      throw FileStorageException('No se pudo leer el archivo.', cause: error);
    }
  }

  @override
  Future<void> createDirectory(FileEntry parent, String name) async {
    if (_isAuthorizedUri(parent.path)) {
      await _invokeAuthorized('createDirectory', <String, Object>{
        'uri': parent.path,
        'name': name,
      });
      return;
    }
    final directory = _directoryFor(parent);
    if (directory == null) {
      throw const FileStorageException('La carpeta actual no es accesible.');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.contains(RegExp(r'[\\/:*?"<>|]'))) {
      throw const FileStorageException('El nombre de la carpeta no es válido.');
    }
    try {
      await Directory('${directory.path}${Platform.pathSeparator}$trimmed')
          .create();
    } on FileSystemException catch (error) {
      throw FileStorageException('No se pudo crear la carpeta.', cause: error);
    }
  }

  @override
  Future<void> importFile(FileEntry parent, FileEntry selected) async {
    if (_isAuthorizedUri(parent.path)) {
      if (_isAuthorizedUri(selected.path)) {
        await _invokeAuthorized('copy', <String, Object>{
          'sourceUri': selected.path,
          'destinationUri': parent.path,
          'name': selected.name,
        });
      } else {
        await _invokeAuthorized('writeBytes', <String, Object>{
          'destinationUri': parent.path,
          'name': selected.name,
          'bytes': await readBytes(selected),
        });
      }
      return;
    }
    final directory = _directoryFor(parent);
    if (directory == null) {
      throw const FileStorageException('La carpeta actual no es accesible.');
    }
    final destination = File(
      '${directory.path}${Platform.pathSeparator}${selected.name}',
    );
    try {
      await destination.writeAsBytes(await readBytes(selected));
    } on FileSystemException catch (error) {
      throw FileStorageException(
        'No se pudo importar el archivo.',
        cause: error,
      );
    }
  }

  @override
  Future<bool> isAccessible(FileEntry entry) async {
    if (entry.bytes != null) return true;
    if (_isAuthorizedUri(entry.path)) {
      try {
        return await _authorizedChannel.invokeMethod<bool>(
              'isAccessible',
              <String, Object>{'uri': entry.path},
            ) ??
            false;
      } on PlatformException {
        return false;
      }
    }
    final file = _fileFor(entry);
    return file != null && await file.exists();
  }

  @override
  Future<FileEntry> copy(
    FileEntry source,
    FileEntry destinationDirectory,
  ) async {
    if (_isAuthorizedUri(source.path) &&
        _isAuthorizedUri(destinationDirectory.path)) {
      await _invokeAuthorized('copy', <String, Object>{
        'sourceUri': source.path,
        'destinationUri': destinationDirectory.path,
        'name': source.name,
      });
      return source;
    }
    final sourceEntity = _requirePrivateEntity(source);
    final targetDirectory = _requirePrivateDirectory(destinationDirectory);
    await _ensureAvailable(sourceEntity, targetDirectory);
    final targetPath =
        '${targetDirectory.path}${Platform.pathSeparator}${source.name}';
    await _ensureTargetDoesNotExist(targetPath);
    try {
      final copied = sourceEntity is Directory
          ? await _copyDirectory(sourceEntity, Directory(targetPath))
          : await (sourceEntity as File).copy(targetPath);
      return _entryFromEntity(copied, destinationDirectory.source);
    } on FileSystemException catch (error) {
      throw FileStorageException(
        'No se pudo copiar "${source.name}".',
        cause: error,
      );
    }
  }

  @override
  Future<FileEntry> move(
    FileEntry source,
    FileEntry destinationDirectory,
  ) async {
    if (_isAuthorizedUri(source.path) &&
        _isAuthorizedUri(destinationDirectory.path)) {
      await _invokeAuthorized('move', <String, Object>{
        'sourceUri': source.path,
        'destinationUri': destinationDirectory.path,
        'name': source.name,
      });
      return source;
    }
    final sourceEntity = _requirePrivateEntity(source);
    final targetDirectory = _requirePrivateDirectory(destinationDirectory);
    await _ensureAvailable(sourceEntity, targetDirectory);
    if (sourceEntity.parent.path == targetDirectory.path) {
      throw const FileStorageException('El archivo ya está en esa carpeta.');
    }
    if (sourceEntity is Directory &&
        targetDirectory.path.startsWith(
          '${sourceEntity.path}${Platform.pathSeparator}',
        )) {
      throw const FileStorageException(
        'No se puede mover una carpeta dentro de sí misma.',
      );
    }
    final targetPath =
        '${targetDirectory.path}${Platform.pathSeparator}${source.name}';
    await _ensureTargetDoesNotExist(targetPath);
    try {
      return _entryFromEntity(
        await sourceEntity.rename(targetPath),
        destinationDirectory.source,
      );
    } on FileSystemException catch (error) {
      throw FileStorageException(
        'No se pudo mover "${source.name}".',
        cause: error,
      );
    }
  }

  @override
  Future<FileEntry> rename(FileEntry entry, String newName) async {
    if (_isAuthorizedUri(entry.path)) {
      await _invokeAuthorized('rename', <String, Object>{
        'uri': entry.path,
        'name': newName.trim(),
      });
      return entry;
    }
    final source = _fileFor(entry);
    final directory = _directoryFor(entry);
    if (source == null && directory == null) {
      throw const FileStorageException(
        'Este recurso externo no permite renombrar desde esta plataforma.',
      );
    }
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed.contains(RegExp(r'[\\/:*?"<>|]'))) {
      throw const FileStorageException('El nombre no es válido.');
    }
    final entity = source ?? directory!;
    final target = '${entity.parent.path}${Platform.pathSeparator}$trimmed';
    if (await FileSystemEntity.type(target) != FileSystemEntityType.notFound) {
      throw const FileStorageException('Ya existe un elemento con ese nombre.');
    }
    try {
      final renamed = await entity.rename(target);
      return _entryFromEntity(renamed, entry.source);
    } on FileSystemException catch (error) {
      throw FileStorageException(
        'No se pudo renombrar "${entry.name}".',
        cause: error,
      );
    }
  }

  @override
  Future<void> delete(FileEntry entry) async {
    if (_isAuthorizedUri(entry.path)) {
      await _invokeAuthorized('delete', <String, Object>{'uri': entry.path});
      return;
    }
    final entity = _fileFor(entry) ?? _directoryFor(entry);
    if (entity == null) {
      throw const FileStorageException(
        'Este recurso externo no permite eliminar desde esta plataforma.',
      );
    }
    try {
      await entity.delete(recursive: entity is Directory);
    } on FileSystemException catch (error) {
      throw FileStorageException(
        'No se pudo eliminar "${entry.name}".',
        cause: error,
      );
    }
  }

  FileSystemEntity _requirePrivateEntity(FileEntry entry) {
    if (entry.source != FileSource.privateStorage) {
      throw const FileStorageException(
        'Esta operación solo está habilitada para recursos privados.',
      );
    }

    final entity = entry.isFolder ? _directoryFor(entry) : _fileFor(entry);
    if (entity == null) {
      throw const FileStorageException('El archivo no está disponible.');
    }

    return entity;
  }

  Directory _requirePrivateDirectory(FileEntry entry) {
    if (entry.source != FileSource.privateStorage || !entry.isFolder) {
      throw const FileStorageException(
        'El destino debe ser una carpeta privada autorizada.',
      );
    }
    final directory = _directoryFor(entry);
    if (directory == null) {
      throw const FileStorageException('La carpeta no está disponible.');
    }
    return directory;
  }

  bool _isAuthorizedUri(String path) => path.startsWith('content://');

  Future<void> _invokeAuthorized(
    String method,
    Map<String, Object> arguments,
  ) async {
    try {
      await _authorizedChannel.invokeMethod<void>(method, arguments);
    } on PlatformException catch (error) {
      throw FileStorageException(
        error.message ?? 'El proveedor no permite esta operación.',
        cause: error,
      );
    }
  }

  Future<void> _ensureAvailable(
    FileSystemEntity source,
    Directory directory,
  ) async {
    if (!await source.exists()) {
      throw const FileStorageException('El archivo de origen ya no existe.');
    }
    if (!await directory.exists()) {
      throw const FileStorageException('La carpeta de destino ya no existe.');
    }
  }

  Future<void> _ensureTargetDoesNotExist(String target) async {
    if (await FileSystemEntity.type(target) != FileSystemEntityType.notFound) {
      throw const FileStorageException('Ya existe un archivo con ese nombre.');
    }
  }

  Future<Directory> _copyDirectory(Directory source, Directory target) async {
    await target.create();
    await for (final entity in source.list(followLinks: false)) {
      final child =
          '${target.path}${Platform.pathSeparator}${_nameOf(entity.path)}';
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(child));
      } else if (entity is File) {
        await entity.copy(child);
      }
    }
    return target;
  }

  FileEntry _entryFromEntity(FileSystemEntity entity, FileSource source) {
    final isDirectory = entity is Directory;
    final stat = entity.statSync();
    return FileEntry(
      name: _nameOf(entity.path),
      type: fileTypeForName(_nameOf(entity.path), isDirectory: isDirectory),
      path: entity.path,
      source: source,
      size: isDirectory ? null : stat.size,
      modified: stat.modified,
      created: stat.changed,
      parentPath: entity.parent.path,
      mimeType: isDirectory ? null : lookupMimeType(entity.path),
    );
  }

  FileEntry _entryForDirectory(Directory directory, FileSource source) {
    return FileEntry(
      name: _nameOf(directory.path),
      type: FileEntryType.folder,
      path: directory.path,
      source: source,
    );
  }

  Directory? _directoryFor(FileEntry entry) {
    if (entry.source == FileSource.externalFile) return null;
    return Directory(entry.path);
  }

  File? _fileFor(FileEntry entry) {
    if (entry.path.startsWith('content://') ||
        entry.path.startsWith('selected://')) {
      return null;
    }
    return File(entry.path);
  }

  Future<Uint8List> _readPath(String path) async {
    if (path.startsWith('content://')) {
      throw const FileStorageException(
        'No se puede convertir una URI content:// a una ruta local.',
      );
    }
    return File(path).readAsBytes();
  }

  String _nameOf(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/')..removeWhere((part) => part.isEmpty);
    return parts.isEmpty ? 'Almacenamiento de la aplicación' : parts.last;
  }
}
