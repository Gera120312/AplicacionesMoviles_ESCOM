# Práctica 4: Gestión de archivos multiplataforma

**Instituto Politécnico Nacional**  
**Escuela Superior de Cómputo**  
**Unidad de aprendizaje:** Desarrollo de Aplicaciones Móviles Nativas  
**Tecnología:** Flutter y Dart  
**Integrantes, grupo y profesor:** pendientes de completar.

## Descripción

La práctica explora el almacenamiento local y la gestión de documentos en
aplicaciones móviles multiplataforma. Se desarrollaron dos proyectos Flutter
independientes: un gestor de archivos y el juego educativo **Ruta de Sumas**.
El trabajo usa almacenamiento privado por defecto y evita servicios de nube,
Firebase y autenticación remota.

## Aplicaciones

### Gestor de archivos

Se implementan exploración del directorio privado, selección de documentos,
navegación por carpetas, lectura de TXT/Markdown/JSON/XML, visualización de
imágenes, metadatos, favoritos, recientes, temas Guinda IPN/Azul ESCOM,
operaciones privadas y operaciones Android sobre URIs `content://` autorizadas
mediante Storage Access Framework. Las operaciones de proveedores externos
dependen de las capacidades que el proveedor conceda y la validación manual en
un dispositivo Android sigue pendiente.

### Ruta de Sumas

El juego incluye niveles básico y avanzado, tableros solucionables, casillas
bloqueadas, puntuación, temporizador, pistas, historial de movimientos, pausa,
temas y preferencias persistentes. Las partidas se serializan en TXT, JSON y
XML, se validan, se guardan en almacenamiento privado, se recuperan mediante
autosave y se pueden listar, visualizar, importar, exportar y compartir. Los
diálogos nativos y la ejecución real en Android/iOS todavía requieren
validación manual.

## Requisitos

- Flutter 3.47.2 y Dart 3.13.2.
- Android Studio o VS Code.
- Android SDK con API mínima 24.
- Emulador o dispositivo Android autorizado.
- macOS con Xcode para compilar y probar iOS 15 o posterior.

## Instalación y ejecución

```powershell
cd Practica4\gestor_archivos
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug

cd ..\juego_archivos
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

Para iOS, ejecutar los mismos comandos en macOS, con Xcode configurado y
`ios/Runner.xcworkspace` como proyecto de trabajo.

## Estructura

Cada aplicación separa `models`, `screens`, `widgets`, `services`, `theme`,
`utils` y una capa de estado (`providers` o `controllers`). La documentación
detallada está en:

- [gestor_archivos/README.md](./gestor_archivos/README.md)
- [juego_archivos/README.md](./juego_archivos/README.md)
- [DOCUMENTACION_TECNICA.md](./DOCUMENTACION_TECNICA.md)
- [FORMATOS_GUARDADO.md](./FORMATOS_GUARDADO.md)
- [MATRIZ_PRUEBAS.md](./MATRIZ_PRUEBAS.md)

## Pruebas y limitaciones

En Windows, el gestor pasó análisis y 10 pruebas automatizadas; Ruta de Sumas
pasó análisis y 14 pruebas automatizadas. Ambos proyectos generaron APK debug.
El emulador `Pixel_7` aparece como `emulator-5554 offline`, por lo que no se
realizaron pruebas manuales Android. iOS no se ha compilado ni ejecutado porque
Xcode requiere macOS. Los resultados completos se encuentran en la matriz.

## Capturas

No se incluyen imágenes inventadas. Las carpetas y requisitos de evidencias se
describen en [evidencias/INSTRUCCIONES.md](./evidencias/INSTRUCCIONES.md).

## Referencias

- [Flutter documentation](https://docs.flutter.dev/)
- [Dart documentation](https://dart.dev/guides)
- [Android Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider)
- [Android DocumentFile](https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile)
- [Apple Document Picker](https://developer.apple.com/documentation/uikit/view_controllers/providing_access_to_directories)
- [Flutter packages](https://pub.dev/)

## Preparación para GitHub

`Practica4` no contiene actualmente un directorio `.git` propio; forma parte
del workspace superior. No se ejecutó `git init`, `git commit` ni `git push`.
El `.gitignore` de esta carpeta excluye compilaciones, cachés, archivos
temporales, credenciales y capturas no verificadas.

Para publicar esta carpeta en un repositorio nuevo, después de revisar los
cambios:

```powershell
cd Practica4
git init
git add .
git status
git commit -m "Documentar Practica 4"
git branch -M main
git remote add origin https://github.com/USUARIO/REPOSITORIO.git
git push -u origin main
```

Reemplazar `USUARIO/REPOSITORIO` y configurar autenticación de GitHub de forma
segura. No almacenar tokens, contraseñas ni llaves privadas en el repositorio.
