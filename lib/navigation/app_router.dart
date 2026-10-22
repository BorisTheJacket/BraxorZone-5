import 'package:flutter/material.dart';
import '../screens/club_app_launcher.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/register_screen.dart';
import '../screens/password_login_screen.dart';
import '../screens/account_settings_screen.dart';
import '../navigation/main_shell.dart';
import '../screens/tournaments_screen.dart';
import '../screens/prices_screen.dart';
import '../screens/club_rules_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/score_tracker_screen.dart';

class AppRouter {
  AppRouter._();

  static const String launcher        = '/';
  static const String splash          = '/splash';
  static const String onboarding      = '/onboarding';
  static const String register        = '/register';
  static const String passwordLogin    = '/password-login';
  static const String main            = '/main';
  static const String accountSettings = '/account-settings';
  static const String tournaments     = '/tournaments';
  static const String prices          = '/prices';
  static const String clubRules       = '/club-rules';
  static const String tasks           = '/tasks';
  static const String scoreTracker    = '/score-tracker';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case launcher:
        return _fade(settings, const ClubAppLauncher());
      case splash:
        return _fade(settings, const SplashScreen());
      case onboarding:
        return _fade(settings, const OnboardingScreen());
      case register:
        return _fade(settings, const RegisterScreen());
      case passwordLogin:
        return _fade(settings, const PasswordLoginScreen());
      case main:
        return _fade(settings, const MainShell());
      case accountSettings:
        return _slide(settings, const AccountSettingsScreen());
      case tournaments:
        return _slide(settings, const TournamentsScreen());
      case prices:
        return _slide(settings, const PricesScreen());
      case clubRules:
        return _expandFade(settings, const ClubRulesScreen());
      case tasks:
        return _slide(settings, const TasksScreen());
      case scoreTracker:
        return _slide(settings, const ScoreTrackerScreen());
      default:
        return _fade(settings, const SplashScreen());
    }
  }

  static PageRouteBuilder _fade(RouteSettings s, Widget page) {
    return PageRouteBuilder(
      settings: s,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static PageRouteBuilder _expandFade(RouteSettings s, Widget page) {
    return PageRouteBuilder(
      settings: s,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(
            parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.93, end: 1.0).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slide(RouteSettings s, Widget page) {
    return PageRouteBuilder(
      settings: s,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: anim.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }
}
