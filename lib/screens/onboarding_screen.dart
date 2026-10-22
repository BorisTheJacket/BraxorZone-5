import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/hex_background.dart';
import '../navigation/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _titles = ['Convenient offers', 'Easy Start'];
  static const _subtitles = [
    'User-friendly interface will provide a pleasant and fast experience',
    "It's easy to get started, our user-friendly app will help you with this, and it's full of interesting features.",
  ];

  void _next() {
    if (_page < 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _go();
    }
  }

  void _go() => Navigator.pushReplacementNamed(context, AppRouter.register);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final safeTop = MediaQuery.paddingOf(context).top;
    final isSmall = screenH < 700;
    // Small phones: 48 % so text / buttons don't get squished
    final imageH = screenH * (isSmall ? 0.48 : 0.55);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Фон ──────────────────────────────────────────────────────
          HexBackground(child: const SizedBox.expand()),

          // ── 2. Основний контент ─────────────────────────────────────────
          Column(
            children: [
              // Зображення (фіксована висота) — PageView тільки для картинок
              SizedBox(
                height: imageH,
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    // Слайд 1 — просто зображення
                    Image.asset(
                      AppAssets.onboarding1,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: Colors.transparent),
                    ),
                    // Слайд 2 — порожній (зображення з loyalty card — в outer Stack)
                    const SizedBox.expand(),
                  ],
                ),
              ),

              // Текстова секція з анімацією fade + slide при зміні слайду
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, isSmall ? 12 : 20, 24, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 340),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.10),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey(_page),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _titles[_page],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _subtitles[_page],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Нижня панель: крапки + кнопка
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, isSmall ? 14 : 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: 2,
                        effect: ExpandingDotsEffect(
                          dotColor: Colors.white24,
                          activeDotColor: AppColors.primary,
                          dotHeight: 6,
                          dotWidth: 6,
                          expansionFactor: 4,
                          spacing: 5,
                        ),
                      ),
                      SizedBox(height: isSmall ? 12 : 18),
                      SizedBox(
                        width: double.infinity,
                        height: isSmall ? 46 : 52,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 3. onboarding_2.png — в outer Stack, вище тексту по z-порядку ──
          // IgnorePointer → свайпи проходять крізь зображення до PageView
          Positioned(
            top: safeTop + imageH * 0.32,
            left: 0,
            right: 0,
            height: imageH * 0.85,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _page == 1 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                child: Image.asset(
                  AppAssets.onboarding2,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Colors.transparent),
                ),
              ),
            ),
          ),

          // ── 4. Верхня панель (логотип + SKIP) поверх зображення ─────────
          // Positioned щоб уникнути tight constraints від StackFit.expand
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Логотип PNG
                    Image.asset(
                      AppAssets.logo,
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const _LogoFallback(),
                    ),
                    const Spacer(),
                    // SKIP PNG
                    GestureDetector(
                      onTap: _go,
                      child: Image.asset(
                        AppAssets.skipBtn,
                        height: 22,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          'SKIP',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Текстовий fallback логотипу (поки PNG не завантажено) ─────────────────────

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BRAXOR',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        ),
        Text(
          'ZONE',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
