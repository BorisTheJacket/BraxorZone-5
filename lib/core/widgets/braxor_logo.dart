import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

class BraxorLogo extends StatelessWidget {
  final double fontSize;

  const BraxorLogo({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    // TODO: Asset ready at assets/images/logo_braxorzone.png
    return Image.asset(
      AppAssets.logo,
      height: fontSize * 1.6,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(height: fontSize * 1.6),
    );
  }
}
