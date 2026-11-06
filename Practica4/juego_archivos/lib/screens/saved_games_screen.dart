import 'package:flutter/material.dart';

import '../controllers/app_settings.dart';
import '../models/save_models.dart';
import '../services/game_file_transfer_service.dart';
import '../services/game_storage_service.dart';
import 'game_screen.dart';
import 'save_file_viewer_screen.dart';

class SavedGamesScreen extends StatefulWidget {
  const SavedGamesScreen({required this.settings, super.key});

  final AppSettings settings;

  @override
  State<SavedGamesScreen> createState() => _SavedGamesScreenState();
}

class _SavedGamesScreenState extends State<SavedGamesScreen> {
  final storage = GameStorageService();
  final transfer = const GameFileTransferService();
  late Future<List<SavedGameFile>> games;
  SaveFormat? formatFilter;
  SaveCategory? categoryFilter;
  String sort = 'date';

  @override
  void initState() {
    super.initState();
    games = storage.list();
  }

  void _reload() => setState(() => games = storage.list());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidas guardadas'),
        actions: <Widget>[
          IconButton(onPressed: _import, icon: const Icon(Icons.file_upload)),
        ],
      ),
      body: FutureBuilder<List<SavedGameFile>>(
        future: games,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var values = snapshot.data!
              .where(
                (game) =>
                    (formatFilter == null || game.format == formatFilter) &&
                    (categoryFilter == null ||
                        game.snapshot.category == categoryFilter),
              )
              .toList();
          values.sort(
            (a, b) => switch (sort) {
              'name' => a.snapshot.name.compareTo(b.snapshot.name),
              'score' => b.snapshot.score.compareTo(a.snapshot.score),
              _ => b.snapshot.modifiedAt.compareTo(a.snapshot.modifiedAt),
            },
          );
          return Column(
            children: <Widget>[
              _filters(context),
              if (values.isEmpty)
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hay partidas guardadas. Guarda una partida desde el juego o importa un archivo.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: values.length,
                    itemBuilder: (context, index) => _gameTile(values[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _filters(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: <Widget>[
        DropdownButton<SaveFormat?>(
          value: formatFilter,
          hint: const Text('Formato'),
          items: <DropdownMenuItem<SaveFormat?>>[
            const DropdownMenuItem(value: null, child: Text('Todos')),
            ...SaveFormat.values.map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text(value.label)),
            ),
          ],
          onChanged: (value) => setState(() => formatFilter = value),
        ),
        const SizedBox(width: 12),
        DropdownButton<SaveCategory?>(
          value: categoryFilter,
          hint: const Text('Categoría'),
          items: <DropdownMenuItem<SaveCategory?>>[
            const DropdownMenuItem(value: null, child: Text('Todas')),
            ...SaveCategory.values.map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text(value.label)),
            ),
          ],
          onChanged: (value) => setState(() => categoryFilter = value),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: sort,
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem(value: 'date', child: Text('Fecha')),
            DropdownMenuItem(value: 'name', child: Text('Nombre')),
            DropdownMenuItem(value: 'score', child: Text('Puntuación')),
          ],
          onChanged: (value) => setState(() => sort = value!),
        ),
      ],
    ),
  );

  Widget _gameTile(SavedGameFile game) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Text(game.format.label)),
      title: Text(game.snapshot.name),
      subtitle: Text(
        '${game.snapshot.level.name} · ${game.snapshot.score} pts · '
        'Ronda ${game.snapshot.round}/${game.snapshot.totalRounds}\n'
        '${game.snapshot.category.label} · ${game.snapshot.tags.join(', ')}',
      ),
      isThreeLine: true,
      onTap: () => _load(game),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _action(value, game),
        itemBuilder: (context) => const <PopupMenuEntry<String>>[
          PopupMenuItem(value: 'load', child: Text('Cargar')),
          PopupMenuItem(value: 'view', child: Text('Ver contenido')),
          PopupMenuItem(value: 'rename', child: Text('Renombrar')),
          PopupMenuItem(
            value: 'metadata',
            child: Text('Editar categoría/etiquetas'),
          ),
          PopupMenuItem(value: 'export', child: Text('Exportar')),
          PopupMenuItem(value: 'share', child: Text('Compartir')),
          PopupMenuItem(value: 'delete', child: Text('Eliminar')),
        ],
      ),
    ),
  );

  Future<void> _action(String action, SavedGameFile game) async {
    switch (action) {
      case 'load':
        _load(game);
      case 'view':
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaveFileViewerScreen(saved: game),
            ),
          );
        }
      case 'rename':
        await _editMetadata(game, onlyName: true);
      case 'metadata':
        await _editMetadata(game);
      case 'export':
        await transfer.export(game);
      case 'share':
        await transfer.share(game);
      case 'delete':
        await storage.delete(game);
        _reload();
    }
  }

  void _load(SavedGameFile game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          level: game.snapshot.level,
          settings: widget.settings,
          snapshot: game.snapshot,
        ),
      ),
    );
  }

  Future<void> _editMetadata(
    SavedGameFile game, {
    bool onlyName = false,
  }) async {
    final name = TextEditingController(text: game.snapshot.name);
    final tags = TextEditingController(text: game.snapshot.tags.join(', '));
    var category = game.snapshot.category;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(onlyName ? 'Renombrar' : 'Editar metadatos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              if (!onlyName)
                DropdownButtonFormField<SaveCategory>(
                  initialValue: category,
                  items: SaveCategory.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => category = value!),
                ),
              if (!onlyName)
                TextField(
                  controller: tags,
                  decoration: const InputDecoration(labelText: 'Etiquetas'),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      await storage.updateMetadata(
        game,
        name: name.text,
        category: onlyName ? null : category,
        tags: onlyName
            ? null
            : tags.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList(),
      );
      _reload();
    }
    name.dispose();
    tags.dispose();
  }

  Future<void> _import() async {
    try {
      final file = await transfer.importFile();
      if (file == null) return;
      await storage.importFile(file);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partida importada correctamente.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo importar: $error')));
      }
    }
  }
}
