import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_notification.dart';

class NotificationService {
  NotificationService._();

  static const _kKey = 'app_notifications';
  static const _kMaxStored = 50;

  static Future<List<AppNotification>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_kKey) ?? [];
    return raw
        .map((s) => AppNotification.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> add(AppNotification notif) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_kKey) ?? [];
    raw.insert(0, jsonEncode(notif.toJson()));
    if (raw.length > _kMaxStored) raw.removeLast();
    await p.setStringList(_kKey, raw);
  }

  static Future<void> saveAll(List<AppNotification> notifications) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kKey, notifications.map((n) => jsonEncode(n.toJson())).toList());
  }

  static Future<void> clearAll() async {
    (await SharedPreferences.getInstance()).remove(_kKey);
  }
}
