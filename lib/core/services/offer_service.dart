import 'package:shared_preferences/shared_preferences.dart';

class OfferService {
  OfferService._();

  static const int _maxPerWeek = 2;

  // Week index that resets every Monday (1970-01-05 was the first Monday)
  static String get _weekKey {
    final daysSinceAnchor =
        DateTime.now().difference(DateTime(1970, 1, 5)).inDays;
    return 'w${daysSinceAnchor ~/ 7}';
  }

  static String _prefKey(String offerId) => 'offer_use_${offerId}_$_weekKey';

  static Future<int> getUseCount(String offerId) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_prefKey(offerId)) ?? 0;
  }

  static Future<int> getRemainingUses(String offerId) async {
    final used = await getUseCount(offerId);
    return (_maxPerWeek - used).clamp(0, _maxPerWeek);
  }

  static Future<bool> canClaim(String offerId) async =>
      (await getUseCount(offerId)) < _maxPerWeek;

  static Future<bool> wasWarningShown() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('offer_warning_shown') ?? false;
  }

  static Future<void> markWarningShown() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('offer_warning_shown', true);
  }

  static Future<void> recordClaim(String offerId) async {
    final p = await SharedPreferences.getInstance();
    final key = _prefKey(offerId);
    final current = p.getInt(key) ?? 0;
    if (current < _maxPerWeek) {
      await p.setInt(key, current + 1);
    }
  }

  // Which offer is active today
  static String get activeOfferId {
    switch (DateTime.now().weekday) {
      case DateTime.friday:
        return 'iron_friday';
      case DateTime.wednesday:
      case DateTime.saturday:
        return 'night_lights';
      default:
        return 'double_break';
    }
  }

  // Human-readable schedule for each offer
  static String scheduleLabel(String offerId) {
    switch (offerId) {
      case 'iron_friday':
        return 'Every Friday';
      case 'night_lights':
        return 'Wed & Sat';
      default:
        return 'Mon · Tue · Thu · Sun';
    }
  }
}
