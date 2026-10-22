import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../core/widgets/notification_bell.dart';
import '../navigation/app_router.dart';
import '../navigation/main_shell.dart';
import '../models/tournament_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tournaments = TournamentModel.upcoming.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              SliverToBoxAdapter(child: _sessionCard(context)),
              SliverToBoxAdapter(child: _quickTiles(context)),
              SliverToBoxAdapter(child: _eventsHeader(context)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _EventCard(tournament: tournaments[i]),
                  childCount: tournaments.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
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
          const NotificationBell(),
        ],
      ),
    );
  }

  Widget _sessionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sports_rounded,
              size: 28, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('No active session',
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Check in to a table to start tracking your game and earning XP',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => ShellTabController.of(context)?.switchTab(3),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded,
                      size: 18, color: Colors.black),
                  const SizedBox(width: 8),
                  Text('Scan QR to Start',
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickTiles(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _QuickTile(
            icon: Icons.table_restaurant_outlined,
            title: 'Book Table',
            subtitle: 'RESERVE YOUR SPOT',
            onTap: () => ShellTabController.of(context)?.switchTab(2),
          ),
          const SizedBox(height: 8),
          _QuickTile(
            icon: Icons.leaderboard_rounded,
            title: 'Match Scoreboard',
            subtitle: 'LIVE ARENA',
            onTap: () => Navigator.pushNamed(context, AppRouter.scoreTracker),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QuickTile(
                  icon: Icons.local_offer_outlined,
                  title: 'View Promos',
                  subtitle: null,
                  onTap: () => ShellTabController.of(context)?.switchTab(1),
                  compact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(
                  icon: Icons.card_membership_outlined,
                  title: 'My Loyalty',
                  subtitle: null,
                  onTap: () => ShellTabController.of(context)?.switchTab(4),
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _eventsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Text('Upcoming Events',
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.tournaments),
            child: Text('See all',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick tile
// ─────────────────────────────────────────────────────────────────────────────

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool compact;

  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: compact ? 14 : 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: GoogleFonts.montserrat(
                          fontSize: compact ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ],
              ),
            ),
            if (!compact)
              const Icon(Icons.chevron_right_rounded,
                  size: 22, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Event card
// ─────────────────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final TournamentModel tournament;
  const _EventCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              width: double.infinity,
              height: 110,
              child: Image.asset(
                tournament.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF111411),
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        size: 32, color: AppColors.textHint),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(tournament.name,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text('UPCOMING',
                          style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(tournament.format,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textHint)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(tournament.formattedDate,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textHint)),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(tournament.startTime,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.tournaments),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text('Join Now',
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
