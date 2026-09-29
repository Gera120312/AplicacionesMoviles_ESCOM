# Bases nativas para iOS

Estas bases deben integrarse en proyectos creados con Xcode en macOS. Son código inicial y todavía requieren la integración de las funciones indicadas como pendientes antes de la entrega final.

## FileManager

- [`FileManager/ContentView.swift`](FileManager/ContentView.swift) muestra `Documents` y permite crear/eliminar archivos.
- Pendiente: agregar `UIDocumentPickerViewController`, `QLPreviewController`, favoritos con `UserDefaults` y compartir con `UIActivityViewController`.
- En `Info.plist`, agregar `UIFileSharingEnabled = YES` y `LSSupportsOpeningDocumentsInPlace = YES`.

## CameraAudio

- [`CameraAudio/ContentView.swift`](CameraAudio/ContentView.swift) solicita permisos y expone controles de captura.
- Agregar `NSCameraUsageDescription` y `NSMicrophoneUsageDescription` al `Info.plist`.
- Probar la captura en un iPhone real. En el simulador, documentar el uso de `PHPickerViewController` como alternativa para imágenes.
- Pendiente: guardar archivos en `Documents` y metadatos en Core Data.
