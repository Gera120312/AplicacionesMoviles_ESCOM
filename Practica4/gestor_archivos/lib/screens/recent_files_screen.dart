import 'package:flutter/material.dart';

import '../models/file_entry.dart';
import '../providers/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/file_entry_tile.dart';

class RecentFilesScreen extends StatelessWidget {
  const RecentFilesScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final files = appState.recentFiles;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivos recientes'),
        actions: <Widget>[
          if (files.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Limpiar historial',
              onPressed: () => _clear(context),
            ),
        ],
      ),
      body: files.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                EmptyState(
                  icon: Icons.history,
                  title: 'Sin archivos recientes',
                  message: 'Los archivos que abras aparecerán aquí.',
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
                        onDismissed: (_) => appState.removeRecent(entry),
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
    if (entry.isFolder) return;
    final route = switch (entry.type) {
      FileEntryType.text || FileEntryType.markdown => '/viewer/text',
      FileEntryType.json || FileEntryType.xml => '/viewer/code',
      FileEntryType.image => '/viewer/image',
      _ => '/viewer/details',
    };
    appState.recordOpened(entry);
    Navigator.of(context).pushNamed(route, arguments: entry);
  }

  Future<void> _clear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Eliminar todos los archivos recientes?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await appState.clearRecent();
  }
}
