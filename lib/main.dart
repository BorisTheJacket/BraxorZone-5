import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'providers/score_tracker_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D0D),
  ));

  final userProvider = UserProvider();
  await userProvider.load();

  final progressProvider = ProgressProvider();
  await progressProvider.load();

  final notifProvider = NotificationProvider();
  await notifProvider.load();

  // Wire achievements → notification centre
  progressProvider.onAchievementUnlocked = (title, xp) {
    notifProvider.add(NotificationProvider.makeAchievement(title, xp));
  };
  progressProvider.onTierChanged = (tierName) {
    notifProvider.add(NotificationProvider.makeTierUp(tierName));
  };

  runApp(BraxorZoneApp(
    userProvider: userProvider,
    progressProvider: progressProvider,
    notifProvider: notifProvider,
  ));
}

class BraxorZoneApp extends StatelessWidget {
  final UserProvider userProvider;
  final ProgressProvider progressProvider;
  final NotificationProvider notifProvider;
  const BraxorZoneApp({
    super.key,
    required this.userProvider,
    required this.progressProvider,
    required this.notifProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: progressProvider),
        ChangeNotifierProvider.value(value: notifProvider),
        ChangeNotifierProvider(create: (_) => ScoreTrackerProvider()),
      ],
      child: MaterialApp(
        title: 'BraxorZone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRouter.launcher,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          final screenW = mq.size.width;
          final screenH = mq.size.height;
          const maxW = 480.0;

          // Small phones (e.g. iPhone SE ≈ 667 pt): scale text down 10 %
          // so fixed-height containers don't overflow.
          final textScale = screenH < 700 ? 0.9 : 1.0;

          // iPad: centre content at phone width
          if (screenW > maxW) {
            final inner = MediaQuery(
              data: mq.copyWith(
                size: Size(maxW, screenH),
                padding: mq.padding,
                viewInsets: mq.viewInsets,
                textScaler: TextScaler.linear(textScale),
              ),
              child: SizedBox(width: maxW, child: child!),
            );
            return ColoredBox(
              color: AppColors.background,
              child: Center(child: inner),
            );
          }

          // Small phone: only adjust text scale
          if (textScale < 1.0) {
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            );
          }

          return child!;
        },
      ),
    );
  }
}
