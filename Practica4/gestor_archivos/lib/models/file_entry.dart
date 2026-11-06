import 'dart:typed_data';

enum FileEntryType { folder, text, markdown, json, xml, image, unknown }

enum FileSource { privateStorage, externalFile, externalDirectory }

class FileEntry {
  const FileEntry({
    required this.name,
    required this.type,
    required this.path,
    required this.source,
    this.size,
    this.modified,
    this.created,
    this.parentPath,
    this.mimeType,
    this.children = const <FileEntry>[],
    this.bytes,
    this.isAccessible = true,
  });

  final String name;
  final FileEntryType type;
  final String path;
  final FileSource source;
  final int? size;
  final DateTime? modified;
  final DateTime? created;
  final String? parentPath;
  final String? mimeType;
  final List<FileEntry> children;
  final Uint8List? bytes;
  final bool isAccessible;

  Map<String, Object?> toMap() => <String, Object?>{
    'name': name,
    'type': type.name,
    'path': path,
    'source': source.name,
    'size': size,
    'modified': modified?.toIso8601String(),
    'created': created?.toIso8601String(),
    'parentPath': parentPath,
    'mimeType': mimeType,
  };

  factory FileEntry.fromMap(Map<String, Object?> map) {
    return FileEntry(
      name: map['name'] as String? ?? 'Sin nombre',
      type: FileEntryType.values.byName(
        map['type'] as String? ?? FileEntryType.unknown.name,
      ),
      path: map['path'] as String? ?? '',
      source: FileSource.values.byName(
        map['source'] as String? ?? FileSource.privateStorage.name,
      ),
      size: map['size'] as int?,
      modified: _parseDate(map['modified']),
      created: _parseDate(map['created']),
      parentPath: map['parentPath'] as String?,
      mimeType: map['mimeType'] as String?,
    );
  }

  bool get isFolder => type == FileEntryType.folder;

  String get readableSize {
    if (size == null) return 'Tamaño no disponible';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}

FileEntryType fileTypeForName(String name, {bool isDirectory = false}) {
  if (isDirectory) return FileEntryType.folder;
  final extension = name.split('.').last.toLowerCase();
  return switch (extension) {
    'txt' => FileEntryType.text,
    'md' || 'markdown' => FileEntryType.markdown,
    'json' => FileEntryType.json,
    'xml' => FileEntryType.xml,
    'png' || 'jpg' || 'jpeg' || 'webp' || 'gif' => FileEntryType.image,
    _ => FileEntryType.unknown,
  };
}

String entryTypeLabel(FileEntryType type) {
  return switch (type) {
    FileEntryType.folder => 'Carpeta',
    FileEntryType.text => 'Texto',
    FileEntryType.markdown => 'Markdown',
    FileEntryType.json => 'JSON',
    FileEntryType.xml => 'XML',
    FileEntryType.image => 'Imagen',
    FileEntryType.unknown => 'Formato no compatible',
  };
}
