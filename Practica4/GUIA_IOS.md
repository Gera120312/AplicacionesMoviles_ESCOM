# Guía de ejecución iOS

La validación iOS está pendiente porque requiere macOS y Xcode. Los proyectos
contienen `ios/Runner.xcworkspace` y declaran iOS 15.0.

## Preparación

Instalar Xcode, sus herramientas de línea de comandos, Flutter y CocoaPods
cuando sea necesario. Abrir `ios/Runner.xcworkspace`, configurar firma para
dispositivo real y seleccionar un simulador.

```bash
cd Practica4/gestor_archivos
flutter pub get
cd ios && pod install && cd ..
flutter test
flutter build ios --debug
flutter run

cd ../juego_archivos
flutter pub get
cd ios && pod install && cd ..
flutter test
flutter build ios --debug
flutter run
```

En el gestor comprobar Document Picker, security-scoped URLs y coordinación de
archivos. En Ruta de Sumas comprobar File Picker, exportación, Share Sheet,
persistencia y modo avión. Registrar capturas reales en `evidencias/ios/`.
Hasta ejecutar en macOS/Xcode, no declarar iOS como probado.
