import 'package:flutter/material.dart';

import '../models/file_entry.dart';

class FileIcon extends StatelessWidget {
  const FileIcon({required this.type, this.size = 40, super.key});

  final FileEntryType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      FileEntryType.folder => (Icons.folder, Colors.amber.shade700),
      FileEntryType.text => (Icons.description_outlined, Colors.blueGrey),
      FileEntryType.markdown => (Icons.article_outlined, Colors.indigo),
      FileEntryType.json => (Icons.data_object, Colors.orange),
      FileEntryType.xml => (Icons.code, Colors.deepOrange),
      FileEntryType.image => (Icons.image_outlined, Colors.teal),
      FileEntryType.unknown => (Icons.insert_drive_file_outlined, Colors.grey),
    };
    return Icon(icon, size: size, color: color);
  }
}
