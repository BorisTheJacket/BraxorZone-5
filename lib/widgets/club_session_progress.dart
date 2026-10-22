import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_assets.dart';

class ClubSessionProgress extends StatelessWidget {
  final AnimationController spinController;
  final double currentProgress;
  final double totalProgress;

  const ClubSessionProgress({
    super.key,
    required this.spinController,
    required this.currentProgress,
    required this.totalProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surface,
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpinningBadge(),
              const SizedBox(height: 36),
              _buildTitle(),
              const SizedBox(height: 28),
              _buildProgressBar(),
              const SizedBox(height: 16),
              _buildPercentageText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinningBadge() {
    return AnimatedBuilder(
      animation: spinController,
      builder: (context, child) {
        return Transform.rotate(
          angle: spinController.value * 2 * 3.14159,
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDim],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                AppAssets.logo,
                width: 60,
                height: 60,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.sports_baseball,
                  size: 48,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.primary, AppColors.textPrimary],
      ).createShader(bounds),
      child: Text(
        'Initializing...',
        style: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 260,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              width: totalProgress > 0 ? 260 * (currentProgress / totalProgress) : 0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDim],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageText() {
    final int percent = totalProgress > 0
        ? ((currentProgress / totalProgress * 100).clamp(0, 100)).toInt()
        : 0;
    return Text(
      '$percent%',
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 1.0,
      ),
    );
  }
}

typedef InitializationScreen = ClubSessionProgress;
