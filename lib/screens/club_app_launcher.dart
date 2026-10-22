import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/club_zone_coordinator.dart';
import '../utils/club_zone_config.dart';
import '../widgets/club_session_progress.dart';
import '../widgets/club_venue_portal.dart';
import '../widgets/club_sync_dialog.dart';
import 'splash_screen.dart';

class ClubAppLauncher extends StatefulWidget {
  const ClubAppLauncher({super.key});

  @override
  State<ClubAppLauncher> createState() => _ClubAppLauncherState();
}

class _ClubAppLauncherState extends State<ClubAppLauncher>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  double _currentProgress = 0;
  final double _totalProgress = 100;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showMainMenu = false;
  String? _zoneResource;
  String? _baseResource;
  bool _hasNavigatedFromBase = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startAppInitialization();
  }

  void _setupAnimation() {
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  Future<void> _startAppInitialization() async {
    final coordinator = ClubZoneCoordinator(
      onComplete: _handleInitializationComplete,
      onError: _handleInitializationError,
      onShowMainMenu: _handleShowMainMenu,
      onProgressUpdate: _updateProgress,
    );

    await coordinator.startInitialization();
  }

  void _handleInitializationComplete() async {
    await _loadZoneResource();

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _hasError = false;
        _showMainMenu = false;
      });
    }
  }

  void _handleInitializationError() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _showMainMenu = false;
      });
    }
  }

  void _handleShowMainMenu() {
    if (mounted) {
      setState(() {
        _showMainMenu = true;
        _hasError = false;
        _isInitialized = false;
      });
    }
  }

  void _updateProgress(double current, double total) {
    if (mounted) {
      setState(() {
        _currentProgress = current;
      });
    }
  }

  Future<void> _loadZoneResource() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedResource = prefs.getString(ClubZoneConfig.savedSessionTokenKey);
    final String effectiveResource = savedResource ?? ClubZoneConfig.defaultVenueHub;

    if (mounted) {
      setState(() {
        _zoneResource = effectiveResource;
        _baseResource = ClubZoneConfig.defaultVenueHub;
      });
    }
  }

  void _handleResourceChanged(String newResource) {
    if (mounted) {
      setState(() {
        if (newResource != _baseResource && "$newResource/" != _baseResource) {
          _hasNavigatedFromBase = true;
        }
      });
    }
  }

  void _handleClose() {
    if (mounted) {
      setState(() {
        _isInitialized = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showMainMenu) {
      return const SplashScreen();
    }

    if (_hasError) {
      return const ClubSyncDialog();
    }

    if (!_isInitialized) {
      return ClubSessionProgress(
        spinController: _spinController,
        currentProgress: _currentProgress,
        totalProgress: _totalProgress,
      );
    }

    if (_zoneResource == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClubVenuePortal(
      zoneResource: _zoneResource!,
      initialZoneResource: _baseResource,
      hasNavigatedFromBase: _hasNavigatedFromBase,
      onClose: _handleClose,
      onNavigationChanged: _handleResourceChanged,
    );
  }
}

typedef AppLauncher = ClubAppLauncher;
