import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:xml/xml.dart';

import '../models/file_entry.dart';
import '../providers/app_state.dart';
import '../widgets/file_icon.dart';

class TextViewerScreen extends StatelessWidget {
  const TextViewerScreen({
    required this.entry,
    required this.appState,
    super.key,
  });

  final FileEntry entry;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return _AsyncViewer(
      title: entry.name,
      future: appState.readBytes(entry),
      builder: (bytes) {
        final content = _decodeUtf8(bytes);
        if (entry.type == FileEntryType.markdown) {
          return MarkdownBody(data: content);
        }
        return SelectableText(content, style: const TextStyle(height: 1.6));
      },
    );
  }
}

class CodeViewerScreen extends StatelessWidget {
  const CodeViewerScreen({
    required this.entry,
    required this.appState,
    super.key,
  });

  final FileEntry entry;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return _AsyncViewer(
      title: entry.name,
      future: appState.readBytes(entry),
      builder: (bytes) {
        final original = _decodeUtf8(bytes);
        var formatted = original;
        String? parseError;
        if (entry.type == FileEntryType.json) {
          try {
            formatted = const JsonEncoder.withIndent('  ')
                .convert(jsonDecode(original));
          } on FormatException catch (error) {
            parseError = 'JSON inválido: ${error.message}';
          }
        } else {
          try {
            formatted = XmlDocument.parse(original).toXmlString(pretty: true);
          } on XmlException catch (error) {
            parseError = 'XML inválido: ${error.message}';
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (parseError != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('$parseError\nSe muestra el contenido original.'),
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                formatted,
                language: entry.type == FileEntryType.json ? 'json' : 'xml',
                theme: githubTheme,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    required this.entry,
    required this.appState,
    super.key,
  });

  final FileEntry entry;
  final AppState appState;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final TransformationController _transform = TransformationController();
  int _rotation = 0;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AsyncViewer(
      title: widget.entry.name,
      future: widget.appState.readBytes(widget.entry),
      builder: (bytes) => Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: InteractiveViewer(
              transformationController: _transform,
              minScale: .5,
              maxScale: 6,
              child: RotatedBox(
                quarterTurns: _rotation,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('La imagen está dañada o no es compatible.'),
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: <Widget>[
              IconButton(
                onPressed: () =>
                    setState(() => _rotation = (_rotation + 1) % 4),
                icon: const Icon(Icons.rotate_right),
                tooltip: 'Rotar 90 grados',
              ),
              IconButton(
                onPressed: () {
                  _rotation = 0;
                  _transform.value = Matrix4.identity();
                  setState(() {});
                },
                icon: const Icon(Icons.restart_alt),
                tooltip: 'Restablecer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FileDetailsScreen extends StatelessWidget {
  const FileDetailsScreen({required this.entry, super.key});

  final FileEntry entry;

  @override
  Widget build(BuildContext context) {
    return _ViewerScaffold(
      title: 'Detalles',
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: FileIcon(type: entry.type),
              title: Text(entry.name),
            ),
            _detail('Tipo', entryTypeLabel(entry.type)),
            _detail('Tamaño', entry.readableSize),
            _detail('Fecha de creación', _date(entry.created)),
            _detail('Fecha de modificación', _date(entry.modified)),
            _detail('Ubicación', entry.path),
            _detail('MIME/UTType', entry.mimeType ?? 'No disponible'),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) =>
      ListTile(title: Text(label), subtitle: Text(value));

  String _date(DateTime? value) =>
      value?.toLocal().toString() ?? 'No disponible';
}

class _AsyncViewer extends StatelessWidget {
  const _AsyncViewer({
    required this.title,
    required this.future,
    required this.builder,
  });

  final String title;
  final Future<Uint8List?> future;
  final Widget Function(Uint8List bytes) builder;

  @override
  Widget build(BuildContext context) {
    return _ViewerScaffold(
      title: title,
      child: FutureBuilder<Uint8List?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Text(
              'No se pudo leer el archivo. Verifica que siga disponible.',
            );
          }
          try {
            return builder(snapshot.data!);
          } on FormatException catch (error) {
            return Text(
              'No se pudo decodificar el contenido UTF-8: ${error.message}',
            );
          }
        },
      ),
    );
  }
}

class _ViewerScaffold extends StatelessWidget {
  const _ViewerScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

String _decodeUtf8(Uint8List bytes) =>
    utf8.decode(bytes, allowMalformed: false);
