import '../core/constants/app_assets.dart';

class TournamentModel {
  final String id;
  final String name;
  final DateTime date;
  final String startTime;
  final String branch;
  final String format;
  final String subFormat;
  final String badge;        // 'UPCOMING' | 'ELITE CLASS' | 'FEATURED' | ''
  final int maxPlayers;
  final String prizeInfo;

  const TournamentModel({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.branch,
    required this.format,
    required this.subFormat,
    required this.badge,
    required this.maxPlayers,
    required this.prizeInfo,
  });

  static List<TournamentModel> get upcoming => [
        TournamentModel(
          id: 't1',
          name: 'Night Championship',
          date: DateTime(2026, 8, 9),
          startTime: '19:00',
          branch: 'Braxor Central',
          format: '8-BALL',
          subFormat: 'HANDICAP',
          badge: 'UPCOMING',
          maxPlayers: 16,
          prizeInfo: 'Trophy + Loyalty Points',
        ),
        TournamentModel(
          id: 't2',
          name: 'Masters Invitational',
          date: DateTime(2026, 9, 14),
          startTime: '20:30',
          branch: 'Braxor Arena',
          format: '8-BALL',
          subFormat: 'PRO SERIES',
          badge: 'ELITE CLASS',
          maxPlayers: 16,
          prizeInfo: 'Trophy + Free Packages',
        ),
        TournamentModel(
          id: 't3',
          name: 'Weekend Warriors',
          date: DateTime(2026, 10, 18),
          startTime: '14:00',
          branch: 'Braxor Night Hall',
          format: 'DOUBLES',
          subFormat: 'OPEN',
          badge: '',
          maxPlayers: 20,
          prizeInfo: 'Grand Trophy + Cash Prize',
        ),
      ];

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Banner: assets/banners/banner_tournament_t1.png etc.
  String get assetPath => AppAssets.tournamentBanner(id);
}
