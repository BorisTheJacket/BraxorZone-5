import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/progress_provider.dart';
import '../screens/home_screen.dart';
import '../screens/offers_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/qr_screen.dart';
import '../screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    OffersScreen(),
    BookingScreen(),
    QrScreen(),
    ProfileScreen(),
  ];

  static const _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_offer_outlined),
      activeIcon: Icon(Icons.local_offer_rounded),
      label: 'Offers',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today_rounded),
      label: 'Booking',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.qr_code_scanner_rounded),
      activeIcon: Icon(Icons.qr_code_scanner_rounded),
      label: 'QR',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShellTabController(
      switchTab: (i) => setState(() => _index = i),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            body: IndexedStack(index: _index, children: _tabs),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                items: _items,
              ),
            ),
          ),
          const _AchievementBanner(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Achievement banner overlay — slides in from top, auto-dismisses after 3 s
// ─────────────────────────────────────────────────────────────────────────────

class _AchievementBanner extends StatefulWidget {
  const _AchievementBanner();

  @override
  State<_AchievementBanner> createState() => _AchievementBannerState();
}

class _AchievementBannerState extends State<_AchievementBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;
  String? _shownId;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(
            begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _show() {
    _ctrl.forward(from: 0);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    _timer?.cancel();
    _ctrl.reverse().then((_) {
      if (mounted) {
        context.read<ProgressProvider>().dismissNotification();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (_, provider, __) {
        final notif = provider.nextNotification;

        if (notif != null && notif.missionId != _shownId) {
          _shownId = notif.missionId;
          WidgetsBinding.instance.addPostFrameCallback((_) => _show());
        }

        if (notif == null) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.55),
                            width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.emoji_events_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Achievement Unlocked!',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  notif.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${notif.xp} XP',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Allows any child widget to switch the shell's active tab
// ─────────────────────────────────────────────────────────────────────────────

class ShellTabController extends InheritedWidget {
  final void Function(int) switchTab;

  const ShellTabController({
    super.key,
    required this.switchTab,
    required super.child,
  });

  static ShellTabController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellTabController>();

  @override
  bool updateShouldNotify(ShellTabController old) =>
      switchTab != old.switchTab;
}
