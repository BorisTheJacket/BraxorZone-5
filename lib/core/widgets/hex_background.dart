import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class HexBackground extends StatelessWidget {
  final Widget child;
  final String? assetPath;

  const HexBackground({
    super.key,
    required this.child,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    // Current (possibly clamped) width from MediaQuery
    final currentW = MediaQuery.of(context).size.width;
    // Real physical device width (before any MediaQuery override)
    final view = View.of(context);
    final realW = view.physicalSize.width / view.devicePixelRatio;

    // How many px to bleed on each side to fill the full device screen
    final bleed = ((realW - currentW) / 2).clamp(0.0, double.infinity);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -bleed,
          right: -bleed,
          top: 0,
          bottom: 0,
          child: Image.asset(
            assetPath ?? AppAssets.bgHome,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.background),
          ),
        ),
        child,
      ],
    );
  }
}
