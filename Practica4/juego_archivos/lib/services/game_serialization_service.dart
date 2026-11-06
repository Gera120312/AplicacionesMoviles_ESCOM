import 'dart:convert';

import 'package:xml/xml.dart';

import '../models/save_models.dart';

class GameSerializationService {
  const GameSerializationService();

  String encode(GameSnapshot snapshot, SaveFormat format) => switch (format) {
    SaveFormat.json => const JsonEncoder.withIndent(
      '  ',
    ).convert(snapshot.toMap()),
    SaveFormat.xml => _encodeXml(snapshot),
    SaveFormat.txt => _encodeTxt(snapshot),
  };

  GameSnapshot decode(String content, SaveFormat? hint) {
    if (content.trim().isEmpty) {
      throw const FormatException('El archivo está vacío.');
    }
    final format = hint ?? detect(content);
    try {
      return switch (format) {
        SaveFormat.json => GameSnapshot.fromMap(
          _asMap(jsonDecode(content), 'JSON'),
        ),
        SaveFormat.xml => GameSnapshot.fromMap(_xmlToMap(content)),
        SaveFormat.txt => GameSnapshot.fromMap(_txtToMap(content)),
      };
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Archivo ${format.label} inválido: $error');
    }
  }

  SaveFormat detect(String content) {
    final trimmed = content.trimLeft();
    if (trimmed.startsWith('{')) return SaveFormat.json;
    if (trimmed.startsWith('<')) return SaveFormat.xml;
    if (trimmed.startsWith('RUTA_DE_SUMAS_SAVE')) return SaveFormat.txt;
    throw const FormatException('No se pudo identificar el formato.');
  }

  String _encodeXml(GameSnapshot snapshot) {
    final map = snapshot.toMap();
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'gameSave',
      attributes: <String, String>{
        'version': '${snapshot.schemaVersion}',
        'app': 'ruta_de_sumas',
      },
      nest: () {
        _xmlScalar(builder, 'id', map['id']);
        _xmlScalar(builder, 'name', map['name']);
        _xmlScalar(builder, 'level', map['level']);
        for (final key in <String>[
          'round',
          'totalRounds',
          'score',
          'elapsedSeconds',
          'remainingSeconds',
          'status',
          'createdAt',
          'modifiedAt',
          'hints',
          'attempts',
          'category',
        ]) {
          _xmlScalar(builder, key, map[key]);
        }
        _xmlList(builder, 'tags', 'tag', map['tags'] as List<Object>);
        final board = map['board'] as Map<String, Object>;
        builder.element(
          'board',
          nest: () {
            _xmlScalar(builder, 'size', board['size']);
            _xmlScalar(builder, 'target', board['target']);
            _xmlList(
              builder,
              'solution',
              'index',
              board['solution'] as List<Object>,
            );
            builder.element(
              'tiles',
              nest: () {
                for (final item in board['tiles'] as List<Object>) {
                  final tile = item as Map<String, Object>;
                  builder.element(
                    'tile',
                    attributes: <String, String>{
                      'index': '${tile['index']}',
                      'value': '${tile['value']}',
                      'blocked': '${tile['blocked']}',
                    },
                  );
                }
              },
            );
          },
        );
        _xmlList(
          builder,
          'selectedPath',
          'index',
          map['selectedPath'] as List<Object>,
        );
        final settings = map['settings'] as Map<String, Object>;
        builder.element(
          'settings',
          nest: () {
            settings.forEach((key, value) => _xmlScalar(builder, key, value));
          },
        );
        builder.element(
          'moveHistory',
          nest: () {
            for (final item in map['moveHistory'] as List<Object>) {
              final move = item as Map<String, Object?>;
              builder.element(
                'move',
                attributes: <String, String>{
                  'type': '${move['type']}',
                  'order': '${move['order']}',
                  if (move['tileIndex'] != null)
                    'tileIndex': '${move['tileIndex']}',
                  if (move['points'] != null) 'points': '${move['points']}',
                },
              );
            }
          },
        );
      },
    );
    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _xmlScalar(XmlBuilder builder, String name, Object? value) {
    builder.element(name, nest: value?.toString());
  }

  void _xmlList(
    XmlBuilder builder,
    String name,
    String itemName,
    List<Object> values,
  ) {
    builder.element(
      name,
      nest: () {
        for (final value in values) {
          _xmlScalar(builder, itemName, value);
        }
      },
    );
  }

  String _encodeTxt(GameSnapshot snapshot) {
    final map = snapshot.toMap();
    final board = map['board'] as Map<String, Object>;
    final settings = map['settings'] as Map<String, Object>;
    final lines = <String>[
      'RUTA_DE_SUMAS_SAVE',
      'VERSION=${snapshot.schemaVersion}',
      'ID=${snapshot.id}',
      'NAME=${_escape(map['name'])}',
      'LEVEL=${map['level']}',
      'ROUND=${map['round']}',
      'TOTAL_ROUNDS=${map['totalRounds']}',
      'SCORE=${map['score']}',
      'ELAPSED_SECONDS=${map['elapsedSeconds']}',
      'REMAINING_SECONDS=${map['remainingSeconds']}',
      'STATUS=${map['status']}',
      'CREATED_AT=${map['createdAt']}',
      'MODIFIED_AT=${map['modifiedAt']}',
      'HINTS=${map['hints']}',
      'ATTEMPTS=${map['attempts']}',
      'CATEGORY=${map['category']}',
      'TAGS=${(map['tags'] as List<Object>).map(_escape).join(',')}',
      '',
      '[BOARD]',
      'SIZE=${board['size']}',
      'TARGET=${board['target']}',
      'SOLUTION=${(board['solution'] as List<Object>).join(',')}',
      'TILES',
      ...(board['tiles'] as List<Object>).map((item) {
        final tile = item as Map<String, Object>;
        return '${tile['index']}|${tile['value']}|${tile['blocked']}';
      }),
      '',
      '[SELECTED_PATH]',
      (map['selectedPath'] as List<Object>).join(','),
      '',
      '[SETTINGS]',
      'ACCENT=${settings['accent']}',
      'BRIGHTNESS=${settings['brightness']}',
      'SOUNDS=${settings['sounds']}',
      'ANIMATIONS=${settings['animations']}',
      '',
      '[MOVE_HISTORY]',
      ...(map['moveHistory'] as List<Object>).map((item) {
        final move = item as Map<String, Object?>;
        return [
          '${move['type']}',
          '${move['order']}',
          '${move['tileIndex'] ?? ''}',
          '${move['points'] ?? ''}',
        ].join('|');
      }),
    ];
    return '${lines.join('\n')}\n';
  }

  String _escape(Object? value) => base64UrlEncode(utf8.encode('$value'));

  Map<String, Object?> _txtToMap(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    if (lines.isEmpty || lines.first != 'RUTA_DE_SUMAS_SAVE') {
      throw const FormatException('Encabezado TXT inválido.');
    }
    final values = <String, String>{};
    var section = '';
    final tiles = <Map<String, Object>>[];
    final moves = <Map<String, Object?>>[];
    final selected = <int>[];
    final solution = <int>[];
    final settings = <String, Object>{};
    var boardSize = 0;
    var target = 0;
    var readingTiles = false;
    for (final line in lines.skip(1)) {
      if (line.startsWith('[') && line.endsWith(']')) {
        section = line.substring(1, line.length - 1);
        readingTiles = false;
        continue;
      }
      if (section == 'BOARD' && line == 'TILES') {
        readingTiles = true;
        continue;
      }
      if (section == 'BOARD' && readingTiles && line.isNotEmpty) {
        final parts = line.split('|');
        if (parts.length != 3) {
          throw const FormatException('Casilla TXT inválida.');
        }
        tiles.add(<String, Object>{
          'index': int.parse(parts[0]),
          'value': int.parse(parts[1]),
          'blocked': _parseBool(parts[2]),
        });
        continue;
      }
      if (section == 'MOVE_HISTORY' && line.isNotEmpty) {
        final parts = line.split('|');
        if (parts.length != 4) {
          throw const FormatException('Movimiento TXT inválido.');
        }
        moves.add(<String, Object?>{
          'type': parts[0],
          'order': int.parse(parts[1]),
          'tileIndex': parts[2].isEmpty ? null : int.parse(parts[2]),
          'points': parts[3].isEmpty ? null : int.parse(parts[3]),
        });
        continue;
      }
      if (section == 'SELECTED_PATH' && line.isNotEmpty) {
        selected.addAll(_parseInts(line));
        continue;
      }
      if (line.isEmpty || !line.contains('=')) continue;
      final separator = line.indexOf('=');
      final key = line.substring(0, separator);
      final value = line.substring(separator + 1);
      if (section == 'SETTINGS') {
        settings[key] = switch (key) {
          'SOUNDS' || 'ANIMATIONS' => _parseBool(value),
          _ => value,
        };
      } else if (section == 'BOARD') {
        if (key == 'SIZE') boardSize = int.parse(value);
        if (key == 'TARGET') target = int.parse(value);
        if (key == 'SOLUTION') solution.addAll(_parseInts(value));
      } else if (section == 'SELECTED_PATH') {
        selected.addAll(_parseInts(value));
      } else {
        values[key] = value;
      }
    }
    final tags = values['TAGS'] == null
        ? <String>[]
        : values['TAGS']!
              .split(',')
              .where((value) => value.isNotEmpty)
              .map((value) => utf8.decode(base64Url.decode(value)))
              .toList();
    return <String, Object?>{
      'schemaVersion': int.parse(values['VERSION']!),
      'app': 'ruta_de_sumas',
      'id': values['ID']!,
      'name': utf8.decode(base64Url.decode(values['NAME']!)),
      'level': values['LEVEL']!,
      'round': int.parse(values['ROUND']!),
      'totalRounds': int.parse(values['TOTAL_ROUNDS']!),
      'score': int.parse(values['SCORE']!),
      'elapsedSeconds': int.parse(values['ELAPSED_SECONDS']!),
      'remainingSeconds': int.parse(values['REMAINING_SECONDS']!),
      'status': values['STATUS']!,
      'createdAt': values['CREATED_AT']!,
      'modifiedAt': values['MODIFIED_AT']!,
      'hints': int.parse(values['HINTS']!),
      'attempts': int.parse(values['ATTEMPTS']!),
      'category': values['CATEGORY']!,
      'tags': tags,
      'board': <String, Object>{
        'size': boardSize,
        'target': target,
        'solution': solution,
        'tiles': tiles,
      },
      'selectedPath': selected,
      'settings': <String, Object?>{
        'accent': settings['ACCENT'],
        'brightness': settings['BRIGHTNESS'],
        'sounds': settings['SOUNDS'],
        'animations': settings['ANIMATIONS'],
      },
      'moveHistory': moves,
    };
  }

  bool _parseBool(String value) {
    if (value == 'true') return true;
    if (value == 'false') return false;
    throw const FormatException('Booleano inválido.');
  }

  List<int> _parseInts(String value) =>
      value.isEmpty ? <int>[] : value.split(',').map(int.parse).toList();

  Map<String, Object?> _xmlToMap(String content) {
    final root = XmlDocument.parse(content).rootElement;
    if (root.name.local != 'gameSave') {
      throw const FormatException('Elemento XML raíz inválido.');
    }
    String text(String name) =>
        root.getElement(name)?.innerText ??
        (throw FormatException('Elemento XML faltante: $name'));
    List<int> list(String parent, String child) => root
        .getElement(parent)!
        .findElements(child)
        .map((element) => int.parse(element.innerText))
        .toList();
    final boardElement = root.getElement('board');
    if (boardElement == null) {
      throw const FormatException('Tablero faltante.');
    }
    final tilesElement = boardElement.getElement('tiles');
    if (tilesElement == null) {
      throw const FormatException('Casillas faltantes.');
    }
    final tiles = tilesElement.findElements('tile').map((tile) {
      return <String, Object>{
        'index': int.parse(tile.getAttribute('index')!),
        'value': int.parse(tile.getAttribute('value')!),
        'blocked': _parseBool(tile.getAttribute('blocked')!),
      };
    }).toList();
    final settingsElement = root.getElement('settings');
    final movesElement = root.getElement('moveHistory');
    if (settingsElement == null || movesElement == null) {
      throw const FormatException('Secciones XML faltantes.');
    }
    return <String, Object?>{
      'schemaVersion': int.parse(root.getAttribute('version') ?? ''),
      'app': root.getAttribute('app'),
      'id': text('id'),
      'name': text('name'),
      'level': text('level'),
      'round': int.parse(text('round')),
      'totalRounds': int.parse(text('totalRounds')),
      'score': int.parse(text('score')),
      'elapsedSeconds': int.parse(text('elapsedSeconds')),
      'remainingSeconds': int.parse(text('remainingSeconds')),
      'status': text('status'),
      'createdAt': text('createdAt'),
      'modifiedAt': text('modifiedAt'),
      'hints': int.parse(text('hints')),
      'attempts': int.parse(text('attempts')),
      'category': text('category'),
      'tags': root
          .getElement('tags')!
          .findElements('tag')
          .map((element) => element.innerText)
          .toList(),
      'board': <String, Object>{
        'size': int.parse(boardElement.getElement('size')!.innerText),
        'target': int.parse(boardElement.getElement('target')!.innerText),
        'solution': boardElement
            .getElement('solution')!
            .findElements('index')
            .map((element) => int.parse(element.innerText))
            .toList(),
        'tiles': tiles,
      },
      'selectedPath': list('selectedPath', 'index'),
      'settings': <String, Object?>{
        'accent': settingsElement.getElement('accent')?.innerText,
        'brightness': settingsElement.getElement('brightness')?.innerText,
        'sounds': _parseBool(settingsElement.getElement('sounds')!.innerText),
        'animations': _parseBool(
          settingsElement.getElement('animations')!.innerText,
        ),
      },
      'moveHistory': movesElement.findElements('move').map((move) {
        return <String, Object?>{
          'type': move.getAttribute('type'),
          'order': int.parse(move.getAttribute('order')!),
          'tileIndex': move.getAttribute('tileIndex') == null
              ? null
              : int.parse(move.getAttribute('tileIndex')!),
          'points': move.getAttribute('points') == null
              ? null
              : int.parse(move.getAttribute('points')!),
        };
      }).toList(),
    };
  }

  Map<String, Object?> _asMap(Object? value, String format) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.map((key, value) => MapEntry('$key', value));
    throw FormatException('$format inválido.');
  }
}
