import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:gestor_archivos/models/file_entry.dart';
import 'package:gestor_archivos/services/file_storage_service.dart';

void main() {
  late Directory temporaryDirectory;
  late LocalFileStorageService service;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'gestor_archivos_test_',
    );
    service = LocalFileStorageService(privateDirectory: temporaryDirectory);
  });

  tearDown(() async {
    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('lista archivos privados y detecta sus tipos', () async {
    await File('${temporaryDirectory.path}/notas.txt').writeAsString('hola');
    await Directory('${temporaryDirectory.path}/Documentos').create();

    final root = await service.privateRoot();
    final entries = await service.listDirectory(root);

    expect(
      entries.map((entry) => entry.name),
      containsAll(<String>['notas.txt', 'Documentos']),
    );
    expect(
      entries.singleWhere((entry) => entry.name == 'notas.txt').type,
      FileEntryType.text,
    );
  });

  test('lee bytes de un archivo privado', () async {
    final file = File('${temporaryDirectory.path}/datos.json');
    await file.writeAsString('{"ok":true}');
    final root = await service.privateRoot();
    final entry = (await service.listDirectory(root)).single;

    final bytes = await service.readBytes(entry);

    expect(
      bytes,
      Uint8List.fromList(<int>[
        123,
        34,
        111,
        107,
        34,
        58,
        116,
        114,
        117,
        101,
        125,
      ]),
    );
  });

  test('copia, mueve, renombra y elimina archivos privados', () async {
    final sourceFile = File('${temporaryDirectory.path}/origen.txt');
    final destination = Directory('${temporaryDirectory.path}/destino');
    final secondDestination = Directory('${temporaryDirectory.path}/destino2');
    await sourceFile.writeAsString('contenido');
    await destination.create();
    await secondDestination.create();
    final root = await service.privateRoot();
    final entries = await service.listDirectory(root);
    final source = entries.singleWhere((entry) => entry.name == 'origen.txt');
    final destinationEntry = entries.singleWhere(
      (entry) => entry.name == 'destino',
    );

    await service.copy(source, destinationEntry);
    expect(await File('${destination.path}/origen.txt').exists(), isTrue);
    await expectLater(
      service.copy(source, destinationEntry),
      throwsA(isA<FileStorageException>()),
    );
    final moved = await service.move(
      FileEntry(
        name: 'origen.txt',
        type: FileEntryType.text,
        path: '${destination.path}/origen.txt',
        source: FileSource.privateStorage,
      ),
      FileEntry(
        name: 'destino2',
        type: FileEntryType.folder,
        path: secondDestination.path,
        source: FileSource.privateStorage,
      ),
    );
    final renamed = await service.rename(moved, 'renombrado.txt');
    await service.delete(renamed);
    expect(
      await File('${secondDestination.path}/renombrado.txt').exists(),
      isFalse,
    );
  });
}
