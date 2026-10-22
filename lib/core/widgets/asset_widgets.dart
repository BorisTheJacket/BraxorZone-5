import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Icon-sized image loaded from an asset path.
/// Falls back to an empty [SizedBox] when the asset file is not yet present.
class AssetIcon extends StatelessWidget {
  final String path;
  final double size;
  final Color? color;

  const AssetIcon(
    this.path, {
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }
}

/// Full-size / banner image loaded from an asset path.
/// Falls back to a surface-colored box when the asset file is not yet present.
class AssetImg extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AssetImg(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget img = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.surface,
      ),
    );
    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}
