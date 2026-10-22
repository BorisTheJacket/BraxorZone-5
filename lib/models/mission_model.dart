import '../core/constants/app_assets.dart';

enum MissionStatus { completed, inProgress, locked }

class MissionModel {
  final String id;
  final String title;
  final String description;
  final int current;
  final int target;
  final MissionStatus status;
  final String iconAsset;
  final int rewardPoints;

  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.status,
    required this.iconAsset,
    required this.rewardPoints,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  static List<MissionModel> get initial => const [
        MissionModel(
          id: 'm_first_visit',
          title: 'First Club Visit',
          description: 'Complete your very first visit to any BraxorZone branch.',
          current: 1,
          target: 1,
          status: MissionStatus.completed,
          iconAsset: AppAssets.missionFirstVisit,
          rewardPoints: 50,
        ),
        MissionModel(
          id: 'm_visit_5',
          title: 'Regular Player',
          description: 'Visit the club 5 times.',
          current: 3,
          target: 5,
          status: MissionStatus.inProgress,
          iconAsset: AppAssets.missionRegular,
          rewardPoints: 100,
        ),
        MissionModel(
          id: 'm_first_tournament',
          title: 'First Tournament',
          description: 'Attend your first BraxorZone tournament.',
          current: 0,
          target: 1,
          status: MissionStatus.inProgress,
          iconAsset: AppAssets.missionTournament,
          rewardPoints: 150,
        ),
        MissionModel(
          id: 'm_visit_10',
          title: 'Dedicated Fan',
          description: 'Visit the club 10 times.',
          current: 3,
          target: 10,
          status: MissionStatus.locked,
          iconAsset: AppAssets.missionDedicated,
          rewardPoints: 200,
        ),
        MissionModel(
          id: 'm_streak_5',
          title: 'On a Roll',
          description: 'Visit the club 5 days in a row.',
          current: 2,
          target: 5,
          status: MissionStatus.inProgress,
          iconAsset: AppAssets.missionOnRoll,
          rewardPoints: 250,
        ),
        MissionModel(
          id: 'm_monthly_10',
          title: 'Monthly Regular',
          description: 'Visit the club 10 times in a month.',
          current: 3,
          target: 10,
          status: MissionStatus.locked,
          iconAsset: AppAssets.missionMonthly,
          rewardPoints: 300,
        ),
        MissionModel(
          id: 'm_weekday_6pm',
          title: 'Early Bird',
          description: 'Visit 3 times on weekdays before 6:00 PM.',
          current: 1,
          target: 3,
          status: MissionStatus.inProgress,
          iconAsset: AppAssets.missionEarlyBird,
          rewardPoints: 150,
        ),
        MissionModel(
          id: 'm_night_3week',
          title: 'Night Owl',
          description: 'Buy 3 night packages in a week.',
          current: 1,
          target: 3,
          status: MissionStatus.locked,
          iconAsset: AppAssets.missionNightOwl,
          rewardPoints: 300,
        ),
        MissionModel(
          id: 'm_visit_20',
          title: 'Club Veteran',
          description: 'Visit the club 20 times.',
          current: 3,
          target: 20,
          status: MissionStatus.locked,
          iconAsset: AppAssets.missionVeteran,
          rewardPoints: 500,
        ),
        MissionModel(
          id: 'm_daily_month',
          title: 'Unstoppable',
          description: 'Visit the club every day for a month.',
          current: 0,
          target: 30,
          status: MissionStatus.locked,
          iconAsset: AppAssets.missionUnstoppable,
          rewardPoints: 1000,
        ),
        MissionModel(
          id: 'm_visit_100',
          title: 'Legend',
          description: 'Visit the club 100 times in a year.',
          current: 3,
          target: 100,
          status: MissionStatus.locked,
          iconAsset: AppAssets.missionLegend,
          rewardPoints: 2000,
        ),
      ];
}
