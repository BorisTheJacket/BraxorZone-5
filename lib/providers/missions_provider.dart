import 'package:flutter/foundation.dart';
import '../models/mission_model.dart';

class MissionsProvider extends ChangeNotifier {
  late List<MissionModel> _missions;

  MissionsProvider() {
    _missions = List.from(MissionModel.initial);
  }

  List<MissionModel> get missions => List.unmodifiable(_missions);

  List<MissionModel> get completedMissions =>
      _missions.where((m) => m.status == MissionStatus.completed).toList();

  List<MissionModel> get inProgressMissions =>
      _missions.where((m) => m.status == MissionStatus.inProgress).toList();

  void updateProgress(String id, int newCurrent) {
    final i = _missions.indexWhere((m) => m.id == id);
    if (i == -1) return;
    final m = _missions[i];
    final updated = MissionModel(
      id: m.id,
      title: m.title,
      description: m.description,
      current: newCurrent.clamp(0, m.target),
      target: m.target,
      status: newCurrent >= m.target
          ? MissionStatus.completed
          : m.status == MissionStatus.locked
              ? MissionStatus.locked
              : MissionStatus.inProgress,
      iconAsset: m.iconAsset,
      rewardPoints: m.rewardPoints,
    );
    _missions[i] = updated;
    notifyListeners();
  }
}
