import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class WorksiteNotificationManager {
  static const String _projectId = '425bc721-39f4-490b-b3e3-3c63b750da3a';

  bool _isReady = false;

  // Singleton
  static final WorksiteNotificationManager _instance = WorksiteNotificationManager._internal();
  factory WorksiteNotificationManager() => _instance;
  WorksiteNotificationManager._internal();

  // Simple logger helper
  void _log(String message) => debugPrint('[WorksiteNotificationManager] $message');

  // Generic error-safe wrapper
  Future<T?> _safeCall<T>(String action, Future<T?> Function() fn) async {
    try {
      return await fn();
    } catch (e, st) {
      _log('Error during $action: $e');
      if (kDebugMode) {
        _log('$st');
      }
      return null;
    }
  }

  Future<void> ignite(String contractorId) async {
    if (_isReady) return;

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      OneSignal.initialize(_projectId);

      await _safeCall('setContractorIdentity', () async {
        await _setContractorIdentity(contractorId);
        return null;
      });

      await _safeCall('requestProjectPermissions', () async {
        await _requestProjectPermissions();
        return null;
      });

      _setupProjectHandlers();
      _isReady = true;

      _log('Ignited successfully');
    } catch (e) {
      _log('Error igniting: $e');
    }
  }

  Future<void> _setContractorIdentity(String contractorId) async {
    if (contractorId.isEmpty) return;
    try {
      await OneSignal.login(contractorId);
      _log('Contractor identity set: $contractorId');
    } catch (e) {
      _log('Error setting contractor identity: $e');
    }
  }

  Future<void> _requestProjectPermissions() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
      _log('Requested notification permission');
    } catch (e) {
      _log('Error requesting permissions: $e');
    }
  }

  void _setupProjectHandlers() {
    _setCheckpointReminderHandler();
    _setBlueprintClickHandler();
    _setProjectMessageHandler();
  }

  void _setCheckpointReminderHandler() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final notification = event.notification;
      _log('Checkpoint reminder received: ${notification.title}');
    });
  }

  void _setBlueprintClickHandler() {
    OneSignal.Notifications.addClickListener((event) {
      _log('Blueprint clicked');
    });
  }

  void _setProjectMessageHandler() {
    OneSignal.InAppMessages.addClickListener((event) {
      _log('In-app message clicked');
    });
  }

  bool _ensureReady(String action) {
    if (!_isReady) {
      _log('Warning: not ready when calling $action');
      return false;
    }
    return true;
  }

  Future<void> setCheckpointTag(String key, String value) async {
    if (!_ensureReady('setCheckpointTag')) return;
    await _safeCall('setCheckpointTag', () async {
      await OneSignal.User.addTags({key: value});
      _log('Checkpoint tag set: $key = $value');
      return null;
    });
  }

  Future<void> removeCheckpointTag(String key) async {
    if (!_ensureReady('removeCheckpointTag')) return;
    await _safeCall('removeCheckpointTag', () async {
      await OneSignal.User.removeTag(key);
      _log('Checkpoint tag removed: $key');
      return null;
    });
  }

  Future<void> setMultipleCheckpointTags(Map<String, String> tags) async {
    if (!_ensureReady('setMultipleCheckpointTags')) return;
    await _safeCall('setMultipleCheckpointTags', () async {
      await OneSignal.User.addTags(tags);
      _log('Multiple checkpoint tags set: ${tags.keys.join(', ')}');
      return null;
    });
  }

  Future<String?> getDeviceId() async {
    if (!_ensureReady('getDeviceId')) return null;
    return await _safeCall<String?>('getDeviceId', () async {
      final pushSubscription = OneSignal.User.pushSubscription;
      final deviceId = pushSubscription.id;
      _log('Device ID: $deviceId');
      return deviceId;
    });
  }

  Future<bool> isProjectPermissionGranted() async {
    final result = await _safeCall<bool>('isProjectPermissionGranted', () async {
      final permission = OneSignal.Notifications.permission;
      return permission;
    });
    return result ?? false;
  }

  Future<void> retire() async {
    if (!_isReady) return;
    await _safeCall('retire', () async {
      await OneSignal.logout();
      _isReady = false;
      _log('Retired from notifications');
      return null;
    });
  }

  void extinguish() {
    _isReady = false;
  }
}

typedef WorksiteNotificationService = WorksiteNotificationManager;

