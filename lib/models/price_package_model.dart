import '../core/constants/app_assets.dart';

class PricePackageModel {
  final String id;
  final String name;
  final String duration;
  final String price;
  final String description;
  final String iconAsset;
  final bool isFeatured;
  final List<String> includes;

  const PricePackageModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.description,
    required this.iconAsset,
    this.isFeatured = false,
    required this.includes,
  });

  static List<PricePackageModel> get all => const [
        PricePackageModel(
          id: 'clean_shot',
          name: 'Clean Shot',
          duration: '1 Hour',
          price: '25',
          description: 'Perfect for a quick game or warm-up session.',
          iconAsset: AppAssets.priceCleanShot,
          includes: [
            'Table for 1 hour',
            'Cue & balls included',
            'Scoreboard access',
          ],
        ),
        PricePackageModel(
          id: 'game_shift',
          name: 'Game Shift',
          duration: '3 Hours',
          price: '65',
          description: 'The most popular choice for a full game session.',
          iconAsset: AppAssets.priceGameShift,
          isFeatured: true,
          includes: [
            'Table for 3 hours',
            'Cue & balls included',
            'Scoreboard access',
            'Complimentary water',
          ],
        ),
        PricePackageModel(
          id: 'non_stop',
          name: 'Non-Stop',
          duration: '5 Hours',
          price: '99',
          description: 'Extended play for serious enthusiasts.',
          iconAsset: AppAssets.priceNonStop,
          includes: [
            'Table for 5 hours',
            'Cue & balls included',
            'Scoreboard access',
            'Complimentary drinks',
            'Snack platter',
          ],
        ),
        PricePackageModel(
          id: 'night_series',
          name: 'Night Series',
          duration: 'Whole Night',
          price: '149',
          description: 'Play all night long with premium perks.',
          iconAsset: AppAssets.priceNightSeries,
          includes: [
            'Table for the whole night',
            'Cue & balls included',
            'Scoreboard access',
            'Unlimited soft drinks',
            'Snack platter',
            'Priority support',
          ],
        ),
      ];
}
