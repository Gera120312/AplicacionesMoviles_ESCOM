import 'package:flutter_test/flutter_test.dart';

import 'package:practica3_file_manager/main.dart';

void main() {
  testWidgets('muestra el gestor de archivos', (tester) async {
    await tester.pumpWidget(const FileManagerApp());
    expect(find.text('Archivos ESCOM'), findsOneWidget);
    expect(find.text('Buscar en la carpeta actual'), findsOneWidget);
  });
}
