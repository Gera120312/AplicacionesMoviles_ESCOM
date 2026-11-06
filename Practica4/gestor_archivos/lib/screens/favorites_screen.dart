import 'package:flutter/material.dart';

import '../models/file_entry.dart';
import '../providers/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/file_entry_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final files = appState.favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: files.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                EmptyState(
                  icon: Icons.star_outline,
                  title: 'No tienes favoritos',
                  message: 'Los archivos y carpetas favoritos aparecerán aquí.',
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: files
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey(entry.path),
                        onDismissed: (_) => appState.removeFavorite(entry),
                        child: FileEntryTile(
                          entry: entry,
                          onOpen: () => _open(context, entry),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  void _open(BuildContext context, FileEntry entry) {
    if (entry.isFolder) {
      appState.openDirectory(entry);
      return;
    }
    final route = switch (entry.type) {
      FileEntryType.text || FileEntryType.markdown => '/viewer/text',
      FileEntryType.json || FileEntryType.xml => '/viewer/code',
      FileEntryType.image => '/viewer/image',
      _ => '/viewer/details',
    };
    appState.recordOpened(entry);
    Navigator.of(context).pushNamed(route, arguments: entry);
  }
}
