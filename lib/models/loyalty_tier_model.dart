import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';

class LoyaltyTierModel {
  final String name;
  final int requiredAmount;
  final int cashbackPercent;
  final String benefit;
  final Color color;
  final String iconAsset;

  const LoyaltyTierModel({
    required this.name,
    required this.requiredAmount,
    required this.cashbackPercent,
    required this.benefit,
    required this.color,
    required this.iconAsset,
  });

  static List<LoyaltyTierModel> get tiers => const [
        LoyaltyTierModel(
          name: 'Rookie',
          requiredAmount: 0,
          cashbackPercent: 1,
          benefit: '1% Cashback',
          color: Color(0xFF78909C),
          iconAsset: AppAssets.tierRookie,
        ),
        LoyaltyTierModel(
          name: 'Player',
          requiredAmount: 1000,
          cashbackPercent: 5,
          benefit: '5% Cashback',
          color: Color(0xFFB0BEC5),
          iconAsset: AppAssets.tierPlayer,
        ),
        LoyaltyTierModel(
          name: 'Pro',
          requiredAmount: 2500,
          cashbackPercent: 10,
          benefit: '10% Cashback',
          color: Color(0xFFD4AF37),
          iconAsset: AppAssets.tierPro,
        ),
        LoyaltyTierModel(
          name: 'Master',
          requiredAmount: 5000,
          cashbackPercent: 15,
          benefit: '15% Cashback',
          color: Color(0xFF80CBC4),
          iconAsset: AppAssets.tierMaster,
        ),
        LoyaltyTierModel(
          name: 'Legend',
          requiredAmount: 10000,
          cashbackPercent: 20,
          benefit: '20% + Gifts',
          color: Color(0xFF80D8FF),
          iconAsset: AppAssets.tierLegend,
        ),
      ];

  int get nextRequiredAmount {
    final index = tiers.indexWhere((t) => t.name == name);
    if (index < tiers.length - 1) return tiers[index + 1].requiredAmount;
    return requiredAmount;
  }
}
