import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_settings.dart';
import '../controllers/game_controller.dart';
import '../models/game_models.dart';
import '../models/save_models.dart';
import '../services/game_storage_service.dart';
import 'home_screen.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.level,
    required this.settings,
    this.snapshot,
    super.key,
  });

  final GameLevel level;
  final AppSettings settings;
  final GameSnapshot? snapshot;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final GameController controller;
  final GameStorageService storage = GameStorageService();
  Timer? autosaveTimer;
  bool recoveryCleared = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = GameController(
      level: widget.level,
      soundsEnabled: widget.settings.sounds,
      animationsEnabled: widget.settings.animations,
      snapshot: widget.snapshot,
    );
    controller.addListener(_scheduleAutosave);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.pause();
      _saveRecovery();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_scheduleAutosave);
    autosaveTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _scheduleAutosave() {
    autosaveTimer?.cancel();
    autosaveTimer = Timer(const Duration(milliseconds: 700), _saveRecovery);
  }

  Future<void> _saveRecovery() async {
    if (!mounted || controller.isOver) return;
    try {
      await storage.saveRecovery(
        controller.snapshot(
          id: 'recovery',
          name: 'Recuperación automática',
          settings: _saveSettings,
        ),
      );
    } on Object {
      // Recovery must never interrupt the current game.
    }
  }

  SaveSettings get _saveSettings => SaveSettings(
    accent: widget.settings.accent.name,
    brightness: widget.settings.themeMode.name,
    sounds: widget.settings.sounds,
    animations: widget.settings.animations,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (controller.isOver) {
          if (!recoveryCleared) {
            recoveryCleared = true;
            storage.deleteRecovery();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultsScreen(
                    result: controller.result(),
                    settings: widget.settings,
                    snapshot: controller.snapshot(
                      id: 'result-${DateTime.now().microsecondsSinceEpoch}',
                      name: 'Partida finalizada',
                      settings: _saveSettings,
                    ),
                  ),
                ),
              );
            }
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.level.name} · ${controller.score} pts'),
            actions: <Widget>[
              IconButton(
                onPressed: controller.status == GameStatus.playing
                    ? controller.pause
                    : controller.resume,
                icon: Icon(
                  controller.status == GameStatus.paused
                      ? Icons.play_arrow
                      : Icons.pause,
                ),
                tooltip: controller.status == GameStatus.paused
                    ? 'Reanudar'
                    : 'Pausar',
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    _statusCard(context),
                    const SizedBox(height: 12),
                    _board(context, constraints.maxWidth),
                    const SizedBox(height: 12),
                    if (controller.feedback != null)
                      AnimatedContainer(
                        duration: widget.settings.animations
                            ? const Duration(milliseconds: 250)
                            : Duration.zero,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: controller.feedback!.startsWith('¡')
                              ? Colors.green.withValues(alpha: .18)
                              : Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          controller.feedback!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 12),
                    _actions(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statusCard(BuildContext context) {
    final urgent = controller.remainingSeconds <= 15;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Ronda ${controller.round}/${widget.level.rounds}'),
                Text(
                  'Objetivo: ${controller.board.target}',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${controller.remainingSeconds ~/ 60}:${(controller.remainingSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: urgent ? Colors.red : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: controller.progress),
            const SizedBox(height: 10),
            Text(
              'Suma actual: ${controller.currentSum}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _board(BuildContext context, double width) {
    final boardWidth = (width - 8).clamp(240.0, 560.0);
    return SizedBox(
      width: boardWidth,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.board.tiles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.level.size,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final tile = controller.board.tiles[index];
          final selected = controller.selected.contains(index);
          final hinted = controller.highlightedHint == index;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: .92, end: 1),
            duration: widget.settings.animations
                ? const Duration(milliseconds: 180)
                : Duration.zero,
            builder: (context, scale, child) =>
                Transform.scale(scale: selected ? 1 : scale, child: child),
            child: InkWell(
              onTap: tile.blocked ? null : () => controller.select(index),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tile.blocked
                      ? Colors.grey.shade700
                      : selected
                      ? Theme.of(context).colorScheme.primary
                      : hinted
                      ? Colors.amber.withValues(alpha: .7)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: tile.blocked
                    ? const Icon(Icons.block, color: Colors.white)
                    : Text(
                        '${tile.value}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : null,
                            ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilledButton.icon(
          onPressed: controller.check,
          icon: const Icon(Icons.check),
          label: const Text('Comprobar'),
        ),
        OutlinedButton.icon(
          onPressed: controller.undo,
          icon: const Icon(Icons.undo),
          label: const Text('Deshacer'),
        ),
        OutlinedButton.icon(
          onPressed: () => _saveDialog(context),
          icon: const Icon(Icons.save),
          label: const Text('Guardar partida'),
        ),
        OutlinedButton.icon(
          onPressed: controller.clearRoute,
          icon: const Icon(Icons.clear),
          label: const Text('Limpiar'),
        ),
        OutlinedButton.icon(
          onPressed: controller.hint,
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('Pista'),
        ),
        TextButton(
          onPressed: () => _pauseDialog(context),
          child: const Text('Pausa'),
        ),
      ],
    );
  }

  Future<void> _saveDialog(BuildContext context) async {
    final nameController = TextEditingController(text: 'Partida de Ruta');
    final tagsController = TextEditingController();
    var category = SaveCategory.practice;
    final request = await showDialog<_SaveRequest>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Guardar partida'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                DropdownButtonFormField<SaveCategory>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: SaveCategory.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => category = value!),
                ),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Etiquetas',
                    hintText: 'separadas por comas',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Formato: ${widget.settings.saveFormat.label}'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _SaveRequest(
                  name: nameController.text,
                  category: category,
                  tags: tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList(),
                ),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    tagsController.dispose();
    if (!context.mounted || request == null) return;
    try {
      final snapshot = controller.snapshot(
        id: 'game-${DateTime.now().microsecondsSinceEpoch}',
        name: request.name.trim(),
        settings: _saveSettings,
        category: request.category,
        tags: request.tags,
      );
      await storage.save(snapshot, widget.settings.saveFormat);
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

  Future<void> _pauseDialog(BuildContext context) async {
    controller.pause();
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Partida pausada'),
        content: const Text('El temporizador está detenido.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'resume'),
            child: const Text('Reanudar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'restart'),
            child: const Text('Reiniciar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, 'menu'),
            child: const Text('Menú principal'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'resume':
        controller.resume();
      case 'restart':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GameScreen(level: widget.level, settings: widget.settings),
          ),
        );
      case 'menu':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(settings: widget.settings),
          ),
          (route) => false,
        );
    }
  }
}

class _SaveRequest {
  const _SaveRequest({
    required this.name,
    required this.category,
    required this.tags,
  });

  final String name;
  final SaveCategory category;
  final List<String> tags;
}
