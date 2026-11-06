import 'package:flutter/material.dart';

import '../services/game_preferences.dart';
import '../models/save_models.dart';

class AppSettings extends ChangeNotifier {
  AppSettings(this.preferences)
    : accent = preferences.accent == 'azul' ? AppAccent.blue : AppAccent.guinda,
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == preferences.brightness,
        orElse: () => ThemeMode.system,
      ),
      sounds = preferences.sounds,
      animations = preferences.animations,
      saveFormat = SaveFormatX.fromName(preferences.saveFormat);

  final GamePreferences preferences;
  AppAccent accent;
  ThemeMode themeMode;
  bool sounds;
  bool animations;
  SaveFormat saveFormat;

  Color get seed => accent == AppAccent.guinda
      ? const Color(0xFF6C1D45)
      : const Color(0xFF1565C0);

  void setAccent(AppAccent value) {
    accent = value;
    preferences.setAccent(value == AppAccent.guinda ? 'guinda' : 'azul');
    notifyListeners();
  }

  void setThemeMode(ThemeMode value) {
    themeMode = value;
    preferences.setBrightness(value.name);
    notifyListeners();
  }

  void setSounds(bool value) {
    sounds = value;
    preferences.setSounds(value);
    notifyListeners();
  }

  void setAnimations(bool value) {
    animations = value;
    preferences.setAnimations(value);
    notifyListeners();
  }

  void setSaveFormat(SaveFormat value) {
    saveFormat = value;
    preferences.setSaveFormat(value.name);
    notifyListeners();
  }
}

enum AppAccent { guinda, blue }
