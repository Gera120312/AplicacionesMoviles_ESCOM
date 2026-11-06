import 'package:flutter/material.dart';

import '../controllers/app_settings.dart';
import '../models/game_models.dart';
import '../models/save_models.dart';
import '../services/game_storage_service.dart';
import 'home_screen.dart';
import 'level_selection_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    required this.result,
    required this.settings,
    required this.snapshot,
    super.key,
  });

  final GameResult result;
  final AppSettings settings;
  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                Icon(
                  result.won ? Icons.emoji_events : Icons.timer_off,
                  size: 80,
                  color: result.won
                      ? Colors.amber
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  result.won ? '¡Victoria!' : 'Tiempo agotado',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        _row('Nivel', result.level.name),
                        _row('Puntuación', '${result.score}'),
                        _row(
                          'Rondas completadas',
                          '${result.roundsCompleted}/${result.level.rounds}',
                        ),
                        _row('Intentos', '${result.attempts}'),
                        _row('Pistas utilizadas', '${result.hints}'),
                        _row(
                          'Tiempo transcurrido',
                          '${result.elapsedSeconds} s',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LevelSelectionScreen(settings: settings),
                    ),
                  ),
                  child: const Text('Jugar otra vez'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(settings: settings),
                    ),
                    (route) => false,
                  ),
                  child: const Text('Volver al menú'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _saveResult(context),
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar partida'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveResult(BuildContext context) async {
    try {
      await GameStorageService().save(snapshot, settings.saveFormat);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Partida guardada.')));
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
      }
    }
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
