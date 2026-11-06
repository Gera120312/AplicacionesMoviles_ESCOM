import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestor_archivos/models/file_entry.dart';
import 'package:gestor_archivos/providers/app_state.dart';
import 'package:gestor_archivos/screens/viewer_screens.dart';
import 'package:gestor_archivos/services/preferences_service.dart';

void main() {
  testWidgets('muestra texto real UTF-8', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final state = AppState(await PreferencesService.create());
    final entry = FileEntry(
      name: 'notas.txt',
      type: FileEntryType.text,
      path: 'selected://notas.txt',
      source: FileSource.externalFile,
      bytes: Uint8List.fromList('Hola ESCOM'.codeUnits),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TextViewerScreen(entry: entry, appState: state),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hola ESCOM'), findsOneWidget);
  });

  testWidgets('muestra contenido JSON real', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final state = AppState(await PreferencesService.create());
    final entry = FileEntry(
      name: 'datos.json',
      type: FileEntryType.json,
      path: 'selected://datos.json',
      source: FileSource.externalFile,
      bytes: Uint8List.fromList('{"ok":true}'.codeUnits),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CodeViewerScreen(entry: entry, appState: state),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HighlightView), findsOneWidget);
  });
}
