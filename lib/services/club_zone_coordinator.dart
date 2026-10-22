import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/club_zone_config.dart';
import 'club_venue_gateway.dart';
import '../worksite_notification_manager.dart';

class ClubZoneCoordinator {
  final VoidCallback onComplete;
  final VoidCallback onError;
  final VoidCallback onShowMainMenu;
  final Function(double, double) onProgressUpdate;

  final WorksiteNotificationService _worksiteNotificationService = WorksiteNotificationService();

  bool _shouldRetrySync = true;
  bool _shouldShowVenuePortal = false;
  bool _shouldShowMainMenu = false;

  ClubZoneCoordinator({
    required this.onComplete,
    required this.onError,
    required this.onShowMainMenu,
    required this.onProgressUpdate,
  });

  Future<void> startInitialization() async {
    await _checkTargetDate();
    await _igniteNotifications();

    if (!await _checkConnection()) {
      await _handleUnreachableVenue();
      return;
    }

    await _performInitializationSteps();
  }

  Future<void> _igniteNotifications() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String contractorId = prefs.getString('contractorId') ?? prefs.getString('contractor_id') ?? '';
      await _worksiteNotificationService.ignite(contractorId);
    } catch (_) {}
  }

  Future<void> _checkTargetDate() async {
    final DateTime currentDate = DateTime.now();
    final DateTime targetDate = DateTime(2024, 12, 3);

    if (!currentDate.isAfter(targetDate)) {
      return;
    }
  }

  Future<bool> _checkConnection() async {
    return await ClubVenueGateway.isVenueReachable();
  }

  Future<void> _handleUnreachableVenue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool isRequested = (prefs.getInt(ClubZoneConfig.syncRequestedKey) ?? 0) == 1;
    final bool gotAnswer = (prefs.getInt(ClubZoneConfig.syncResponseKey) ?? 0) == 1;
    final bool isPermitted = (prefs.getInt(ClubZoneConfig.memberClearanceKey) ?? 0) == 1;

    await _igniteNotifications();

    if (isRequested && gotAnswer && !isPermitted) {
      onShowMainMenu();
      return;
    }

    onError();
  }

  Future<void> _performInitializationSteps() async {
    const totalSteps = 100.0;

    for (double step = 0; step <= totalSteps; step++) {
      await Future.delayed(const Duration(milliseconds: 50));
      onProgressUpdate(step, totalSteps);

      if (step == 50) {
        await _handleRequests();
      }
    }

    if (_shouldShowVenuePortal) {
      onComplete();
    } else if (_shouldShowMainMenu) {
      onShowMainMenu();
    }
  }

  Future<void> _handleRequests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool isRequested = (prefs.getInt(ClubZoneConfig.syncRequestedKey) ?? 0) == 1;
    final bool gotAnswer = (prefs.getInt(ClubZoneConfig.syncResponseKey) ?? 0) == 1;
    final bool isPermitted = (prefs.getInt(ClubZoneConfig.memberClearanceKey) ?? 0) == 1;
    final bool hasSavedPath = prefs.containsKey(ClubZoneConfig.savedSessionTokenKey);

    if ((!isRequested || !hasSavedPath) && !gotAnswer) {
      await _dispatchSync(false);
    } else if (isPermitted) {
      await _igniteNotifications();
      _shouldShowVenuePortal = true;
    } else {
      await _igniteNotifications();
      _shouldShowMainMenu = true;
    }
  }

  Future<void> _dispatchSync(bool useDeepSync) async {
    try {
      final http.Response response = await ClubVenueGateway.dispatchVenueSync(
        useDeepSync,
        ClubZoneConfig.defaultVenueHub,
      );
      await _handleSyncResponse(response);
    } catch (e) {
      await _igniteNotifications();
      _shouldShowMainMenu = true;
    }
  }

  Future<void> _handleSyncResponse(http.Response response) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ClubZoneConfig.syncRequestedKey, 1);

    await _evaluateSyncStatusCode(response);
    await prefs.setInt(ClubZoneConfig.syncResponseKey, 1);
  }

  Future<void> _evaluateSyncStatusCode(http.Response response) async {
    if (response.statusCode == 405 && _shouldRetrySync) {
      _shouldRetrySync = false;
      await _dispatchSync(true);
    } else if (response.statusCode == 404) {
      await _igniteNotifications();
      _shouldShowMainMenu = true;
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      await _inspectVenuePayload();
    } else {
      await _igniteNotifications();
      _shouldShowMainMenu = true;
    }
  }

  Future<void> _inspectVenuePayload() async {
    try {
      final http.Response contentResponse = await http.get(
        Uri.parse(ClubZoneConfig.defaultVenueHub),
      );

      if (contentResponse.statusCode == 200) {
        await _analyzeContent(contentResponse.body);
      } else {
        await _igniteNotifications();
        _shouldShowMainMenu = true;
      }
    } catch (e) {
      await _igniteNotifications();
      _shouldShowMainMenu = true;
    }
  }

  Future<void> _analyzeContent(String pageContent) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String contractorId = prefs.getString('contractorId') ?? prefs.getString('contractor_id') ?? '';

    if (pageContent.contains(ClubZoneConfig.clubPassSignature)) {
      await _worksiteNotificationService.ignite(contractorId);
      _shouldShowMainMenu = true;
    } else {
      await prefs.setInt(ClubZoneConfig.memberClearanceKey, 1);
      await _worksiteNotificationService.ignite(contractorId);
      _shouldShowVenuePortal = true;
    }
  }
}

typedef LoadingManager = ClubZoneCoordinator;
typedef AppInitializer = ClubZoneCoordinator;
