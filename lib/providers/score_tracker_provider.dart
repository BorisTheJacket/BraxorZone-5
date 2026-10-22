import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/player_model.dart';

class ScoreTrackerProvider extends ChangeNotifier {
  final List<PlayerModel> _players = [];
  int _seconds = 0;
  bool _running = false;
  bool _matchStarted = false;
  String? _currentPlayer;

  List<PlayerModel> get players      => List.unmodifiable(_players);
  int               get seconds      => _seconds;
  bool              get running      => _running;
  bool              get matchStarted => _matchStarted;
  String?           get currentPlayer => _currentPlayer;

  int get totalBalls => _players.fold(0, (s, p) => s + p.ballsScored);
  int get totalFouls => _players.fold(0, (s, p) => s + p.fouls);

  String get formattedTime {
    final h = _seconds ~/ 3600;
    final m = (_seconds % 3600) ~/ 60;
    final s = _seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void addPlayer(String name) {
    final id = '${name}_${DateTime.now().millisecondsSinceEpoch}';
    _players.add(PlayerModel(
      id: id,
      name: name,
      ballsScored: 0,
      fouls: 0,
      avatarIndex: Random().nextInt(3),
    ));
    _currentPlayer ??= _players.first.name;
    notifyListeners();
  }

  void removePlayer(String id) {
    _players.removeWhere((p) => p.id == id);
    _currentPlayer = _players.isNotEmpty ? _players.first.name : null;
    notifyListeners();
  }

  void increment(String id) {
    final i = _players.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _players[i] = _players[i].copyWith(ballsScored: _players[i].ballsScored + 1);
    _currentPlayer = _players[i].name;
    notifyListeners();
  }

  void decrement(String id) {
    final i = _players.indexWhere((p) => p.id == id);
    if (i == -1 || _players[i].ballsScored == 0) return;
    _players[i] = _players[i].copyWith(ballsScored: _players[i].ballsScored - 1);
    notifyListeners();
  }

  void addFoul(String id) {
    final i = _players.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _players[i] = _players[i].copyWith(fouls: _players[i].fouls + 1);
    notifyListeners();
  }

  void tick() {
    if (_running) {
      _seconds++;
      notifyListeners();
    }
  }

  void startMatch() {
    _matchStarted = true;
    _running = true;
    notifyListeners();
  }

  void pauseTimer() {
    _running = false;
    notifyListeners();
  }

  void endMatch() {
    _running = false;
    _matchStarted = false;
    _players.clear();
    _seconds = 0;
    _currentPlayer = null;
    notifyListeners();
  }
}
