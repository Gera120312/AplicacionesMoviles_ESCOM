# Kotlin Multiplatform: cámara y micrófono

Esta base comparte el estado y los contratos de captura en [`shared/src/commonMain`](shared/src/commonMain). La integración final debe crear un proyecto KMP desde Android Studio y conectar:

- `androidMain`: CameraX, MediaRecorder y permisos de Android.
- `iosMain`: AVCaptureSession, AVAudioRecorder y permisos de iOS.
- Interfaz: Compose Multiplatform o pantallas nativas que consuman `CaptureController`.

La carpeta no contiene un wrapper Gradle completo porque el binario de iOS debe generarse dentro de macOS/Xcode con las versiones disponibles en el equipo. Copiar el directorio [`shared/src/commonMain`](shared/src/commonMain) al proyecto KMP creado por el asistente oficial y declarar `kotlinx-coroutines-core` como dependencia del módulo compartido.

## Flujo esperado

1. `CaptureController.requestPermissions()` solicita permisos por plataforma.
2. `capturePhoto()` guarda una imagen local.
3. `startAudioRecording()` y `stopAudioRecording()` guardan audio local.
4. `items` expone la galería offline mediante `StateFlow`.

## Archivos de referencia

- [`CaptureController.kt`](shared/src/commonMain/kotlin/mx/ipn/practica3/CaptureController.kt): modelo, estado y contrato común.
- [`PlatformCapture.kt`](shared/src/commonMain/kotlin/mx/ipn/practica3/PlatformCapture.kt): punto de extensión para las implementaciones de plataforma.
