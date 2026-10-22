import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../models/tournament_model.dart';


class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tournaments = TournamentModel.upcoming;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              SliverToBoxAdapter(child: _titleSection()),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _TournamentCard(tournament: tournaments[i]),
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
      child: Row(children: [
        const BraxorLogo(fontSize: 20),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('Back',
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
          ),
        ),
      ]),
    );
  }

  Widget _titleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ELITE EVENTS',
            style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 2.0)),
        const SizedBox(height: 4),
        Text('Upcoming Tournaments',
            style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tournament card
// ─────────────────────────────────────────────────────────────────────────────

class _TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  const _TournamentCard({required this.tournament});

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TournamentDetailSheet(tournament: tournament),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isElite = tournament.badge == 'ELITE CLASS';
    final hasBadge = tournament.badge.isNotEmpty;

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isElite
                ? AppColors.accentOrange.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Banner — full width ────────────────────────────────────────
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image.asset(
                    tournament.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF111411),
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            size: 40, color: AppColors.textHint),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.25, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ),
                // Badge — top right
                if (hasBadge)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isElite
                            ? AppColors.accentOrange
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tournament.badge,
                          style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 0.5)),
                    ),
                  ),
                // Name + Prize Pool overlaid at bottom
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          tournament.name.toUpperCase(),
                          style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              height: 1.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Prize Pool',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.65))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${tournament.format} • ${tournament.subFormat}',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 5),
                    Text(tournament.formattedDate,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 5),
                    Text(tournament.startTime,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _TournamentDetailSheet extends StatelessWidget {
  final TournamentModel tournament;
  const _TournamentDetailSheet({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final isElite = tournament.badge == 'ELITE CLASS';
    final hasBadge = tournament.badge.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xF0121512),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // Banner image
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(children: [
                  SizedBox.expand(
                    child: Image.asset(
                      tournament.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF111411),
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              size: 48, color: AppColors.textHint),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.2, 1.0],
                          colors: [
                            Colors.transparent,
                            const Color(0xF0121512),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hasBadge)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isElite
                              ? AppColors.accentOrange
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tournament.badge,
                            style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: 0.5)),
                      ),
                    ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Text(
                      tournament.name.toUpperCase(),
                      style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.1),
                    ),
                  ),
                ]),
              ),

              // Info body
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Format chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                          '${tournament.format} • ${tournament.subFormat}',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.4)),
                    ),
                    const SizedBox(height: 18),

                    // Info rows
                    _infoRow(Icons.calendar_today_rounded, 'Date',
                        tournament.formattedDate),
                    const SizedBox(height: 12),
                    _infoRow(Icons.access_time_rounded, 'Start time',
                        tournament.startTime),
                    const SizedBox(height: 12),
                    _infoRow(Icons.location_on_outlined, 'Venue',
                        tournament.branch),
                    const SizedBox(height: 12),
                    _infoRow(Icons.emoji_events_outlined, 'Prize',
                        tournament.prizeInfo),
                    const SizedBox(height: 12),
                    _infoRow(Icons.people_outline_rounded, 'Slots',
                        '${tournament.maxPlayers} players max'),

                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 17, color: AppColors.primary),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textHint,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ]),
    ]);
  }
}
