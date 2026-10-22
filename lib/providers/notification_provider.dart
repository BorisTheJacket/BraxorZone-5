import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _items = [];

  List<AppNotification> get notifications => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> load() async {
    _items = await NotificationService.loadAll();
    notifyListeners();
  }

  Future<void> add(AppNotification notif) async {
    await NotificationService.add(notif);
    _items.insert(0, notif);
    notifyListeners();
  }

  Future<void> markAllRead() async {
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    await NotificationService.saveAll(_items);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items = [];
    await NotificationService.clearAll();
    notifyListeners();
  }

  // ── Factory helpers ──────────────────────────────────────────────────────────

  static AppNotification makeWelcome(String name) => AppNotification(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Welcome to BraxorZone, $name!',
        body:
            'Your account is ready. Start booking tables and earning XP.',
        timestamp: DateTime.now(),
        iconType: 'welcome',
        action: 'profile',
      );

  static AppNotification makeBooking(String package, String club) =>
      AppNotification(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Booking Confirmed',
        body: '$package at $club has been reserved for you.',
        timestamp: DateTime.now(),
        iconType: 'booking',
        action: 'booking',
      );

  static AppNotification makeAchievement(String title, int xp) =>
      AppNotification(
        id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Achievement Unlocked: $title',
        body: 'You earned +$xp XP for completing this challenge.',
        timestamp: DateTime.now(),
        iconType: 'achievement',
        action: 'tasks',
      );

  static AppNotification makeTierUp(String tierName) => AppNotification(
        id: 'tier_${DateTime.now().millisecondsSinceEpoch}',
        title: '${tierName[0].toUpperCase()}${tierName.substring(1)} Status Unlocked!',
        body:
            'Congratulations! You\'ve reached $tierName tier. Check your new perks.',
        timestamp: DateTime.now(),
        iconType: 'tier',
        action: 'profile',
      );
}
