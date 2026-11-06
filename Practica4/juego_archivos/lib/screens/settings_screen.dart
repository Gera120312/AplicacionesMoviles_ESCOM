import 'package:flutter/material.dart';

import '../controllers/app_settings.dart';
import '../models/save_models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.settings, super.key});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) => Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Apariencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            RadioGroup<AppAccent>(
              groupValue: settings.accent,
              onChanged: (value) => settings.setAccent(value!),
              child: const Column(
                children: <Widget>[
                  RadioListTile<AppAccent>(
                    title: Text('Guinda IPN'),
                    value: AppAccent.guinda,
                  ),
                  RadioListTile<AppAccent>(
                    title: Text('Azul ESCOM'),
                    value: AppAccent.blue,
                  ),
                ],
              ),
            ),
            RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (value) => settings.setThemeMode(value!),
              child: Column(
                children: ThemeMode.values
                    .map(
                      (mode) => RadioListTile<ThemeMode>(
                        title: Text(_modeName(mode)),
                        value: mode,
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Sonidos'),
              value: settings.sounds,
              onChanged: settings.setSounds,
            ),
            SwitchListTile(
              title: const Text('Animaciones'),
              value: settings.animations,
              onChanged: settings.setAnimations,
            ),
            const Divider(),
            const Text(
              'Gestión de partidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            RadioGroup<SaveFormat>(
              groupValue: settings.saveFormat,
              onChanged: (value) => settings.setSaveFormat(value!),
              child: Column(
                children: SaveFormat.values
                    .map(
                      (format) => RadioListTile<SaveFormat>(
                        title: Text(format.label),
                        value: format,
                      ),
                    )
                    .toList(),
              ),
            ),
            const ListTile(
              title: Text('Ruta de Sumas'),
              subtitle: Text('Versión 1.0.0 · Práctica 4 · ESCOM-IPN'),
            ),
          ],
        ),
      ),
    );
  }

  String _modeName(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Automático',
    ThemeMode.light => 'Claro',
    ThemeMode.dark => 'Oscuro',
  };
}
