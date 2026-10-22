import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/hex_background.dart';
import '../navigation/app_router.dart';
import '../worksite_notification_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeIn));
    _scale = Tween(begin: 0.82, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack)));

    _ctrl.forward();
    _initNotifications();
    Future.delayed(const Duration(milliseconds: 2600), _navigate);
  }

  void _initNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contractorId = prefs.getString('contractorId') ?? prefs.getString('contractor_id') ?? '';
      await WorksiteNotificationService().ignite(contractorId);
    } catch (_) {}
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final registered = await AuthService.isRegistered();
    if (!mounted) return;

    if (!registered) {
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
      return;
    }

    final usePassword = await AuthService.usePasswordOnLaunch();
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      usePassword ? AppRouter.passwordLogin : AppRouter.main,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        assetPath: AppAssets.bgSplash,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _fade.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(
                  children: [
                    const Spacer(),
                    Image.asset(
                      AppAssets.logo,
                      width: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _textLogo(),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'BRAXOR',
          style: GoogleFonts.montserrat(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 6,
          ),
        ),
        Text(
          'ZONE',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
            letterSpacing: 16,
          ),
        ),
      ],
    );
  }
}
