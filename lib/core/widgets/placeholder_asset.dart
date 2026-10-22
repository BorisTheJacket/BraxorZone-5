import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Placeholder for image assets.
/// TODO: Replace with Image.asset(assetPath, fit: fit, ...) when sprites are ready.
class PlaceholderAsset extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final Color? tint;

  const PlaceholderAsset({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tint ?? AppColors.surface,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, color: AppColors.textHint, size: 26),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                assetPath.split('/').last,
                style: GoogleFonts.inter(fontSize: 9, color: AppColors.textHint),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    if (width != null || height != null) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: inner,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AspectRatio(aspectRatio: aspectRatio, child: inner),
    );
  }
}
