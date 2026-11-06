import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestor_archivos/models/file_entry.dart';
import 'package:gestor_archivos/providers/app_state.dart';
import 'package:gestor_archivos/services/file_storage_service.dart';
import 'package:gestor_archivos/services/preferences_service.dart';

void main() {
  test('persiste favoritos y limita el historial a 30 elementos', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await PreferencesService.create();
    final directory = await Directory.systemTemp.createTemp('app_state_test_');
    final service = LocalFileStorageService(privateDirectory: directory);
    final state = AppState(preferences, service);
    final entry = FileEntry(
      name: 'nota.txt',
      type: FileEntryType.text,
      path: '${directory.path}/nota.txt',
      source: FileSource.privateStorage,
    );

    await state.toggleFavorite(entry);
    for (var index = 0; index < 31; index++) {
      await state.recordOpened(
        FileEntry(
          name: '$index.txt',
          type: FileEntryType.text,
          path: '${directory.path}/$index.txt',
          source: FileSource.privateStorage,
        ),
      );
    }

    final restored = AppState(await PreferencesService.create(), service);
    await restored.initialize();
    expect(restored.favorites.single.path, entry.path);
    expect(restored.recentFiles, hasLength(30));
    await directory.delete(recursive: true);
  });
}
