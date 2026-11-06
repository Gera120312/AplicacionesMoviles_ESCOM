import 'package:flutter/material.dart';

import '../models/save_models.dart';
import '../services/game_storage_service.dart';

class SaveFileViewerScreen extends StatefulWidget {
  const SaveFileViewerScreen({required this.saved, super.key});

  final SavedGameFile saved;

  @override
  State<SaveFileViewerScreen> createState() => _SaveFileViewerScreenState();
}

class _SaveFileViewerScreenState extends State<SaveFileViewerScreen> {
  late Future<String> content;

  @override
  void initState() {
    super.initState();
    content = widget.saved.file.readAsString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.saved.fileName)),
      body: FutureBuilder<String>(
        future: content,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${widget.saved.format.label} · ${widget.saved.size} bytes\n'
                  'Modificado: ${widget.saved.snapshot.modifiedAt.toLocal()}\n'
                  'Ubicación privada: ${widget.saved.file.path}',
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: widget.saved.format == SaveFormat.txt
                      ? SelectableText(
                          snapshot.data!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        )
                      : SelectableText.rich(
                          TextSpan(
                            children: _syntaxSpans(
                              snapshot.data!,
                              Theme.of(context),
                            ),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<TextSpan> _syntaxSpans(String content, ThemeData theme) {
    final pattern = RegExp(
      r'"(?:\\.|[^"\\])*"|<\/?[\w:-]+[^>]*>|\b(?:true|false|null)\b|-?\b\d+(?:\.\d+)?\b',
    );
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in pattern.allMatches(content)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: content.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      final color = token.startsWith('<')
          ? Colors.deepPurple
          : token.startsWith('"')
          ? Colors.blue
          : Colors.teal;
      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(color: color),
        ),
      );
      cursor = match.end;
    }
    if (cursor < content.length) {
      spans.add(TextSpan(text: content.substring(cursor)));
    }
    return spans;
  }
}
