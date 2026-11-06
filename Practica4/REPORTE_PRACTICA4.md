# Instituto Politécnico Nacional
## Escuela Superior de Cómputo

**Unidad de aprendizaje:** Desarrollo de Aplicaciones Móviles Nativas  
**Práctica 4:** Gestión de archivos multiplataforma (Android e iOS)  
**Alumno o integrantes:** pendiente  
**Grupo:** pendiente  
**Profesor:** pendiente  
**Fecha:** pendiente

## 1. Introducción

El desarrollo móvil actual requiere aplicaciones capaces de funcionar en más
de una plataforma sin perder una experiencia coherente. Android e iOS ofrecen
modelos de seguridad diferentes: Android emplea permisos y proveedores de
documentos, mientras que iOS protege los archivos mediante el sandbox y
autorizaciones concedidas por el selector del sistema. Gestionar un archivo no
consiste únicamente en leer una ruta, sino en respetar su origen, autorización
y capacidades del proveedor.

Flutter permite compartir interfaces, modelos y reglas en Dart, y conectar
servicios nativos cuando una plataforma requiere una API específica. Esta
práctica aplica ese enfoque en un gestor de archivos y en un juego educativo.
El almacenamiento local permite trabajar sin conexión y conservar información
en el dispositivo; por ello las partidas y preferencias se almacenan en áreas
privadas y los documentos externos se usan solo con autorización del sistema.

La persistencia también exige formatos claros. TXT facilita la lectura humana,
JSON favorece el intercambio estructurado y XML representa jerarquías
explícitas. En los tres casos se valida la información antes de utilizarla,
evitando que un archivo incompleto o manipulado cierre la aplicación o afecte
datos válidos.

## 2. Objetivo

Desarrollar dos aplicaciones Flutter multiplataforma que demuestren gestión
local de archivos, visualización de documentos y persistencia de información
sin depender de servicios externos.

Objetivos específicos: explorar almacenamiento privado y documentos
autorizados; visualizar TXT, Markdown, JSON, XML e imágenes; implementar
operaciones seguras; desarrollar un juego con estado, puntuación, tiempo e
historial; serializar y restaurar partidas; validar archivos y preparar
Android API 24+ e iOS 15+.

## 3. Herramientas utilizadas

Se utilizaron Flutter 3.47.2, Dart 3.13.2, VS Code, Android Studio, Android
SDK 36, Git y pruebas de Flutter. Las dependencias se documentan en los
`pubspec.yaml` y `pubspec.lock` de cada aplicación.

## 4. Desarrollo del gestor

El gestor se organizó alrededor de `AppState`, `FileEntry` y
`LocalFileStorageService`. Ofrece navegación, visores, metadatos, favoritos,
recientes y temas Guinda/Azul. `path_provider` maneja el espacio privado.
Android usa `MethodChannel`, `ContentResolver` y `DocumentFile` para URIs
`content://`; el proveedor puede rechazar una operación y ese error se
comunica al usuario.

**Espacios para capturas reales:** inicio, temas, exploración, visores,
favoritos, recientes y operaciones en `evidencias/`.

## 5. Desarrollo de Ruta de Sumas

El juego genera rutas adyacentes con objetivo alcanzable. El nivel básico usa
4×4 y el avanzado 5×5 con bloqueos. El jugador obtiene puntos, recibe
bonificaciones por tiempo y puede usar pistas con penalización. `GameSnapshot`
permite guardar estado completo en TXT, JSON y XML; el autosave propone la
recuperación de una sesión y la lista permite gestionar metadatos.

**Espacios para evidencias reales:** menú, niveles, temas, guardados, lista,
restauración y exportación.

## 6. Implementación técnica

La lógica compartida está en Dart. El código Kotlin del gestor es específico de
Android y conecta SAF sin convertir URIs a rutas. iOS tiene deployment target
15.0, pero no fue compilado en este entorno. Los serializadores y el validador
funcionan sin red.

## 7. Pruebas realizadas

El gestor pasó `flutter analyze`, **10 pruebas automatizadas** y
`flutter build apk --debug`. Ruta de Sumas pasó `flutter analyze`, **14
pruebas automatizadas** y `flutter build apk --debug`. También se ejecutaron
`flutter pub get` y `dart format lib test` en ambos proyectos.

Las pruebas SAF del canal son mocks Dart y no sustituyen un proveedor Android
real. El emulador `Pixel_7` quedó `offline`. No se compiló ni ejecutó iOS.

## 8. Resultados obtenidos

Implementado y comprobado automáticamente: modelos, reglas, serialización,
validación, almacenamiento privado, autosave, operaciones privadas, mocks SAF,
análisis, pruebas y APK. Pendiente: diálogos nativos, proveedor SAF real, modo
avión, ejecución Android e integración iOS.

## 9. Dificultades encontradas

ADB reportó `unauthorized` y después `offline`; el emulador corresponde a
`Pixel_7`. Flutter reportó `cmdline-tools` faltante y licencias Android no
disponibles. iOS requiere macOS/Xcode y Android/iOS no comparten el mismo modelo
de autorización de documentos.

## 10. Conclusiones

La práctica permitió comprobar que Flutter facilita compartir modelos, reglas e
interfaces, pero no elimina las diferencias entre plataformas. La gestión
responsable de archivos requiere separar almacenamiento privado, documentos
seleccionados y APIs nativas. También se comprobó que una persistencia útil
debe conservar el estado completo, no únicamente la puntuación.

Los tres formatos muestran compromisos entre legibilidad, estructura e
interoperabilidad. La validación evita restaurar tableros inconsistentes y
permite conservar partidas válidas ante archivos corruptos. Las pruebas
automatizadas ofrecen una base reproducible, pero no sustituyen la comprobación
de selectores nativos, proveedores externos ni ejecución en iOS.

## 11. Bibliografía

- Android Developers. (s. f.). *Access documents and other files from shared
  storage*. https://developer.android.com/guide/topics/providers/document-provider
- Apple. (s. f.). *Document picker*. https://developer.apple.com/documentation/uikit/view_controllers/providing_access_to_directories
- Dart Team. (s. f.). *Dart documentation*. https://dart.dev/guides
- Flutter. (s. f.). *Flutter documentation*. https://docs.flutter.dev/
- Flutter Community. (s. f.). *Packages*. https://pub.dev/

## 12. Anexos

- [Matriz de pruebas](./MATRIZ_PRUEBAS.md)
- [Documentación técnica](./DOCUMENTACION_TECNICA.md)
- [Formatos de guardado](./FORMATOS_GUARDADO.md)
- [Guía Android](./GUIA_ANDROID.md)
- [Guía iOS](./GUIA_IOS.md)
- [Instrucciones de evidencias](./evidencias/INSTRUCCIONES.md)
