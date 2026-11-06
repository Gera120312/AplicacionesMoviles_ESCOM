# Gestor de archivos

## Objetivo

Aplicación Flutter para explorar el almacenamiento privado de la aplicación y
abrir documentos que el usuario autorice mediante el selector del sistema.

## Funcionalidades

- Exploración privada y navegación por carpetas.
- Selección/importación de documentos.
- Visores de TXT, Markdown, JSON, XML e imágenes.
- Metadatos, favoritos y recientes persistentes.
- Copiar, mover, renombrar, eliminar y crear carpetas privadas.
- Selección múltiple, ordenamiento, vista de lista/cuadrícula y temas.
- Android SAF para URIs `content://`: listado, lectura y operaciones mutables
  cuando el proveedor las permite.

La integración SAF y los diálogos de selección requieren pruebas manuales en
Android. No se afirma soporte iOS validado desde Windows.

## Arquitectura

- `models/file_entry.dart`: modelo de archivo, tipos y metadatos.
- `providers/app_state.dart`: estado, navegación, favoritos, recientes y
  operaciones.
- `services/file_storage_service.dart`: almacenamiento privado y canal SAF.
- `services/preferences_service.dart`: preferencias locales.
- `screens/`: inicio, recientes, favoritos, configuración y visores.
- `widgets/`: breadcrumbs, iconos, tarjetas y estados vacíos.
- `theme/app_theme.dart`: temas Guinda IPN y Azul ESCOM.

## Dependencias

Las versiones directas declaradas están en `pubspec.yaml`; las versiones
resueltas quedan fijadas en `pubspec.lock`. Incluyen `file_picker` 10.3.10,
`flutter_highlight` 0.7.0, `flutter_markdown` 0.7.7+1, `mime` 2.1.0,
`path_provider` 2.1.6, `shared_preferences` 2.5.6 y `xml` 6.6.1.
Android agrega `androidx.documentfile:documentfile:1.0.1`.

## Almacenamiento y seguridad

El directorio privado usa `path_provider`. Android no solicita
`MANAGE_EXTERNAL_STORAGE`: el acceso externo utiliza URIs autorizadas y
`ContentResolver`/`DocumentFile` a través de `MethodChannel`. Nunca se
convierte una URI `content://` en una ruta absoluta.

En iOS existe el proyecto con deployment target 15.0, pero la coordinación de
security-scoped URLs y Document Picker debe verificarse en macOS/Xcode.

## Ejecución y pruebas

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

Resultado registrado: análisis sin problemas, 10 pruebas exitosas y APK debug
generado. Las pruebas manuales de SAF, orientación, modo avión e iOS están
pendientes.
