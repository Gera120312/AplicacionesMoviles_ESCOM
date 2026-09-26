// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:hola_mundo_flutter/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CatalogoApp());

    // Verify that our counter starts at 0.
    expect(find.text('Catálogo UI · Entrada'), findsOneWidget);
    expect(find.text('Nombre para la lista'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.text('Acciones'));
    await tester.pump();
    expect(find.text('Botones y acciones'), findsOneWidget);
  });
}
