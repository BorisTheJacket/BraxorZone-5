import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../models/mission_model.dart';
import '../providers/progress_provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: Consumer<ProgressProvider>(
            builder: (_, progress, __) => Column(
              children: [
                _header(context),
                _xpHeader(progress),
                _titleRow(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: progress.missions.length,
                    itemBuilder: (_, i) =>
                        _MissionCard(mission: progress.missions[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const BraxorLogo(fontSize: 20),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _xpHeader(ProgressProvider progress) {
    final tier     = progress.currentTier;
    final next     = progress.nextTier;
    final xp       = progress.totalXp;
    final nextXp   = next?.requiredAmount ?? tier.requiredAmount;
    final prog     = next == null ? 1.0 : (xp / nextXp).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BRAXOR',
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  Text('LOYALTY PROGRAM',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppColors.textHint)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'LEVEL: ${tier.name.toUpperCase()}',
                  style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: tier.color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: prog,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          next == null
                              ? '$xp XP — Max tier'
                              : '$xp / $nextXp XP',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          '${(prog * 100).round()}%',
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _titleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tasks & Achievements',
              style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'Complete challenges to earn XP and unlock exclusive club perks.',
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission card (unchanged visual, driven by live data)
// ─────────────────────────────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final MissionModel mission;
  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final isCompleted = mission.status == MissionStatus.completed;
    final isLocked    = mission.status == MissionStatus.locked;

    final Color accentColor;
    final String statusLabel;
    final Color statusBg;
    final Color statusText;

    if (isCompleted) {
      accentColor = AppColors.primary;
      statusLabel = 'COMPLETED';
      statusBg    = AppColors.primary.withValues(alpha: 0.15);
      statusText  = AppColors.primary;
    } else if (isLocked) {
      accentColor = AppColors.textHint;
      statusLabel = 'LOCKED';
      statusBg    = AppColors.border;
      statusText  = AppColors.textHint;
    } else {
      accentColor = AppColors.accentOrange;
      statusLabel = 'IN PROGRESS';
      statusBg    = AppColors.accentOrange.withValues(alpha: 0.15);
      statusText  = AppColors.accentOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock_outline_rounded,
                      size: 20, color: AppColors.textHint)
                  : Icon(_missionIcon(mission.id),
                      size: 22, color: accentColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mission.title.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isLocked
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 18, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  mission.description,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.35),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (!isLocked) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: mission.progress,
                      backgroundColor: AppColors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(accentColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(statusLabel,
                          style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: statusText,
                              letterSpacing: 0.3)),
                    ),
                    const Spacer(),
                    Text(
                      isCompleted
                          ? '+${mission.rewardPoints} XP'
                          : '${mission.current} / ${mission.target}',
                      style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _missionIcon(String id) {
    switch (id) {
      case 'm_first_visit':      return Icons.emoji_events_outlined;
      case 'm_visit_5':          return Icons.sports_rounded;
      case 'm_visit_10':         return Icons.workspace_premium_outlined;
      case 'm_visit_20':         return Icons.stars_rounded;
      case 'm_visit_100':        return Icons.local_fire_department_rounded;
      case 'm_streak_5':         return Icons.bolt_rounded;
      case 'm_daily_month':      return Icons.calendar_month_outlined;
      case 'm_monthly_10':       return Icons.repeat_rounded;
      case 'm_weekday_6pm':      return Icons.wb_sunny_outlined;
      case 'm_night_3week':      return Icons.nights_stay_rounded;
      case 'm_first_tournament': return Icons.military_tech_rounded;
      default:                   return Icons.flag_outlined;
    }
  }
}
