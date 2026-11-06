import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/game_models.dart';
import '../models/save_models.dart';
import '../services/game_generator.dart';
import '../services/sound_service.dart';

class GameController extends ChangeNotifier {
  GameController({
    required this.level,
    required this.soundsEnabled,
    required this.animationsEnabled,
    int? seed,
    GameSnapshot? snapshot,
  }) : _generator = GameGenerator(random: seed == null ? null : Random(seed)),
       _sound = const SoundService() {
    if (snapshot == null) {
      _startRound();
    } else {
      _restore(snapshot);
    }
  }

  final GameLevel level;
  final bool soundsEnabled;
  final bool animationsEnabled;
  final GameGenerator _generator;
  final SoundService _sound;
  Timer? _timer;
  late GameBoard board;
  final List<int> selected = <int>[];
  final List<GameMove> moves = <GameMove>[];
  GameStatus status = GameStatus.playing;
  int round = 1;
  int score = 0;
  int remainingSeconds = 0;
  int elapsedSeconds = 0;
  int attempts = 0;
  int hints = 0;
  int _order = 0;
  int? highlightedHint;
  String? feedback;

  GameSnapshot snapshot({
    required String id,
    required String name,
    required SaveSettings settings,
    SaveCategory category = SaveCategory.practice,
    List<String> tags = const <String>[],
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return GameSnapshot(
      id: id,
      schemaVersion: 1,
      name: name,
      level: level,
      board: board,
      selectedPath: List<int>.from(selected),
      round: round,
      totalRounds: level.rounds,
      score: score,
      elapsedSeconds: elapsedSeconds,
      remainingSeconds: remainingSeconds,
      status: status,
      createdAt: createdAt ?? now,
      modifiedAt: now,
      settings: settings,
      moves: List<GameMove>.from(moves),
      hints: hints,
      attempts: attempts,
      category: category,
      tags: List<String>.from(tags),
    );
  }

  int get currentSum =>
      selected.fold(0, (sum, index) => sum + board.tiles[index].value);
  double get progress => (round - 1) / level.rounds;
  bool get isOver => status == GameStatus.won || status == GameStatus.lost;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (status != GameStatus.playing) return;
    status = GameStatus.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void resume() {
    if (status != GameStatus.paused) return;
    status = GameStatus.playing;
    start();
    notifyListeners();
  }

  void disposeGame() {
    _timer?.cancel();
    _timer = null;
  }

  void select(int index) {
    if (status != GameStatus.playing ||
        board.tiles[index].blocked ||
        selected.contains(index) ||
        (selected.isNotEmpty &&
            !GameGenerator.adjacent(
              selected.last,
              level.size,
            ).contains(index)) ||
        selected.length >= 4) {
      return;
    }
    selected.add(index);
    moves.add(
      GameMove(type: MoveType.select, order: _order++, tileIndex: index),
    );
    feedback = currentSum > board.target ? 'La suma supera el objetivo' : null;
    _sound.tap(soundsEnabled);
    notifyListeners();
  }

  void undo() {
    if (selected.isEmpty || status != GameStatus.playing) return;
    final index = selected.removeLast();
    moves.add(GameMove(type: MoveType.undo, order: _order++, tileIndex: index));
    feedback = null;
    notifyListeners();
  }

  void clearRoute() {
    if (selected.isEmpty || status != GameStatus.playing) return;
    selected.clear();
    moves.add(GameMove(type: MoveType.clear, order: _order++));
    feedback = null;
    notifyListeners();
  }

  bool check() {
    if (status != GameStatus.playing) return false;
    attempts++;
    final valid =
        selected.length >= 2 &&
        selected.length <= 4 &&
        currentSum == board.target &&
        _isContinuous();
    if (valid) {
      score += 100 + min(50, remainingSeconds ~/ 4);
      moves.add(GameMove(type: MoveType.correct, order: _order++, points: 100));
      feedback = '¡Ruta correcta!';
      _sound.result(correct: true, enabled: soundsEnabled);
      if (round == level.rounds) {
        status = GameStatus.won;
      } else {
        moves.add(GameMove(type: MoveType.roundCompleted, order: _order++));
        round++;
        _startRound();
      }
    } else {
      score = max(0, score - 10);
      moves.add(
        GameMove(type: MoveType.incorrect, order: _order++, points: -10),
      );
      feedback = 'Ruta incorrecta. Revisa adyacencia y suma.';
      _sound.result(correct: false, enabled: soundsEnabled);
    }
    selected.clear();
    notifyListeners();
    return valid;
  }

  void hint() {
    if (status != GameStatus.playing) return;
    score = max(0, score - 20);
    hints++;
    highlightedHint = board.solution.first;
    moves.add(
      GameMove(
        type: MoveType.hint,
        order: _order++,
        tileIndex: highlightedHint,
        points: -20,
      ),
    );
    feedback = 'Pista: prueba la casilla resaltada.';
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      highlightedHint = null;
      notifyListeners();
    });
  }

  GameResult result() => GameResult(
    won: status == GameStatus.won,
    level: level,
    score: score,
    elapsedSeconds: elapsedSeconds,
    roundsCompleted: status == GameStatus.won ? level.rounds : round - 1,
    attempts: attempts,
    hints: hints,
  );

  bool _isContinuous() {
    for (var i = 1; i < selected.length; i++) {
      if (!GameGenerator.adjacent(
        selected[i - 1],
        level.size,
      ).contains(selected[i])) {
        return false;
      }
    }
    return selected.toSet().length == selected.length;
  }

  void _startRound() {
    board = _generator.generate(level);
    selected.clear();
    remainingSeconds = level.seconds;
    feedback = null;
    start();
  }

  void _restore(GameSnapshot snapshot) {
    board = snapshot.board;
    selected
      ..clear()
      ..addAll(snapshot.selectedPath);
    moves
      ..clear()
      ..addAll(snapshot.moves);
    status = snapshot.status;
    round = snapshot.round;
    score = snapshot.score;
    remainingSeconds = snapshot.remainingSeconds;
    elapsedSeconds = snapshot.elapsedSeconds;
    attempts = snapshot.attempts;
    hints = snapshot.hints;
    _order = moves.isEmpty
        ? 0
        : moves.map((move) => move.order).reduce(max) + 1;
    if (status == GameStatus.playing) start();
  }

  void _tick() {
    if (status != GameStatus.playing) return;
    remainingSeconds--;
    elapsedSeconds++;
    if (remainingSeconds <= 0) {
      remainingSeconds = 0;
      status = GameStatus.lost;
      disposeGame();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    disposeGame();
    super.dispose();
  }
}
