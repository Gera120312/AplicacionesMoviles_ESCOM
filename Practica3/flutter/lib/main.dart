import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const FileManagerApp());
}

class FileManagerApp extends StatefulWidget {
  const FileManagerApp({super.key});

  @override
  State<FileManagerApp> createState() => _FileManagerAppState();
}

class _FileManagerAppState extends State<FileManagerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const burgundy = Color(0xff7a1737);
    const blue = Color(0xff005baa);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archivos ESCOM',
      themeMode: _themeMode,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: blue)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: burgundy,
          brightness: Brightness.dark,
        ),
      ),
      home: FileBrowserPage(
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class FileBrowserPage extends StatefulWidget {
  const FileBrowserPage({required this.onThemeChanged, super.key});

  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<FileBrowserPage> createState() => _FileBrowserPageState();
}

class _FileBrowserPageState extends State<FileBrowserPage> {
  Directory? _directory;
  List<FileSystemEntity> _entries = <FileSystemEntity>[];
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDirectory();
  }

  Future<void> _loadDirectory([Directory? directory]) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final target = directory ?? await getApplicationDocumentsDirectory();
      final entries = target.listSync()..sort(_compareEntries);
      if (!mounted) return;
      setState(() {
        _directory = target;
        _entries = entries;
        _loading = false;
      });
    } on FileSystemException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  int _compareEntries(FileSystemEntity left, FileSystemEntity right) {
    final leftDirectory = left is Directory;
    final rightDirectory = right is Directory;
    if (leftDirectory != rightDirectory) return leftDirectory ? -1 : 1;
    return _name(left).toLowerCase().compareTo(_name(right).toLowerCase());
  }

  String _name(FileSystemEntity entity) => entity.path.split(Platform.pathSeparator).last;

  List<FileSystemEntity> get _visibleEntries => _entries
      .where((entry) => _name(entry).toLowerCase().contains(_query.toLowerCase()))
      .toList();

  Future<void> _createFolder() async {
    final name = await _askForName('Nueva carpeta');
    if (name == null || _directory == null) return;
    try {
      await Directory('${_directory!.path}${Platform.pathSeparator}$name').create();
      await _loadDirectory(_directory);
    } on FileSystemException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _createTextFile() async {
    final name = await _askForName('Nuevo archivo', extension: '.txt');
    if (name == null || _directory == null) return;
    try {
      await File('${_directory!.path}${Platform.pathSeparator}$name').writeAsString('');
      await _loadDirectory(_directory);
    } on FileSystemException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<String?> _askForName(String title, {String extension = ''}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Nombre$extension'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, '$value$extension');
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(FileSystemEntity entity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar elemento'),
        content: Text('¿Eliminar ${_name(entity)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await entity.delete(recursive: entity is Directory);
      await _loadDirectory(_directory);
    } on FileSystemException catch (error) {
      _showMessage(error.message);
    }
  }

  void _open(FileSystemEntity entity) {
    if (entity is Directory) {
      _loadDirectory(entity);
      return;
    }
    if (entity is File && _isTextFile(entity.path)) {
      Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => TextPreviewPage(file: entity)),
      );
      return;
    }
    _showMessage('La vista previa de este tipo de archivo no está disponible.');
  }

  bool _isTextFile(String path) => <String>['.txt', '.md', '.json', '.swift', '.dart', '.kt']
      .any(path.toLowerCase().endsWith);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final currentDirectory = _directory;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivos ESCOM'),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Tema',
            icon: const Icon(Icons.palette_outlined),
            onSelected: widget.onThemeChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(value: ThemeMode.system, child: Text('Tema del sistema')),
              PopupMenuItem(value: ThemeMode.light, child: Text('Tema guinda claro')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Tema azul oscuro')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadDirectory(_directory),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDirectory?.path ?? 'Cargando almacenamiento local...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      leading: const Icon(Icons.search),
                      hintText: 'Buscar en la carpeta actual',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(child: Center(child: Text(_error!)))
            else if (_visibleEntries.isEmpty)
              const SliverFillRemaining(child: Center(child: Text('No hay elementos aquí.')))
            else
              SliverList.builder(
                itemCount: _visibleEntries.length,
                itemBuilder: (context, index) {
                  final entry = _visibleEntries[index];
                  final directory = entry is Directory;
                  return ListTile(
                    leading: Icon(directory ? Icons.folder_outlined : _iconFor(entry.path)),
                    title: Text(_name(entry)),
                    subtitle: Text(directory ? 'Carpeta' : 'Archivo local'),
                    onTap: () => _open(entry),
                    onLongPress: () => _delete(entry),
                    trailing: directory ? const Icon(Icons.chevron_right) : null,
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: PopupMenuButton<String>(
        tooltip: 'Crear',
        icon: const Icon(Icons.add),
        onSelected: (value) => value == 'folder' ? _createFolder() : _createTextFile(),
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'folder', child: Text('Nueva carpeta')),
          PopupMenuItem(value: 'file', child: Text('Nuevo archivo de texto')),
        ],
      ),
    );
  }

  IconData _iconFor(String path) {
    if (path.toLowerCase().endsWith('.json')) return Icons.data_object;
    if (path.toLowerCase().endsWith('.md')) return Icons.article_outlined;
    if (<String>['.jpg', '.jpeg', '.png', '.gif'].any(path.toLowerCase().endsWith)) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}

class TextPreviewPage extends StatelessWidget {
  const TextPreviewPage({required this.file, super.key});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(file.path.split(Platform.pathSeparator).last)),
      body: FutureBuilder<String>(
        future: file.readAsString(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('No se pudo leer el archivo: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(snapshot.data!),
          );
        },
      ),
    );
  }
}
