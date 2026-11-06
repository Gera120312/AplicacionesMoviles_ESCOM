import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'game_storage_service.dart';

class GameFileTransferService {
  const GameFileTransferService();

  Future<File?> importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['json', 'xml', 'txt'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    final file = File(path);
    if (await file.length() > 5 * 1024 * 1024) {
      throw const FormatException('El archivo supera el límite de 5 MB.');
    }
    return file;
  }

  Future<void> share(SavedGameFile saved) async {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(saved.file.path)],
        text: saved.snapshot.name,
      ),
    );
  }

  Future<String?> export(SavedGameFile saved) async {
    final output = await FilePicker.platform.saveFile(
      fileName: saved.fileName,
      bytes: await saved.file.readAsBytes(),
    );
    return output;
  }
}
