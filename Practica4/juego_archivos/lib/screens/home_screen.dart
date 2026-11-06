import 'package:flutter/material.dart';

import '../controllers/app_settings.dart';
import '../services/game_storage_service.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'level_selection_screen.dart';
import 'saved_games_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.settings, super.key});

  final AppSettings settings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = GameStorageService();
  bool recoveryChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRecovery());
  }

  Future<void> _checkRecovery() async {
    if (recoveryChecked) return;
    recoveryChecked = true;
    try {
      final saved = await storage.readRecovery();
      if (!mounted || saved == null) return;
      final action = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Partida recuperable'),
          content: const Text(
            'Se encontró una sesión interrumpida. ¿Deseas continuarla?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'discard'),
              child: const Text('Descartar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'continue'),
              child: const Text('Continuar partida'),
            ),
          ],
        ),
      );
      if (action == 'discard') {
        await storage.deleteRecovery();
      } else if (action == 'continue' && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
              level: saved.snapshot.level,
              settings: widget.settings,
              snapshot: saved.snapshot,
            ),
          ),
        );
      }
    } on Object {
      await storage.deleteRecovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 32),
                  Icon(
                    Icons.route,
                    size: 78,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ruta de Sumas',
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conecta casillas adyacentes y alcanza el objetivo exacto.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  _menuButton(
                    context,
                    'Jugar',
                    Icons.play_arrow_rounded,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LevelSelectionScreen(settings: widget.settings),
                      ),
                    ),
                  ),
                  _menuButton(
                    context,
                    'Partidas guardadas',
                    Icons.folder_open,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SavedGamesScreen(settings: widget.settings),
                      ),
                    ),
                  ),
                  _menuButton(
                    context,
                    'Configuración',
                    Icons.settings,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SettingsScreen(settings: widget.settings),
                      ),
                    ),
                  ),
                  _menuButton(
                    context,
                    'Cómo jugar',
                    Icons.help_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HowToPlayScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Práctica 4 · ESCOM-IPN',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Padding(padding: const EdgeInsets.all(6), child: Text(label)),
        ),
      ),
    );
  }
}
