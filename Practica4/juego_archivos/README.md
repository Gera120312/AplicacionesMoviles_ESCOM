# Ruta de Sumas

## Objetivo

Juego Flutter sin conexión en el que el jugador selecciona casillas
adyacentes para alcanzar una suma objetivo.

## Funcionalidades

- Nivel básico 4×4 y avanzado 5×5 con casillas bloqueadas.
- Generación de rutas solucionables.
- Puntuación, bonificaciones, penalizaciones, pistas y temporizador.
- Pausa, reanudación, historial y resultados.
- Temas Guinda IPN/Azul ESCOM y preferencias persistentes.
- Guardado y carga de estado completo en TXT, JSON y XML.
- Autosave y recuperación de sesión.
- Categorías, etiquetas, listado, edición, eliminación y renombrado.
- Visualización, importación, exportación y compartición de archivos.

Los diálogos nativos de selección/compartición y la ejecución real en Android
e iOS están pendientes de validación manual.

## Arquitectura

- `models/game_models.dart`: niveles, tablero, casillas, movimientos y estado.
- `models/save_models.dart`: snapshot serializable, formato, categoría y configuración.
- `controllers/game_controller.dart`: reglas, rondas, reloj, puntuación e historial.
- `services/game_generator.dart`: tableros y soluciones reproducibles.
- `services/game_serialization_service.dart`: TXT, JSON y XML.
- `services/game_save_validator.dart`: validación de estructura e invariantes.
- `services/game_storage_service.dart`: archivos privados, autosave y metadatos.
- `services/game_file_transfer_service.dart`: selector y compartición.
- `screens/`: menú, juego, resultados, configuración, partidas y visor.

## Dependencias

Las versiones resueltas principales son `file_picker` 10.3.10,
`path_provider` 2.1.6, `share_plus` 12.0.2, `shared_preferences` 2.5.6 y
`xml` 6.6.1. Las versiones declaradas y transitorias están en
`pubspec.yaml` y `pubspec.lock`.

## Almacenamiento y seguridad

Las partidas se guardan en el directorio privado de documentos, dentro de
`saves/`; el autosave separado usa `recovery/autosave.json`. Las escrituras
usan archivo temporal y sustitución. Los archivos importados se limitan a 5 MB
y se validan antes de entregarse al controlador.

## Ejecución y pruebas

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

Resultado registrado: análisis sin problemas, 14 pruebas exitosas y APK debug
generado. La prueba de iOS, los selectores nativos y el modo avión requieren
entornos reales.
