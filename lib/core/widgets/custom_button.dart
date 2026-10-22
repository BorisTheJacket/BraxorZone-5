import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum BtnVariant { primary, accent, outlined, ghost }

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = BtnVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    switch (widget.variant) {
      case BtnVariant.outlined:
        return OutlinedButton(
          onPressed: widget.onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _content(AppColors.primary),
        );
      case BtnVariant.ghost:
        return TextButton(
          onPressed: widget.onTap,
          child: _content(AppColors.textSecondary),
        );
      case BtnVariant.accent:
        return _gradientBtn(AppColors.greenGradient, Colors.black);
      case BtnVariant.primary:
        return _gradientBtn(AppColors.greenGradient, Colors.white);
    }
  }

  Widget _gradientBtn(List<Color> colors, Color textColor) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _pressed
                  ? []
                  : [
                      BoxShadow(
                        color: colors.first.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(child: _content(textColor)),
          ),
        ),
      ),
    );
  }

  Widget _content(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
