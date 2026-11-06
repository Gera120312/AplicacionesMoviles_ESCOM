import 'package:flutter/material.dart';

import 'models/file_entry.dart';
import 'providers/app_state.dart';
import 'screens/favorites_screen.dart';
import 'screens/navigation_shell.dart';
import 'screens/recent_files_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/viewer_screens.dart';
import 'services/preferences_service.dart';
import 'services/file_storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await PreferencesService.create();
  final appState = AppState(preferences, LocalFileStorageService());
  await appState.initialize();
  runApp(FileManagerApp(appState: appState));
}

class FileManagerApp extends StatelessWidget {
  const FileManagerApp({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Gestor de archivos',
          theme: AppTheme.build(appState.accent, Brightness.light),
          darkTheme: AppTheme.build(appState.accent, Brightness.dark),
          themeMode: appState.themeMode,
          home: NavigationShell(appState: appState),
          routes: <String, WidgetBuilder>{
            '/recent': (context) => RecentFilesScreen(appState: appState),
            '/favorites': (context) => FavoritesScreen(appState: appState),
            '/settings': (context) => SettingsScreen(appState: appState),
            '/viewer/text': (context) => TextViewerScreen(
              entry: ModalRoute.of(context)!.settings.arguments! as FileEntry,
              appState: appState,
            ),
            '/viewer/code': (context) => CodeViewerScreen(
              entry: ModalRoute.of(context)!.settings.arguments! as FileEntry,
              appState: appState,
            ),
            '/viewer/image': (context) => ImageViewerScreen(
              entry: ModalRoute.of(context)!.settings.arguments! as FileEntry,
              appState: appState,
            ),
            '/viewer/details': (context) => FileDetailsScreen(
              entry: ModalRoute.of(context)!.settings.arguments! as FileEntry,
            ),
          },
        );
      },
    );
  }
}
