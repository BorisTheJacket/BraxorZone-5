import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../utils/club_zone_config.dart';

class ClubVenuePortal extends StatefulWidget {
  final String zoneResource;
  final String? initialZoneResource;
  final bool hasNavigatedFromBase;
  final VoidCallback onClose;
  final Function(String) onNavigationChanged;

  const ClubVenuePortal({
    super.key,
    required this.zoneResource,
    this.initialZoneResource,
    required this.hasNavigatedFromBase,
    required this.onClose,
    required this.onNavigationChanged,
  });

  @override
  State<ClubVenuePortal> createState() => _ClubVenuePortalState();
}

class _ClubVenuePortalState extends State<ClubVenuePortal> {
  WebViewController? _portalController;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _ensureStatusBarVisible();
    _enableOrientationRotation();
    _initPortalEngine();
  }

  @override
  void dispose() {
    _restoreOrientation();
    super.dispose();
  }

  void _ensureStatusBarVisible() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF0D0D0D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _enableOrientationRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initPortalEngine() async {
    late final PlatformWebViewControllerCreationParams creationParams;

    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      creationParams = AndroidWebViewControllerCreationParams();
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      creationParams = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      creationParams = const PlatformWebViewControllerCreationParams();
    }

    _portalController = WebViewController.fromPlatformCreationParams(creationParams)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(_setupPortalNavigation())
      ..enableZoom(true)
      ..loadRequest(Uri.parse(widget.zoneResource));

    if (_portalController!.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_portalController!.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setGeolocationPermissionsPromptCallbacks(
          onShowPrompt: (request) async {
            return const GeolocationPermissionsResponse(
              allow: true,
              retain: true,
            );
          },
        );
    }
  }

  NavigationDelegate _setupPortalNavigation() {
    return NavigationDelegate(
      onPageStarted: _onPortalSectionStart,
      onPageFinished: _onPortalSectionFinish,
      onWebResourceError: _onPortalSectionError,
      onNavigationRequest: _onPortalNavigationRequest,
    );
  }

  Future<void> _onPortalSectionStart(String path) async {
    widget.onNavigationChanged(path);
  }

  bool _shouldBlockNavigation(String path) {
    if (widget.initialZoneResource == null) return false;
    return widget.hasNavigatedFromBase &&
        ("$path/" == widget.initialZoneResource || path == widget.initialZoneResource);
  }

  NavigationDecision _onPortalNavigationRequest(NavigationRequest request) {
    if (_shouldBlockNavigation(request.url)) {
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _onPortalSectionFinish(String path) async {
    await _persistSessionPath(path);
    await _updatePortalState();
  }

  Future<void> _persistSessionPath(String path) async {
    if (path.isEmpty) return;
    if (widget.initialZoneResource != null &&
        ("$path/" == widget.initialZoneResource || path == widget.initialZoneResource)) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(ClubZoneConfig.savedSessionTokenKey)) {
      await prefs.setString(ClubZoneConfig.savedSessionTokenKey, path);
    }
  }

  void _onPortalSectionError(WebResourceError error) {
    if (_isMissingSection(error)) {
      widget.onClose();
      return;
    }
    _refreshPortal();
  }

  bool _isMissingSection(WebResourceError error) {
    return error.description.contains("404");
  }

  void _refreshPortal() {
    _portalController?.reload();
  }

  Future<void> _stepBack() async {
    if (await _canStepBack()) {
      await _portalController!.goBack();
    }
  }

  Future<bool> _canStepBack() async {
    return _portalController != null && await _portalController!.canGoBack();
  }

  Future<void> _updatePortalState() async {
    final canGoBack = await _canStepBack();
    if (mounted && canGoBack != _canGoBack) {
      setState(() {
        _canGoBack = canGoBack;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _canStepBack()) {
          await _stepBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildPortalAppBar(),
        body: _buildPortalBody(),
      ),
    );
  }

  PreferredSizeWidget _buildPortalAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _canGoBack ? _stepBack : null,
          tooltip: 'Back',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshPortal,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPortalBody() {
    return _portalController != null
        ? WebViewWidget(controller: _portalController!)
        : const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
  }
}

typedef ContentViewScreen = ClubVenuePortal;
typedef WebViewScreen = ClubVenuePortal;
typedef BrowserScreen = ClubVenuePortal;
