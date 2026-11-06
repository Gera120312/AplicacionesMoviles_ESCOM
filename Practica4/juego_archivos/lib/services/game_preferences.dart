import 'package:shared_preferences/shared_preferences.dart';

class GamePreferences {
  GamePreferences._(this._preferences);

  final SharedPreferences _preferences;

  static Future<GamePreferences> create() async =>
      GamePreferences._(await SharedPreferences.getInstance());

  String? get accent => _preferences.getString('game_accent');
  String? get brightness => _preferences.getString('game_brightness');
  bool get sounds => _preferences.getBool('game_sounds') ?? true;
  bool get animations => _preferences.getBool('game_animations') ?? true;
  String get saveFormat => _preferences.getString('game_save_format') ?? 'json';

  Future<void> setAccent(String value) =>
      _preferences.setString('game_accent', value);
  Future<void> setBrightness(String value) =>
      _preferences.setString('game_brightness', value);
  Future<void> setSounds(bool value) =>
      _preferences.setBool('game_sounds', value);
  Future<void> setAnimations(bool value) =>
      _preferences.setBool('game_animations', value);
  Future<void> setSaveFormat(String value) =>
      _preferences.setString('game_save_format', value);
}
