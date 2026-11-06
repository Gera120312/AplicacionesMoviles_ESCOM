import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_archivos/models/file_entry.dart';
import 'package:gestor_archivos/services/file_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('mx.ipn.escom/authorized_documents');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'lista y lee documentos content:// mediante el canal autorizado',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'listDirectory':
            return <Map<String, Object?>>[
              <String, Object?>{
                'name': 'nota.txt',
                'uri': 'content://provider/nota',
                'isDirectory': false,
                'size': 4,
                'modified': 1000,
                'mimeType': 'text/plain',
              },
            ];
          case 'readBytes':
            return Uint8List.fromList(<int>[1, 2, 3, 4]);
          default:
            return null;
        }
      });
      final service = LocalFileStorageService();
      const directory = FileEntry(
        name: 'Documentos',
        type: FileEntryType.folder,
        path: 'content://provider/tree',
        source: FileSource.externalDirectory,
      );

      final entries = await service.listDirectory(directory);
      final bytes = await service.readBytes(entries.single);

      expect(entries.single.name, 'nota.txt');
      expect(entries.single.source, FileSource.externalDirectory);
      expect(bytes, orderedEquals(<int>[1, 2, 3, 4]));
    },
  );

  test('envía operaciones mutables al proveedor autorizado', () async {
    final methods = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return null;
    });
    final service = LocalFileStorageService();
    const folder = FileEntry(
      name: 'Documentos',
      type: FileEntryType.folder,
      path: 'content://provider/tree',
      source: FileSource.externalDirectory,
    );
    const file = FileEntry(
      name: 'nota.txt',
      type: FileEntryType.text,
      path: 'content://provider/file',
      source: FileSource.externalFile,
    );

    await service.copy(file, folder);
    await service.move(file, folder);
    await service.rename(file, 'renombrada.txt');
    await service.delete(file);

    expect(methods, containsAll(<String>['copy', 'move', 'rename', 'delete']));
  });
}
