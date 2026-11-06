import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestor_archivos/main.dart';
import 'package:gestor_archivos/providers/app_state.dart';
import 'package:gestor_archivos/services/preferences_service.dart';

void main() {
  testWidgets('muestra la pantalla inicial', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final appState = AppState(await PreferencesService.create());
    await tester.pumpWidget(FileManagerApp(appState: appState));

    expect(find.text('Gestor de archivos'), findsOneWidget);
    expect(find.textContaining('Explora tus archivos'), findsOneWidget);
  });
}
