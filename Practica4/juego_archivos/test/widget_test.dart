import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:juego_archivos/controllers/app_settings.dart';
import 'package:juego_archivos/main.dart';
import 'package:juego_archivos/services/game_preferences.dart';

void main() {
  testWidgets('muestra la pantalla inicial', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final settings = AppSettings(await GamePreferences.create());
    await tester.pumpWidget(SumPathApp(settings: settings));

    expect(find.text('Ruta de Sumas'), findsOneWidget);
    expect(find.text('Jugar'), findsOneWidget);
    expect(find.text('Cómo jugar'), findsOneWidget);
  });
}
