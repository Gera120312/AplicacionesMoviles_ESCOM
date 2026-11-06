import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._(this._preferences);

  final SharedPreferences _preferences;

  static Future<PreferencesService> create() async {
    return PreferencesService._(await SharedPreferences.getInstance());
  }

  String? get accent => _preferences.getString('accent');
  String? get brightness => _preferences.getString('brightness');
  bool? get gridView => _preferences.getBool('grid_view');
  String? get sortOrder => _preferences.getString('sort_order');
  bool? get ascending => _preferences.getBool('ascending');
  List<String> get favorites =>
      _preferences.getStringList('favorites') ?? <String>[];
  List<String> get recentFiles =>
      _preferences.getStringList('recent_files') ?? <String>[];

  Future<void> setAccent(String value) =>
      _preferences.setString('accent', value);
  Future<void> setBrightness(String value) =>
      _preferences.setString('brightness', value);
  Future<void> setGridView(bool value) =>
      _preferences.setBool('grid_view', value);
  Future<void> setSortOrder(String value) =>
      _preferences.setString('sort_order', value);
  Future<void> setAscending(bool value) =>
      _preferences.setBool('ascending', value);
  Future<void> setFavorites(List<String> value) =>
      _preferences.setStringList('favorites', value);
  Future<void> setRecentFiles(List<String> value) =>
      _preferences.setStringList('recent_files', value);
}
