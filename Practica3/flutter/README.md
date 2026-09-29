# Práctica 3: gestor de archivos Flutter

<!-- markdownlint-disable MD012 -->

Aplicación multiplataforma para explorar y administrar archivos dentro del directorio privado de documentos de la aplicación. Funciona sin conexión a Internet.

## Funcionalidades

- Explorar carpetas y archivos locales.
- Buscar por nombre en la carpeta actual.
- Crear carpetas y archivos de texto.
- Abrir archivos `.txt`, `.md`, `.json`, `.swift`, `.dart` y `.kt`.
- Eliminar elementos con confirmación.
- Actualizar el listado deslizando hacia abajo.
- Cambiar entre tema del sistema, tema guinda y tema azul.

## Ejecución

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Para generar el APK de Android:

```powershell
flutter build apk --release
```

El archivo se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## Estructura

- [`lib/main.dart`](lib/main.dart): interfaz, navegación y operaciones locales.
- [`test/widget_test.dart`](test/widget_test.dart): prueba del arranque de la aplicación.
- `android/` e `ios/`: plataformas generadas por Flutter.

## Referencia

- [Documentación oficial de Flutter](https://docs.flutter.dev/).

