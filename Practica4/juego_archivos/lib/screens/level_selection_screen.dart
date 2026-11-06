import 'package:flutter/material.dart';

import '../controllers/app_settings.dart';
import '../models/game_models.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un nivel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _levelCard(context, GameLevel.basic, Icons.filter_1),
          const SizedBox(height: 16),
          _levelCard(context, GameLevel.advanced, Icons.filter_2),
        ],
      ),
    );
  }

  Widget _levelCard(BuildContext context, GameLevel level, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 34),
                const SizedBox(width: 12),
                Text(
                  level.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${level.size}×${level.size} · ${level.rounds} rondas · ${level.seconds ~/ 60} minutos',
            ),
            Text(
              level.difficulty == Difficulty.advanced
                  ? 'Incluye casillas bloqueadas y valores del 1 al 15.'
                  : 'Rutas de 2 o 3 casillas con valores del 1 al 9.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(level: level, settings: settings),
                ),
              ),
              child: const Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }
}
