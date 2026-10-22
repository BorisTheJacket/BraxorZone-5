import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../core/widgets/notification_bell.dart';
import '../providers/score_tracker_provider.dart';
import '../models/player_model.dart';

class ScoreTrackerScreen extends StatefulWidget {
  const ScoreTrackerScreen({super.key});
  @override
  State<ScoreTrackerScreen> createState() => _ScoreTrackerScreenState();
}

class _ScoreTrackerScreenState extends State<ScoreTrackerScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1),
        (_) { if (mounted) context.read<ScoreTrackerProvider>().tick(); });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ─── Add Player dialog with avatar picker ─────────────────────────────────

  void _addPlayer() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border)),
        title: Text('Add Player',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.inter(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Player name',
            hintStyle: GoogleFonts.inter(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.person_outline_rounded,
                size: 20, color: AppColors.textHint),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700))),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                context.read<ScoreTrackerProvider>().addPlayer(name);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('Add',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── End Match dialog ─────────────────────────────────────────────────────

  void _endMatch() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border)),
        title: Text('End Match',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text('Are you sure you want to end the match?',
            style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700))),
          ElevatedButton(
            onPressed: () {
              context.read<ScoreTrackerProvider>().endMatch();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('End Match',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: Consumer<ScoreTrackerProvider>(
            builder: (_, provider, __) => Column(
              children: [
                _buildHeader(),
                _buildTitleRow(),
                Expanded(child: _buildPlayerPlate(provider)),
                _buildFooter(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(children: [
          const BraxorLogo(fontSize: 20),
          const Spacer(),
          const NotificationBell(),
        ]),
      );

  Widget _buildTitleRow() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Text('LIVE ARENA',
                    style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.8)),
              ),
              const SizedBox(height: 6),
              Text('Match Scoreboard',
                  style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: _addPlayer,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add_outlined,
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Add Player',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Solid glass plate ────────────────────────────────────────────────────

  Widget _buildPlayerPlate(ScoreTrackerProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8)),
            ),
            child: Column(children: [
              // Column header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.8))),
                ),
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: Text('PLAYER',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHint,
                            letterSpacing: 1.0)),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text('SCORE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHint,
                            letterSpacing: 1.0)),
                  ),
                  const SizedBox(width: 12),
                  Text('ACTIONS',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHint,
                          letterSpacing: 1.0)),
                  const SizedBox(width: 4),
                ]),
              ),
              // Rows
              if (provider.players.isEmpty)
                Expanded(child: _buildEmptyState())
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: provider.players.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border.withValues(alpha: 0.6)),
                    itemBuilder: (_, i) =>
                        _PlayerRow(player: provider.players[i]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.person_add_outlined,
                  size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text('No players yet',
                style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 5),
            Text('Tap "Add Player" to begin',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  // ─── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter(ScoreTrackerProvider provider) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.76),
            border: Border(
                top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.8))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              if (provider.matchStarted) ...[
                Row(children: [
                  const Icon(Icons.timer_outlined,
                      size: 15, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Text(provider.formattedTime,
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const Spacer(),
                  if (provider.currentPlayer != null) ...[
                    const Icon(Icons.emoji_events_outlined,
                        size: 15, color: AppColors.textHint),
                    const SizedBox(width: 5),
                    Text('Current: ${provider.currentPlayer}',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ],
                ]),
                const SizedBox(height: 12),
                _footerBtn(
                    label: 'End Match',
                    icon: Icons.flag_outlined,
                    bg: AppColors.accentOrange,
                    textColor: Colors.black,
                    onTap: _endMatch),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _statCard(
                        label: 'BALLS POTTED',
                        value: '${provider.totalBalls}',
                        valueColor: AppColors.textPrimary,
                        borderColor: AppColors.border),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                        label: 'FOULS',
                        value: '${provider.totalFouls}',
                        valueColor: AppColors.accentOrange,
                        borderColor:
                            AppColors.accentOrange.withValues(alpha: 0.5)),
                  ),
                ]),
                const SizedBox(height: 10),
              ] else ...[
                _footerBtn(
                    label: 'Start Match',
                    icon: Icons.play_arrow_rounded,
                    bg: AppColors.primary,
                    textColor: Colors.black,
                    onTap: () =>
                        context.read<ScoreTrackerProvider>().startMatch()),
                const SizedBox(height: 10),
              ],
              _footerBtn(
                  label: 'Back',
                  icon: null,
                  bg: provider.matchStarted
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.primary,
                  textColor: provider.matchStarted
                      ? AppColors.textSecondary
                      : Colors.black,
                  borderColor:
                      provider.matchStarted ? AppColors.border : null,
                  onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerBtn({
    required String label,
    required IconData? icon,
    required Color bg,
    required Color textColor,
    required VoidCallback onTap,
    Color? borderColor,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: borderColor != null
                  ? BorderSide(color: borderColor)
                  : BorderSide.none,
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
            ],
          ),
        ),
      );

  Widget _statCard({
    required String label,
    required String value,
    required Color valueColor,
    required Color borderColor,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const SizedBox(height: 5),
          Text(value,
              style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: valueColor)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Player row
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerRow extends StatelessWidget {
  final PlayerModel player;
  const _PlayerRow({required this.player});

  static const _fallbackColors = [
    AppColors.primary,
    AppColors.accentOrange,
    AppColors.accentBlue,
  ];

  @override
  Widget build(BuildContext context) {
    final fallbackColor =
        _fallbackColors[player.name.codeUnitAt(0) % _fallbackColors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Avatar — random image from assets/avatars/
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.6), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                AppAssets.playerAvatars[
                    player.avatarIndex % AppAssets.playerAvatars.length],
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 21,
                  backgroundColor: fallbackColor.withValues(alpha: 0.14),
                  child: Text(
                    player.name.isNotEmpty
                        ? player.name[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: fallbackColor),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + table
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('TABLE 04',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4)),
              ],
            ),
          ),
          // Score
          SizedBox(
            width: 52,
            child: Text('${player.ballsScored}',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1.0)),
          ),
          const SizedBox(width: 12),
          // Buttons
          _ActionBtn(
            icon: Icons.add_rounded,
            accent: AppColors.primary,
            onTap: () =>
                context.read<ScoreTrackerProvider>().increment(player.id),
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            icon: Icons.remove_rounded,
            accent: AppColors.accentOrange,
            onTap: () =>
                context.read<ScoreTrackerProvider>().decrement(player.id),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: accent),
      ),
    );
  }
}
