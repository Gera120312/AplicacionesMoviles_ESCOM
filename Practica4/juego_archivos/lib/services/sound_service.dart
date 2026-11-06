import 'package:flutter/services.dart';

class SoundService {
  const SoundService();

  Future<void> tap(bool enabled) async {
    if (enabled) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> result({required bool correct, required bool enabled}) async {
    if (enabled) await SystemSound.play(SystemSoundType.click);
  }
}
