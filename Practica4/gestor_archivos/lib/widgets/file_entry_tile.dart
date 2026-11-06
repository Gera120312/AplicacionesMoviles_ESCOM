import 'dart:io';

import 'package:flutter/material.dart';

import '../models/file_entry.dart';
import 'file_icon.dart';

class FileEntryTile extends StatelessWidget {
  const FileEntryTile({
    required this.entry,
    required this.onOpen,
    this.onLongPress,
    this.onMore,
    this.selected = false,
    this.grid = false,
    super.key,
  });

  final FileEntry entry;
  final VoidCallback onOpen;
  final VoidCallback? onLongPress;
  final VoidCallback? onMore;
  final bool selected;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final details = '${entry.readableSize} · ${entryTypeLabel(entry.type)}';
    if (grid) {
      return Card(
        color: selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onOpen,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _leadingIcon(entry, 42),
                const SizedBox(height: 10),
                Text(
                  entry.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(details, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
      child: ListTile(
        leading: _leadingIcon(entry, 40),
        title: Text(entry.name),
        subtitle: Text(details),
        trailing: IconButton(
          onPressed: onMore,
          icon: const Icon(Icons.more_vert),
          tooltip: 'Más opciones',
        ),
        onTap: onOpen,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget _leadingIcon(FileEntry entry, double size) {
    if (entry.type == FileEntryType.image &&
        !entry.path.startsWith('content://') &&
        !entry.path.startsWith('selected://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(entry.path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: 256,
          errorBuilder: (context, error, stackTrace) =>
              FileIcon(type: entry.type, size: size),
        ),
      );
    }
    return FileIcon(type: entry.type, size: size);
  }
}
