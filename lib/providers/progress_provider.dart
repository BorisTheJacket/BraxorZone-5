import 'package:flutter/foundation.dart';
import '../core/services/progress_service.dart';
import '../models/mission_model.dart';
import '../models/loyalty_tier_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Achievement notification payload
// ─────────────────────────────────────────────────────────────────────────────

class AchievementNotification {
  final String missionId;
  final String title;
  final int xp;
  const AchievementNotification({
    required this.missionId,
    required this.title,
    required this.xp,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class ProgressProvider extends ChangeNotifier {
  int _totalXp    = 0;
  int _totalVisits= 0;
  int _streak     = 0;
  int _earlyBird  = 0;
  int _monthly    = 0;
  int _nightPkg   = 0;
  bool _tournamentDone = false;

  List<MissionModel> _missions = [];
  final List<AchievementNotification> _notifications = [];

  /// Called each time a mission is newly completed — title + xp awarded.
  void Function(String title, int xp)? onAchievementUnlocked;

  /// Called when the loyalty tier changes — passes the new tier name.
  void Function(String tierName)? onTierChanged;

  // ── Getters ────────────────────────────────────────────────────────────────

  int get totalXp     => _totalXp;
  int get totalVisits => _totalVisits;
  int get streak      => _streak;

  List<MissionModel> get missions => List.unmodifiable(_missions);

  List<AchievementNotification> get notifications =>
      List.unmodifiable(_notifications);
  bool get hasNotification => _notifications.isNotEmpty;
  AchievementNotification? get nextNotification =>
      _notifications.isEmpty ? null : _notifications.first;

  LoyaltyTierModel get currentTier {
    final tiers = LoyaltyTierModel.tiers;
    var result = tiers.first;
    for (final t in tiers) {
      if (_totalXp >= t.requiredAmount) result = t;
    }
    return result;
  }

  LoyaltyTierModel? get nextTier {
    final tiers = LoyaltyTierModel.tiers;
    final idx = tiers.indexOf(currentTier);
    return idx < tiers.length - 1 ? tiers[idx + 1] : null;
  }

  /// How many more visits until the next round milestone.
  int get visitsToNextMilestone {
    for (final m in const [5, 10, 20, 50, 100]) {
      if (_totalVisits < m) return m - _totalVisits;
    }
    return 0;
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> load() async {
    final data = await ProgressService.loadAll();
    _totalXp     = data['totalXp']!;
    _totalVisits = data['totalVisits']!;
    _streak      = data['streak']!;
    _earlyBird   = data['earlyBird']!;
    _monthly     = data['monthly']!;
    _nightPkg    = data['nightPkg']!;
    _tournamentDone = await ProgressService.isTournamentDone();
    _missions    = _buildMissions();
    notifyListeners();
  }

  // ── Record a visit ─────────────────────────────────────────────────────────

  Future<void> recordVisit({String package = '', DateTime? time}) async {
    final prevTierName = currentTier.name;
    final t = time ?? DateTime.now();
    final newlyCompleted = await ProgressService.recordVisit(
      time: t,
      package: package,
    );

    for (final id in newlyCompleted) {
      final def = MissionModel.initial.where((m) => m.id == id).toList();
      if (def.isEmpty) continue;
      await ProgressService.addXp(def.first.rewardPoints);
      _notifications.add(AchievementNotification(
        missionId: id,
        title: def.first.title,
        xp: def.first.rewardPoints,
      ));
      onAchievementUnlocked?.call(def.first.title, def.first.rewardPoints);
    }

    await _refresh();

    if (currentTier.name != prevTierName) {
      onTierChanged?.call(currentTier.name);
    }
  }

  // ── Record tournament attendance ───────────────────────────────────────────

  Future<void> recordTournament() async {
    final prevTierName = currentTier.name;
    final isNew = await ProgressService.recordTournament();
    if (!isNew) return;
    await ProgressService.addXp(150);
    _notifications.add(const AchievementNotification(
      missionId: 'm_first_tournament',
      title: 'First Tournament',
      xp: 150,
    ));
    onAchievementUnlocked?.call('First Tournament', 150);
    await _refresh();
    if (currentTier.name != prevTierName) {
      onTierChanged?.call(currentTier.name);
    }
  }

  // ── Dismiss notification ───────────────────────────────────────────────────

  void dismissNotification() {
    if (_notifications.isNotEmpty) {
      _notifications.removeAt(0);
      notifyListeners();
    }
  }

  // ── Reset (called on account delete) ───────────────────────────────────────

  void reset() {
    _totalXp        = 0;
    _totalVisits    = 0;
    _streak         = 0;
    _earlyBird      = 0;
    _monthly        = 0;
    _nightPkg       = 0;
    _tournamentDone = false;
    _notifications.clear();
    _missions = _buildMissions();
    notifyListeners();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    final data = await ProgressService.loadAll();
    _totalXp     = data['totalXp']!;
    _totalVisits = data['totalVisits']!;
    _streak      = data['streak']!;
    _earlyBird   = data['earlyBird']!;
    _monthly     = data['monthly']!;
    _nightPkg    = data['nightPkg']!;
    _tournamentDone = await ProgressService.isTournamentDone();
    _missions    = _buildMissions();
    notifyListeners();
  }

  List<MissionModel> _buildMissions() {
    return MissionModel.initial.map((m) {
      final current = _currentFor(m.id);
      final status = current >= m.target
          ? MissionStatus.completed
          : _isUnlocked(m.id)
              ? MissionStatus.inProgress
              : MissionStatus.locked;
      return MissionModel(
        id: m.id,
        title: m.title,
        description: m.description,
        current: current,
        target: m.target,
        status: status,
        iconAsset: m.iconAsset,
        rewardPoints: m.rewardPoints,
      );
    }).toList();
  }

  int _currentFor(String id) {
    switch (id) {
      case 'm_first_visit':     return _totalVisits.clamp(0, 1);
      case 'm_visit_5':         return _totalVisits.clamp(0, 5);
      case 'm_visit_10':        return _totalVisits.clamp(0, 10);
      case 'm_visit_20':        return _totalVisits.clamp(0, 20);
      case 'm_visit_100':       return _totalVisits.clamp(0, 100);
      case 'm_streak_5':        return _streak.clamp(0, 5);
      case 'm_daily_month':     return _streak.clamp(0, 30);
      case 'm_monthly_10':      return _monthly.clamp(0, 10);
      case 'm_weekday_6pm':     return _earlyBird.clamp(0, 3);
      case 'm_night_3week':     return _nightPkg.clamp(0, 3);
      case 'm_first_tournament':return _tournamentDone ? 1 : 0;
      default:                  return 0;
    }
  }

  bool _isUnlocked(String id) {
    switch (id) {
      case 'm_first_visit':
      case 'm_visit_5':
      case 'm_first_tournament':
      case 'm_streak_5':
      case 'm_weekday_6pm':
        return true;
      case 'm_visit_10':
      case 'm_monthly_10':
        return _totalVisits >= 5;
      case 'm_visit_20':
      case 'm_night_3week':
        return _totalVisits >= 10;
      case 'm_visit_100':
      case 'm_daily_month':
        return _totalVisits >= 20;
      default:
        return false;
    }
  }
}
