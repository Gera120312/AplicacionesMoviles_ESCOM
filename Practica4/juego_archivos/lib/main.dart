import 'package:flutter/material.dart';

import 'controllers/app_settings.dart';
import 'screens/home_screen.dart';
import 'services/game_preferences.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings(await GamePreferences.create());
  runApp(SumPathApp(settings: settings));
}

class SumPathApp extends StatelessWidget {
  const SumPathApp({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) => MaterialApp(
        title: 'Ruta de Sumas',
        theme: AppTheme.build(settings.seed, Brightness.light),
        darkTheme: AppTheme.build(settings.seed, Brightness.dark),
        themeMode: settings.themeMode,
        home: HomeScreen(settings: settings),
      ),
    );
  }
}
