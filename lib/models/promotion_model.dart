import '../core/constants/app_assets.dart';

class PromotionModel {
  final String id;
  final String title;
  final String tagline;
  final String description;
  final String badge;
  final String assetPath;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.badge,
    required this.assetPath,
  });

  static List<PromotionModel> get all => const [
        PromotionModel(
          id: 'double_break',
          title: 'Double Break',
          tagline: 'Second hour is free.',
          description:
              'Play your first hour at full price and get the second hour completely free. Valid for all packages on weekdays.',
          badge: '2×1',
          assetPath: AppAssets.promoDoubleBreak,
        ),
        PromotionModel(
          id: 'iron_friday',
          title: 'Iron Friday',
          tagline: 'Special discounts after 6:00 PM every Friday.',
          description:
              'Every Friday evening from 18:00 onwards, enjoy exclusive pricing across all BraxorZone branches. The more you play, the more you save.',
          badge: 'FRI',
          assetPath: AppAssets.promoIronFriday,
        ),
        PromotionModel(
          id: 'night_lights',
          title: 'Night Lights',
          tagline: 'Special weekday night game discount.',
          description:
              'Burn the midnight oil with our Night Lights promo. Available Monday through Thursday after 10:00 PM for all-night sessions.',
          badge: 'NIGHT',
          assetPath: AppAssets.promoNightLights,
        ),
        PromotionModel(
          id: 'table_for_two',
          title: 'Table for Two',
          tagline: 'Special pricing for couples.',
          description:
              'Bring your partner and enjoy a shared table at a specially reduced rate. Perfect for a unique date night at BraxorZone.',
          badge: '♥',
          assetPath: AppAssets.promoTableForTwo,
        ),
      ];
}
