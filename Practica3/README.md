# Práctica 3: Aplicaciones nativas

**Alumno:** Gerardo Rendón Bibiano  
**Boleta:** `2022630011`  
**Grupo:** `7CV4`

## Alcance

Esta carpeta contiene la base de entrega para la Práctica 3 del curso de Aplicaciones Móviles Nativas. Se eligieron las opciones recomendadas por el enunciado:

- **Ejercicio 1:** documentación del entorno macOS/Xcode y bitácora.
- **Ejercicio 2:** gestor de archivos nativo para iOS con SwiftUI.
- **Ejercicio 3:** cámara y micrófono nativos para iOS con AVFoundation.
- **Ejercicio 4:** gestor de archivos offline multiplataforma con Flutter.
- **Ejercicio 5:** cámara y micrófono multiplataforma con Kotlin Multiplatform.

Los ejercicios 1, 2, 3 y la compilación para iOS del ejercicio 5 requieren macOS y Xcode. En este equipo Windows se dejan código base y guías verificables; la compilación final debe realizarse en la Mac o el entorno MacOS-Docker del equipo.

## Estructura

```text
Practica3/
  README.md
  docs/
    informe.md
    bitacora.md
    comparacion.md
  flutter/                 # Ejercicio 4: gestor de archivos offline funcional
  ios-native/
    FileManager/            # Ejercicio 2: SwiftUI + FileManager
    CameraAudio/            # Ejercicio 3: AVFoundation
  kmp/
    shared/                 # Ejercicio 5: lógica común en Kotlin
```

## Ejercicio 4: Flutter

La aplicación usa `path_provider` y solo accede al directorio privado de documentos de la aplicación. Incluye:

- exploración de carpetas y archivos;
- búsqueda por nombre;
- creación de carpetas y archivos `.txt`;
- vista previa de archivos de texto;
- eliminación con confirmación y gesto de mantener presionado;
- actualización por arrastre;
- temas del sistema, guinda y azul;
- funcionamiento sin conexión.

```powershell
cd flutter
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

El APK se genera en `flutter/build/app/outputs/flutter-apk/app-release.apk`.

## Ejercicios 1, 2, 3 y 5: iOS

Abrir el contenido de [`ios-native`](ios-native/README.md) y el proyecto KMP desde Xcode en macOS. Antes de ejecutar:

1. Seleccionar un simulador de iPhone.
2. Configurar un `Team` de firma para dispositivo real.
3. Agregar las claves de privacidad indicadas en [`ios-native/README.md`](ios-native/README.md).
4. Probar el gestor de archivos en el sandbox del simulador.
5. Probar cámara y micrófono en un iPhone real; el simulador no tiene cámara física.

## Evidencia pendiente de la entrega

- capturas del entorno MacOS-Docker o Mac física;
- comparativa del hardware del equipo;
- bitácora con fecha, horario, modalidad y participantes;
- capturas de Xcode, simuladores y dispositivo real;
- APK/IPA generados desde los entornos correspondientes;
- nombres y boletas completas del equipo.

Las plantillas editables se encuentran en [`docs/informe.md`](docs/informe.md), [`docs/bitacora.md`](docs/bitacora.md) y [`docs/comparacion.md`](docs/comparacion.md).

## Referencias

- [Apple Developer: FileManager](https://developer.apple.com/documentation/foundation/filemanager).
- [Apple Developer: AVFoundation](https://developer.apple.com/av-foundation/).
- [Flutter documentation](https://docs.flutter.dev/).
- [Kotlin Multiplatform documentation](https://www.jetbrains.com/help/kotlin-multiplatform-dev/get-started.html).
- Instituto Politécnico Nacional, ESCOM. *Enunciado de la Práctica 3*.
