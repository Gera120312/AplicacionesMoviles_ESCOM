import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/file_entry.dart';
import '../services/file_storage_service.dart';
import '../services/preferences_service.dart';

enum AccentTheme { guinda, azul }

enum SortOrder { name, size, date, type }

enum StorageStatus { idle, loading, ready, empty, error }

enum FileOperation { copy, move, rename, delete }

class AppState extends ChangeNotifier {
  AppState(this.preferences, [FileStorageService? storage])
    : storage = storage ?? LocalFileStorageService(),
      accentTheme = preferences.accent == 'azul'
          ? AccentTheme.azul
          : AccentTheme.guinda,
      _themeMode = _parseThemeMode(preferences.brightness),
      isGridView = preferences.gridView ?? false,
      sortOrder = _parseSortOrder(preferences.sortOrder),
      ascending = preferences.ascending ?? true;

  final PreferencesService preferences;
  final FileStorageService storage;
  AccentTheme accentTheme;
  ThemeMode _themeMode;
  bool isGridView;
  SortOrder sortOrder;
  bool ascending;

  FileEntry? currentDirectory;
  List<FileEntry> _entries = <FileEntry>[];
  final List<FileEntry> _navigationStack = <FileEntry>[];
  final List<FileEntry> favorites = <FileEntry>[];
  final List<FileEntry> recentFiles = <FileEntry>[];
  final Set<String> selectedPaths = <String>{};
  StorageStatus status = StorageStatus.idle;
  String? errorMessage;

  ThemeMode get themeMode => _themeMode;
  Color get accent => accentTheme == AccentTheme.guinda
      ? const Color(0xFF6C1D45)
      : const Color(0xFF1565C0);
  String get currentPath => currentDirectory?.path ?? '';
  List<FileEntry> get breadcrumbs =>
      List<FileEntry>.unmodifiable(_navigationStack);
  List<FileEntry> get currentEntries {
    final entries = List<FileEntry>.of(_entries);
    entries.sort((a, b) {
      final result = switch (sortOrder) {
        SortOrder.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        SortOrder.size => (a.size ?? -1).compareTo(b.size ?? -1),
        SortOrder.date => (a.modified ?? DateTime(1900)).compareTo(
          b.modified ?? DateTime(1900),
        ),
        SortOrder.type => entryTypeLabel(
          a.type,
        ).compareTo(entryTypeLabel(b.type)),
      };
      return ascending ? result : -result;
    });
    return entries;
  }

  bool isFavorite(FileEntry entry) =>
      favorites.any((item) => item.path == entry.path);
  bool isSelected(FileEntry entry) => selectedPaths.contains(entry.path);

  Future<void> initialize() async {
    favorites
      ..clear()
      ..addAll(_decodeEntries(preferences.favorites));
    recentFiles
      ..clear()
      ..addAll(_decodeEntries(preferences.recentFiles));
    await loadPrivateRoot();
  }

  Future<void> loadPrivateRoot() async =>
      _loadDirectory(await storage.privateRoot());

  Future<void> selectDirectory() async {
    try {
      final directory = await storage.pickDirectory();
      if (directory != null) await _loadDirectory(directory);
    } on FileStorageException catch (error) {
      _setError(error.message);
    }
  }

  Future<FileEntry?> selectFile() async {
    try {
      return await storage.pickFile();
    } on FileStorageException catch (error) {
      _setError(error.message);
      return null;
    }
  }

  Future<void> openDirectory(FileEntry directory) async {
    if (directory.isFolder) await _loadDirectory(directory);
  }

  Future<void> navigateTo(String path) async {
    final directory = _findInCurrentPath(path);
    if (directory != null) await _loadDirectory(directory);
  }

  Future<void> goBack() async {
    final parentPath = currentDirectory?.parentPath;
    if (parentPath != null) await navigateTo(parentPath);
  }

  Future<void> createFolder(String name) async {
    final directory = currentDirectory;
    if (directory == null) return;
    try {
      await storage.createDirectory(directory, name);
      await _loadDirectory(directory);
    } on FileStorageException catch (error) {
      _setError(error.message);
    }
  }

  Future<void> importSelectedFile(FileEntry selected) async {
    final directory = currentDirectory;
    if (directory == null) return;
    try {
      await storage.importFile(directory, selected);
      await _loadDirectory(directory);
    } on FileStorageException catch (error) {
      _setError(error.message);
    }
  }

  Future<Uint8List?> readBytes(FileEntry entry) async {
    try {
      return await storage.readBytes(entry);
    } on FileStorageException catch (error) {
      _setError(error.message);
      return null;
    }
  }

  Future<void> recordOpened(FileEntry entry) async {
    if (entry.isFolder || entry.path.startsWith('selected://')) return;
    recentFiles
      ..removeWhere((item) => item.path == entry.path)
      ..insert(0, entry);
    if (recentFiles.length > 30) {
      recentFiles.removeRange(30, recentFiles.length);
    }
    await preferences.setRecentFiles(_encodeEntries(recentFiles));
    notifyListeners();
  }

  Future<void> removeRecent(FileEntry entry) async {
    recentFiles.removeWhere((item) => item.path == entry.path);
    await preferences.setRecentFiles(_encodeEntries(recentFiles));
    notifyListeners();
  }

  Future<void> clearRecent() async {
    recentFiles.clear();
    await preferences.setRecentFiles(<String>[]);
    notifyListeners();
  }

  Future<void> toggleFavorite(FileEntry entry) async {
    if (entry.path.startsWith('selected://')) return;
    if (isFavorite(entry)) {
      favorites.removeWhere((item) => item.path == entry.path);
    } else {
      favorites.add(entry);
    }
    await preferences.setFavorites(_encodeEntries(favorites));
    notifyListeners();
  }

  Future<void> removeFavorite(FileEntry entry) async {
    favorites.removeWhere((item) => item.path == entry.path);
    await preferences.setFavorites(_encodeEntries(favorites));
    notifyListeners();
  }

  void toggleSelection(FileEntry entry) {
    if (!selectedPaths.add(entry.path)) selectedPaths.remove(entry.path);
    notifyListeners();
  }

  void clearSelection() {
    selectedPaths.clear();
    notifyListeners();
  }

  Future<bool> performOperation(
    FileOperation operation,
    FileEntry entry, {
    FileEntry? destination,
    String? newName,
  }) async {
    try {
      switch (operation) {
        case FileOperation.copy:
          await storage.copy(entry, destination ?? currentDirectory!);
        case FileOperation.move:
          await storage.move(entry, destination ?? currentDirectory!);
        case FileOperation.rename:
          await storage.rename(entry, newName ?? '');
        case FileOperation.delete:
          await storage.delete(entry);
      }
      final directory = currentDirectory;
      if (directory != null) await _loadDirectory(directory);
      _removeStaleReferences(entry.path);
      return true;
    } on FileStorageException catch (error) {
      _setError(error.message);
      return false;
    }
  }

  void setAccent(AccentTheme value) {
    accentTheme = value;
    preferences.setAccent(value == AccentTheme.guinda ? 'guinda' : 'azul');
    notifyListeners();
  }

  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    preferences.setBrightness(value.name);
    notifyListeners();
  }

  void setGridView(bool value) {
    isGridView = value;
    preferences.setGridView(value);
    notifyListeners();
  }

  void setSortOrder(SortOrder value) {
    sortOrder = value;
    preferences.setSortOrder(value.name);
    notifyListeners();
  }

  void setAscending(bool value) {
    ascending = value;
    preferences.setAscending(value);
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadDirectory(FileEntry directory) async {
    status = StorageStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final entries = await storage.listDirectory(directory);
      currentDirectory = directory;
      final index = _navigationStack.indexWhere(
        (item) => item.path == directory.path,
      );
      if (index >= 0) {
        _navigationStack.removeRange(index + 1, _navigationStack.length);
      } else {
        _navigationStack.add(directory);
      }
      _entries = entries;
      status = entries.isEmpty ? StorageStatus.empty : StorageStatus.ready;
    } on FileStorageException catch (error) {
      status = StorageStatus.error;
      errorMessage = error.message;
    }
    notifyListeners();
  }

  FileEntry? _findInCurrentPath(String path) => currentDirectory?.path == path
      ? currentDirectory
      : _entries.where((entry) => entry.path == path).firstOrNull;

  void _setError(String message) {
    errorMessage = message;
    status = StorageStatus.error;
    notifyListeners();
  }

  void _removeStaleReferences(String path) {
    favorites.removeWhere((item) => item.path == path);
    recentFiles.removeWhere((item) => item.path == path);
    selectedPaths.remove(path);
    preferences.setFavorites(_encodeEntries(favorites));
    preferences.setRecentFiles(_encodeEntries(recentFiles));
  }

  List<FileEntry> _decodeEntries(List<String> values) => values
      .map((value) {
        try {
          return FileEntry.fromMap(
            Map<String, Object?>.from(jsonDecode(value) as Map),
          );
        } catch (_) {
          return null;
        }
      })
      .whereType<FileEntry>()
      .toList();

  List<String> _encodeEntries(List<FileEntry> entries) =>
      entries.map((entry) => jsonEncode(entry.toMap())).toList();

  static ThemeMode _parseThemeMode(String? value) => ThemeMode.values
      .firstWhere((mode) => mode.name == value, orElse: () => ThemeMode.system);

  static SortOrder _parseSortOrder(String? value) => SortOrder.values
      .firstWhere((order) => order.name == value, orElse: () => SortOrder.name);
}
