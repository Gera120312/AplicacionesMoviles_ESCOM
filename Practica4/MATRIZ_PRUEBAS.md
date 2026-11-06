# Matriz de pruebas - Práctica 4

Fecha de ejecución: 2026-11-05  
Entorno: Windows 11, Flutter 3.47.2, Dart 3.13.2  

## Resultados

| ID de prueba | Aplicación | Sistema operativo | Versión | Dispositivo o simulador | Funcionalidad | Pasos | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|---|---|---|---|
| GM-AUTO-001 | Gestor de archivos | Windows | Flutter 3.47.2 | Dart VM | Análisis estático | Ejecutar `flutter analyze` | Sin errores | Sin issues encontrados | Automatizada aprobada | `flutter analyze` |
| GM-AUTO-002 | Gestor de archivos | Windows | Flutter 3.47.2 | Dart VM | Pruebas del gestor | Ejecutar `flutter test` | Todas las pruebas pasan | 10 pruebas exitosas, incluidas 2 de canal SAF simulado | Automatizada aprobada | `test/` |
| GM-AUTO-003 | Gestor de archivos | Android | API configurada 24+ | Gradle/APK debug | Compilación | Ejecutar `flutter build apk --debug` | APK generado | APK generado correctamente | Automatizada aprobada | `build/app/outputs/flutter-apk/app-debug.apk` |
| GM-AUTO-004 | Gestor de archivos | Windows | Flutter 3.47.2 | Archivos temporales | Operaciones privadas | Crear, copiar, mover, renombrar y eliminar archivos temporales | Operaciones correctas sin sobrescritura | Prueba exitosa | Automatizada aprobada | `test/file_storage_service_test.dart` |
| GM-MAN-001 | Gestor de archivos | Android | API 24+ | AVD Pixel 7 | SAF: seleccionar carpeta y listar contenido | Autorizar una carpeta mediante selector del sistema | Listar y navegar usando URIs `content://` | Pendiente; ADB está `offline` | Pendiente de ejecutar | ADB `emulator-5554 offline` |
| GM-MAN-002 | Gestor de archivos | Android | API 24+ | AVD Pixel 7 | SAF: modificar documentos autorizados | Copiar, mover, renombrar, eliminar y crear carpeta | Operación permitida por el proveedor o error legible | Pendiente; requiere emulador autorizado | Pendiente de ejecutar | Canal `authorized_documents` |
| GM-MAN-003 | Gestor de archivos | iOS | iOS 15+ | Simulador/dispositivo Xcode | Document Picker y security-scoped URLs | Seleccionar y modificar un documento externo | Operaciones autorizadas por el proveedor | Pendiente; Windows no dispone de Xcode | Pendiente de ejecutar | Proyecto iOS presente |
| GM-MAN-004 | Gestor de archivos | Android/iOS | API 24+/iOS 15+ | Dispositivo real | Temas, rotación y pantallas pequeñas | Probar claro/oscuro, Guinda/Azul, vertical/horizontal | Sin desbordamientos y texto legible | Pendiente de ejecución manual | Pendiente de ejecutar | Requiere dispositivo |
| RJ-AUTO-001 | Ruta de Sumas | Windows | Flutter 3.47.2 | Dart VM | Motor de juego | Ejecutar pruebas de generación y controlador | Rutas alcanzables, bloqueos y reglas correctas | 5 pruebas del controlador exitosas | Automatizada aprobada | `test/game_controller_test.dart` |
| RJ-AUTO-002 | Ruta de Sumas | Windows | Flutter 3.47.2 | Archivos temporales | TXT, JSON y XML | Serializar y deserializar snapshots completos | Estado idéntico después del round-trip | 3 formatos aprobados | Automatizada aprobada | `test/game_save_test.dart` |
| RJ-AUTO-003 | Ruta de Sumas | Windows | Flutter 3.47.2 | Archivos temporales | Persistencia y autosave | Guardar, listar, recuperar y eliminar autosave | Persistencia y prevención de sobrescritura | Prueba exitosa | Automatizada aprobada | `test/game_save_test.dart` |
| RJ-AUTO-004 | Ruta de Sumas | Windows | Flutter 3.47.2 | Dart VM | Aplicación y widgets | Ejecutar `flutter test` | Todas las pruebas pasan | 14 pruebas exitosas | Automatizada aprobada | `test/` |
| RJ-AUTO-005 | Ruta de Sumas | Android | API configurada 24+ | Gradle/APK debug | Compilación | Ejecutar `flutter build apk --debug` | APK generado | APK generado correctamente | Automatizada aprobada | `build/app/outputs/flutter-apk/app-debug.apk` |
| RJ-MAN-001 | Ruta de Sumas | Android | API 24+ | AVD Pixel 7 | Guardado/carga manual | Jugar, guardar en cada formato y cargar desde lista | Recuperar tablero y progreso exactos | Pendiente; ADB está `offline` | Pendiente de ejecutar | Requiere dispositivo autorizado |
| RJ-MAN-002 | Ruta de Sumas | Android | API 24+ | AVD Pixel 7 | Selector, exportación y compartir | Importar/exportar TXT, JSON y XML; compartir | Usar APIs nativas sin perder el archivo privado | Pendiente; diálogos nativos no ejecutables | Pendiente de ejecutar | Requiere dispositivo autorizado |
| RJ-MAN-003 | Ruta de Sumas | iOS | iOS 15+ | Simulador/dispositivo Xcode | Persistencia y compartir | Ejecutar guardado, carga y compartir | Funcionalidad equivalente en iOS | Pendiente; requiere macOS/Xcode | Pendiente de ejecutar | Proyecto iOS presente |
| OFF-AUTO-001 | Ambas | Windows | Flutter 3.47.2 | Análisis de código | Dependencias de ejecución | Revisar imports y servicios externos | Sin Firebase, nube ni APIs remotas | No se encontraron servicios remotos | Automatizada aprobada | `pubspec.yaml`, `lib/` |
| OFF-MAN-001 | Ambas | Android/iOS | API 24+/iOS 15+ | Dispositivo real | Modo avión | Activar modo avión y jugar/gestionar archivos | Funciones locales continúan disponibles | Pendiente de ejecución | Pendiente de ejecutar | Requiere dispositivo |
| ENV-001 | Ambas | Windows | Android SDK 36 | AVD Pixel 7 | Diagnóstico ADB | Ejecutar `adb devices -l`, reiniciar servidor y consultar estado | Dispositivo `device` | Inicialmente `unauthorized`; después `offline` | Fallida / bloqueada | `adb devices -l` |
| ENV-002 | Ambas | Windows | iOS 15+ | Windows sin Xcode | Preparación iOS | Revisar proyectos y deployment target | Proyecto listo, pruebas reales pendientes | Proyectos presentes, target 15.0; sin compilación local | Pendiente de ejecutar | `ios/Runner.xcodeproj` |

## Clasificación

- **Automatizada aprobada:** ejecutada localmente por comandos y pruebas reproducibles.
- **Manual aprobada:** no hay pruebas manuales de dispositivo aprobadas en esta ejecución.
- **Fallida:** diagnóstico ADB no produjo un dispositivo utilizable.
- **Pendiente de ejecutar:** requiere un emulador autorizado, dispositivo físico o macOS con Xcode.

## Diagnóstico ADB

El objetivo `emulator-5554` corresponde al AVD `Pixel_7` listado por `flutter emulators`; no es un teléfono físico. El reinicio no destructivo ejecutado fue:

```powershell
$adb = 'C:\Users\gerar\AppData\Local\Android\sdk\platform-tools\adb.exe'
& $adb kill-server
& $adb start-server
& $adb devices -l
```

El estado final fue `offline`, por lo que no se intentó instalar, ejecutar ni borrar datos del emulador.

Para continuar manualmente:

1. Abrir Android Studio > Device Manager.
2. Confirmar que `Pixel_7` termine de arrancar; usar **Cold Boot Now** si está atascado.
3. No usar **Wipe Data** sin autorización.
4. Cerrar cualquier instancia duplicada de Android Studio/emulador.
5. Ejecutar:

```powershell
$adb = 'C:\Users\gerar\AppData\Local\Android\sdk\platform-tools\adb.exe'
& $adb kill-server
& $adb start-server
& $adb devices -l
flutter devices
```

El resultado utilizable debe mostrar `emulator-5554 device`, no `unauthorized` ni `offline`. Si continúa `offline`, reiniciar normalmente el AVD y verificar que no existan dos SDK/ADB activos. Flutter también reportó que faltan `cmdline-tools` y que las licencias Android no están disponibles; deben corregirse desde Android Studio o con `sdkmanager` antes de usar otros emuladores.

## Validación iOS pendiente

Los dos proyectos contienen `ios/Runner.xcodeproj` y `ios/Runner.xcworkspace`, con `IPHONEOS_DEPLOYMENT_TARGET = 15.0`. No se afirma compilación ni ejecución iOS: Windows no incluye Xcode. En macOS se debe ejecutar, dentro de cada proyecto:

```bash
flutter pub get
cd ios
pod install
cd ..
flutter build ios --debug
flutter test
```

Después deben probarse Document Picker/security-scoped URLs del gestor y File Picker/Share Sheet del juego en simulador y dispositivo real.
