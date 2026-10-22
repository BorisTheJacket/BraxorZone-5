import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  ProgressService._();

  static const _kTotalXp         = 'prog_total_xp';
  static const _kTotalVisits     = 'prog_total_visits';
  static const _kStreak          = 'prog_streak';
  static const _kLastVisitDate   = 'prog_last_visit_date';
  static const _kEarlyBirdVisits = 'prog_early_bird';
  static const _kNightPkgPrefix  = 'prog_night_pkg_';

  static String _monthKey(DateTime d) =>
      'prog_monthly_${d.year}_${d.month}';

  // Week key for night-package counter (resets every Monday)
  static String get _nightWeekKey {
    final anchor = DateTime(1970, 1, 5); // first Monday
    final days = DateTime.now().difference(anchor).inDays;
    return '$_kNightPkgPrefix${days ~/ 7}';
  }

  // ── Load snapshot ──────────────────────────────────────────────────────────

  static Future<Map<String, int>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    return {
      'totalXp'     : p.getInt(_kTotalXp)               ?? 0,
      'totalVisits' : p.getInt(_kTotalVisits)            ?? 0,
      'streak'      : p.getInt(_kStreak)                 ?? 0,
      'earlyBird'   : p.getInt(_kEarlyBirdVisits)        ?? 0,
      'monthly'     : p.getInt(_monthKey(now))           ?? 0,
      'nightPkg'    : p.getInt(_nightWeekKey)            ?? 0,
    };
  }

  // ── Record a visit ─────────────────────────────────────────────────────────
  // Returns IDs of missions that JUST completed this visit.

  static Future<List<String>> recordVisit({
    required DateTime time,
    required String package,
  }) async {
    final p = await SharedPreferences.getInstance();

    // Read previous counters
    final prevVisits   = p.getInt(_kTotalVisits)            ?? 0;
    final prevStreak   = p.getInt(_kStreak)                 ?? 0;
    final prevMonthly  = p.getInt(_monthKey(time))          ?? 0;
    final prevEarlyBird= p.getInt(_kEarlyBirdVisits)        ?? 0;
    final prevNightPkg = p.getInt(_nightWeekKey)            ?? 0;

    // ── Total visits ──────────────────────────────────────────────────────
    final newVisits = prevVisits + 1;
    await p.setInt(_kTotalVisits, newVisits);

    // ── Streak ────────────────────────────────────────────────────────────
    final lastStr = p.getString(_kLastVisitDate);
    final today = _dateStr(time);
    int newStreak = prevStreak;

    if (lastStr == null) {
      newStreak = 1;
    } else {
      final last = DateTime.parse(lastStr);
      final diff = DateTime(time.year, time.month, time.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
      if (diff == 1)      { newStreak++; }
      else if (diff > 1)  { newStreak = 1; }
      // diff == 0 → same day, streak unchanged
    }
    await p.setInt(_kStreak, newStreak);
    await p.setString(_kLastVisitDate, today);

    // ── Monthly visits ────────────────────────────────────────────────────
    final newMonthly = prevMonthly + 1;
    await p.setInt(_monthKey(time), newMonthly);

    // ── Early Bird (weekday, before 18:00) ────────────────────────────────
    int newEarlyBird = prevEarlyBird;
    if (time.weekday <= DateTime.friday && time.hour < 18) {
      newEarlyBird++;
      await p.setInt(_kEarlyBirdVisits, newEarlyBird);
    }

    // ── Night package ─────────────────────────────────────────────────────
    int newNightPkg = prevNightPkg;
    if (package.toLowerCase().contains('night')) {
      newNightPkg++;
      await p.setInt(_nightWeekKey, newNightPkg);
    }

    // ── Detect newly completed missions ───────────────────────────────────
    final newlyCompleted = <String>[];

    void check(String id, bool wasDone, bool nowDone) {
      if (!wasDone && nowDone) newlyCompleted.add(id);
    }

    check('m_first_visit',    prevVisits  >= 1,  newVisits    >= 1);
    check('m_visit_5',        prevVisits  >= 5,  newVisits    >= 5);
    check('m_visit_10',       prevVisits  >= 10, newVisits    >= 10);
    check('m_visit_20',       prevVisits  >= 20, newVisits    >= 20);
    check('m_visit_100',      prevVisits  >= 100,newVisits    >= 100);
    check('m_streak_5',       prevStreak  >= 5,  newStreak    >= 5);
    check('m_monthly_10',     prevMonthly >= 10, newMonthly   >= 10);
    check('m_weekday_6pm',    prevEarlyBird >= 3,newEarlyBird >= 3);
    check('m_night_3week',    prevNightPkg >= 3, newNightPkg  >= 3);
    check('m_daily_month',    prevStreak  >= 30, newStreak    >= 30);

    return newlyCompleted;
  }

  // ── XP ────────────────────────────────────────────────────────────────────

  static Future<void> addXp(int xp) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kTotalXp, (p.getInt(_kTotalXp) ?? 0) + xp);
  }

  // ── Tournament (manual trigger) ───────────────────────────────────────────

  static Future<bool> recordTournament() async {
    final p = await SharedPreferences.getInstance();
    const key = 'prog_tournament_done';
    if (p.getBool(key) ?? false) return false; // already done
    await p.setBool(key, true);
    return true;
  }

  static Future<bool> isTournamentDone() async =>
      (await SharedPreferences.getInstance()).getBool('prog_tournament_done') ?? false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
