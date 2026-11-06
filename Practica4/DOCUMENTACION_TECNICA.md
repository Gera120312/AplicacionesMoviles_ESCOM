# Documentación técnica

## Arquitectura común

Ambas aplicaciones usan Flutter para la interfaz y servicios Dart separados de
las pantallas. Los modelos no dependen de `BuildContext`, widgets ni
controladores visuales. La configuración de Android fija `minSdk = 24`; los
proyectos iOS declaran `IPHONEOS_DEPLOYMENT_TARGET = 15.0`.

## Gestor de archivos

`FileEntry` representa nombre, tipo, URI/ruta, origen, tamaño, fechas y MIME.
`AppState` administra el directorio actual, breadcrumbs, selección, favoritos,
recientes, ordenamiento y mensajes de error. `LocalFileStorageService` usa
`path_provider` para el almacenamiento privado y `file_picker` para seleccionar
archivos o carpetas.

Las operaciones privadas usan `dart:io`. Para Android, una URI autorizada
`content://` se envía al canal:

```dart
static const MethodChannel _authorizedChannel = MethodChannel(
  'mx.ipn.escom/authorized_documents',
);
```

El código Kotlin usa `ContentResolver` y `DocumentFile` para listar, abrir,
crear, copiar, mover, renombrar y eliminar sin convertir la URI en una ruta de
Windows/Unix. El proveedor puede rechazar una operación; ese error se propaga
como `FileStorageException` y se muestra al usuario.

Los visores utilizan `flutter_markdown`, `flutter_highlight`, `xml` y APIs de
imagen de Flutter. Favoritos y recientes usan `shared_preferences`; el
historial se limita a 30 elementos. La validación manual de proveedores SAF y
la implementación equivalente de security-scoped URLs en iOS están pendientes.

## Ruta de Sumas

`GameGenerator` crea rutas adyacentes y calcula el objetivo desde la solución.
`GameController` mantiene tablero, selección, estado, reloj, puntuación,
intentos, pistas e historial. El temporizador se cancela al pausar, terminar o
destruir el controlador.

`GameSnapshot` es la representación común de persistencia. Incluye versión,
identificador, nombre, nivel, tablero completo, solución, ruta, ronda,
puntuación, tiempos, estado, fechas, preferencias, movimientos, categoría y
etiquetas. `GameSaveValidator` verifica tipos, índices, adyacencia, bloqueos,
objetivo, tiempos, versión y consistencia del estado.

`GameSerializationService` transforma el snapshot a JSON indentado, XML real o
TXT delimitado con valores sensibles escapados en Base64 URL. `GameStorageService`
usa `path_provider`, directorios `saves/` y `recovery/`, archivos temporales y
lectura validada. `GameFileTransferService` integra `file_picker` y
`share_plus`.

La restauración entrega el snapshot al constructor de `GameController`; por
ello se conserva el tablero y no se genera uno nuevo. Una partida pausada no
inicia `Timer`; una partida activa inicia un único temporizador.

## Código compartido y específico

El código Dart de modelos, reglas, serializadores, validación y UI es
multiplataforma. El código Kotlin en `android/app/.../MainActivity.kt` es
específico de Android y existe para SAF. Los plugins encapsulan sus propias
implementaciones nativas para selección, rutas, preferencias y compartición.
La carpeta iOS existe y conserva el deployment target, pero no se ha compilado
en macOS/Xcode; por tanto, su equivalencia no se considera verificada.

## Manejo de errores

Los errores de archivos se convierten en mensajes legibles; los formatos
vacíos, corruptos, incompatibles o inconsistentes se rechazan antes de
restaurar. La lista del gestor conserva archivos válidos aunque otro archivo
sea ilegible. No se usan servicios remotos ni permisos globales.
