import 'package:flutter/material.dart';

import '../models/file_entry.dart';

class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({
    required this.entries,
    required this.onNavigate,
    super.key,
  });

  final List<FileEntry> entries;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (var index = 0; index < entries.length; index++) ...<Widget>[
          if (index > 0) const Icon(Icons.chevron_right, size: 18),
          TextButton(
            onPressed: () => onNavigate(entries[index].path),
            child: Text(index == 0 ? 'Inicio' : entries[index].name),
          ),
        ],
      ],
    );
  }
}
