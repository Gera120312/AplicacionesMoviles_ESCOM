# Informe técnico: Práctica 3

## Portada

- Institución: Instituto Politécnico Nacional, ESCOM
- Unidad de aprendizaje: Desarrollo de aplicaciones móviles nativas
- Práctica: 3 - Aplicaciones nativas
- Integrantes: completar nombres y números de boleta
- Profesor: Gabriel Hurtado Aviles
- Fecha: 28 de septiembre de 2026

## Introducción

El equipo desarrolló soluciones nativas para iOS y soluciones multiplataforma para Android/iOS, priorizando el funcionamiento sin conexión, la persistencia local y el acceso controlado a los recursos del dispositivo.

## Ejercicio 1: Entorno

Completar con la PC seleccionada, sus especificaciones, capturas, responsable, sesiones de trabajo y pasos de MacOS-Docker. Incluir la evidencia de Xcode, el simulador y el proyecto Swift de prueba.

## Ejercicio 2: Gestor de archivos para iOS

La implementación usa SwiftUI y `FileManager` para trabajar dentro de `Documents`, `Inbox` y `tmp`. Documentar la búsqueda, el ordenamiento, los favoritos, los archivos recientes, la importación con `UIDocumentPickerViewController`, el uso compartido con `UIActivityViewController`, la vista previa con Quick Look y las claves `UIFileSharingEnabled` y `LSSupportsOpeningDocumentsInPlace`.

## Ejercicio 3: Cámara y micrófono para iOS

La implementación usa `AVCaptureSession`, `AVAudioRecorder` y `AVAudioPlayer`. Documentar los permisos, la captura en un dispositivo real, la alternativa con fototeca en el simulador, los filtros, el flash, el temporizador, la galería y la persistencia de metadatos.

## Ejercicio 4: Flutter

La aplicación seleccionada es la opción A, gestor de archivos. La lógica se encuentra en [`flutter/lib/main.dart`](../flutter/lib/main.dart); usa almacenamiento local privado y no requiere Internet. Ejecutar `flutter analyze`, `flutter test` y `flutter build apk --release`.

## Ejercicio 5: Kotlin Multiplatform

La aplicación seleccionada es la opción B, cámara y micrófono. [`kmp/shared`](../kmp/shared) contiene los contratos y el estado común. Las implementaciones `expect/actual` deben conectar AVFoundation en iOS y CameraX/MediaRecorder en Android al completar la integración en Android Studio/Xcode.

## Pruebas

| Caso | Plataforma | Resultado | Evidencia |
| --- | --- | --- | --- |
| Flutter analiza sin errores | Windows | Aprobado | salida de `flutter analyze` |
| Widget inicial de Flutter | Windows | Aprobado | salida de `flutter test` |
| Crear carpeta y archivo | Android/iOS | Pendiente | Captura por agregar |
| Importar y compartir | iOS | Pendiente | Captura por agregar |
| Capturar foto y audio | iPhone real | Pendiente | Captura por agregar |
| Compilar APK e IPA | Android/iOS | APK aprobado; IPA pendiente | Binarios por agregar |

## Conclusiones

