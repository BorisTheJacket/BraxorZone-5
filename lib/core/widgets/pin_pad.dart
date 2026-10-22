import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 4 індикаторних кружечки PIN-коду
class PinDots extends StatelessWidget {
  final int filledCount;
  final bool hasError;

  const PinDots({super.key, required this.filledCount, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    final activeColor = hasError ? AppColors.error : AppColors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? activeColor : Colors.transparent,
            border: Border.all(
              color: filled ? activeColor : AppColors.textHint,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

/// Числова клавіатура 3×4 (1–9, пусто, 0, ⌫)
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const PinKeypad({super.key, required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox.shrink();
        final isDelete = k == '⌫';
        return _PinKey(
          label: k,
          isDelete: isDelete,
          onTap: isDelete ? onDelete : () => onDigit(k),
        );
      }).toList(),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String label;
  final bool isDelete;
  final VoidCallback onTap;

  const _PinKey({required this.label, required this.isDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: isDelete
              ? const Icon(Icons.backspace_outlined, color: AppColors.textSecondary, size: 22)
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
