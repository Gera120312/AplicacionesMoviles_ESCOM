import 'package:flutter/material.dart';

import '../models/file_entry.dart';
import '../providers/app_state.dart';
import '../widgets/breadcrumbs.dart';
import '../widgets/empty_state.dart';
import '../widgets/file_entry_tile.dart';
import '../widgets/quick_access_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final entries = appState.currentEntries;
    return PopScope(
      canPop: appState.currentDirectory?.parentPath == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && appState.currentDirectory?.parentPath != null) {
          appState.goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: appState.selectedPaths.isEmpty
              ? const Text('Gestor de archivos')
              : Text('${appState.selectedPaths.length} seleccionados'),
          actions: <Widget>[
            if (appState.selectedPaths.isNotEmpty)
              IconButton(
                onPressed: appState.clearSelection,
                icon: const Icon(Icons.close),
                tooltip: 'Cancelar selección',
              ),
            IconButton(
              tooltip: appState.isGridView
                  ? 'Vista de lista'
                  : 'Vista de cuadrícula',
              onPressed: () => appState.setGridView(!appState.isGridView),
              icon: Icon(
                appState.isGridView ? Icons.view_list : Icons.grid_view,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Ordenar',
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                if (value == 'ascending') {
                  appState.setAscending(!appState.ascending);
                } else {
                  appState.setSortOrder(SortOrder.values.byName(value));
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                for (final order in SortOrder.values)
                  CheckedPopupMenuItem<String>(
                    value: order.name,
                    checked: appState.sortOrder == order,
                    child: Text(_sortLabel(order)),
                  ),
                const PopupMenuDivider(),
                CheckedPopupMenuItem<String>(
                  value: 'ascending',
                  checked: appState.ascending,
                  child: Text(
                    appState.ascending ? 'Ascendente' : 'Descendente',
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'about') {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Gestor de archivos',
                    applicationVersion: '1.0.0',
                    children: const <Widget>[Text('Práctica 4 · ESCOM-IPN')],
                  );
                }
              },
              itemBuilder: (context) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'about',
                  child: Text('Acerca de la aplicación'),
                ),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Explora tus archivos',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Almacenamiento privado y ubicaciones autorizadas por el usuario.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                QuickAccessCard(
                  icon: Icons.folder_copy_outlined,
                  label: 'Almacenamiento de la aplicación',
                  onTap: appState.loadPrivateRoot,
                ),
                QuickAccessCard(
                  icon: Icons.create_new_folder_outlined,
                  label: 'Seleccionar carpeta',
                  onTap: () => appState.selectDirectory(),
                ),
                QuickAccessCard(
                  icon: Icons.file_open_outlined,
                  label: 'Seleccionar archivo',
                  onTap: () => _selectFile(context),
                ),
                QuickAccessCard(
                  icon: Icons.history,
                  label: 'Archivos recientes',
                  onTap: () => Navigator.of(context).pushNamed('/recent'),
                ),
                QuickAccessCard(
                  icon: Icons.star_outline,
                  label: 'Favoritos',
                  onTap: () => Navigator.of(context).pushNamed('/favorites'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (appState.currentDirectory != null)
              Breadcrumbs(
                entries: appState.breadcrumbs,
                onNavigate: appState.navigateTo,
              ),
            const SizedBox(height: 12),
            if (appState.status == StorageStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (appState.status == StorageStatus.error)
              EmptyState(
                icon: Icons.error_outline,
                title: 'No se pudo acceder',
                message:
                    appState.errorMessage ?? 'Error de acceso desconocido.',
                action: FilledButton(
                  onPressed: appState.loadPrivateRoot,
                  child: const Text('Volver al almacenamiento privado'),
                ),
              )
            else if (entries.isEmpty)
              EmptyState(
                icon: Icons.folder_open,
                title: 'Carpeta vacía',
                message: 'No hay archivos ni carpetas en esta ubicación.',
                action: Wrap(
                  spacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => _createFolder(context),
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('Crear carpeta'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _importFile(context),
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Importar archivo'),
                    ),
                  ],
                ),
              )
            else if (appState.isGridView)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 150,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) => FileEntryTile(
                  entry: entries[index],
                  grid: true,
                  onOpen: () => _openEntry(context, entries[index]),
                  onLongPress: () => appState.toggleSelection(entries[index]),
                  onMore: () => _showEntryMenu(context, entries[index]),
                  selected: appState.isSelected(entries[index]),
                ),
              )
            else
              ...entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FileEntryTile(
                    entry: entry,
                    onOpen: () => _openEntry(context, entry),
                    onLongPress: () => appState.toggleSelection(entry),
                    onMore: () => _showEntryMenu(context, entry),
                    selected: appState.isSelected(entry),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openEntry(BuildContext context, FileEntry entry) {
    if (appState.selectedPaths.isNotEmpty) {
      appState.toggleSelection(entry);
      return;
    }
    if (entry.isFolder) {
      appState.openDirectory(entry);
      return;
    }
    final route = switch (entry.type) {
      FileEntryType.text || FileEntryType.markdown => '/viewer/text',
      FileEntryType.json || FileEntryType.xml => '/viewer/code',
      FileEntryType.image => '/viewer/image',
      FileEntryType.folder => '/viewer/details',
      FileEntryType.unknown => '/viewer/details',
    };
    if (entry.type == FileEntryType.unknown) {
      _unsupportedFile(context, entry);
    } else {
      appState.recordOpened(entry);
      Navigator.of(context).pushNamed(route, arguments: entry);
    }
  }

  Future<void> _showEntryMenu(BuildContext context, FileEntry entry) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Abrir'),
              onTap: () => Navigator.pop(context, 'open'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Detalles'),
              onTap: () => Navigator.pop(context, 'details'),
            ),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(
                appState.isFavorite(entry)
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
              ),
              onTap: () => Navigator.pop(context, 'favorite'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copiar aquí'),
              onTap: () => Navigator.pop(context, 'copy'),
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: const Text('Mover aquí'),
              onTap: () => Navigator.pop(context, 'move'),
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Renombrar'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Eliminar'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case 'open':
        _openEntry(context, entry);
      case 'details':
        Navigator.of(context).pushNamed('/viewer/details', arguments: entry);
      case 'favorite':
        await appState.toggleFavorite(entry);
        if (!context.mounted) return;
      case 'copy':
        await appState.performOperation(FileOperation.copy, entry);
        if (!context.mounted) return;
        _showStateError(context);
      case 'move':
        await appState.performOperation(FileOperation.move, entry);
        if (!context.mounted) return;
        _showStateError(context);
      case 'rename':
        await _rename(context, entry);
      case 'delete':
        await _delete(context, entry);
    }
  }

  Future<void> _rename(BuildContext context, FileEntry entry) async {
    final controller = TextEditingController(text: entry.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(controller: controller, autofocus: true),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || name == null) return;
    await appState.performOperation(FileOperation.rename, entry, newName: name);
    if (!context.mounted) return;
    _showStateError(context);
  }

  Future<void> _delete(BuildContext context, FileEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar elemento'),
        content: Text(
          '¿Eliminar "${entry.name}"? Esta operación puede ser permanente.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    await appState.performOperation(FileOperation.delete, entry);
    if (!context.mounted) return;
    _showStateError(context);
  }

  void _showStateError(BuildContext context) {
    if (appState.errorMessage != null) {
      _showError(context, appState.errorMessage!);
    }
  }

  String _sortLabel(SortOrder order) {
    return switch (order) {
      SortOrder.name => 'Nombre',
      SortOrder.size => 'Tamaño',
      SortOrder.date => 'Fecha',
      SortOrder.type => 'Tipo',
    };
  }

  Future<void> _selectFile(BuildContext context) async {
    final entry = await appState.selectFile();
    if (!context.mounted || entry == null) return;
    if (entry.type == FileEntryType.unknown) {
      _unsupportedFile(context, entry);
      return;
    }
    final route = switch (entry.type) {
      FileEntryType.text || FileEntryType.markdown => '/viewer/text',
      FileEntryType.json || FileEntryType.xml => '/viewer/code',
      FileEntryType.image => '/viewer/image',
      FileEntryType.folder || FileEntryType.unknown => '/viewer/details',
    };
    appState.recordOpened(entry);
    Navigator.of(context).pushNamed(route, arguments: entry);
  }

  Future<void> _importFile(BuildContext context) async {
    final entry = await appState.selectFile();
    if (!context.mounted || entry == null) return;
    await appState.importSelectedFile(entry);
    if (context.mounted && appState.errorMessage != null) {
      _showError(context, appState.errorMessage!);
    }
  }

  Future<void> _createFolder(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear carpeta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || name == null) return;
    await appState.createFolder(name);
    if (context.mounted && appState.errorMessage != null) {
      _showError(context, appState.errorMessage!);
    }
  }

  void _unsupportedFile(BuildContext context, FileEntry entry) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Formato no compatible'),
        content: Text(
          'No hay un visualizador interno para "${entry.name}". '
          'Abrir con otra aplicación y compartir se integrarán posteriormente.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
