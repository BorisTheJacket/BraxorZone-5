import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/braxor_logo.dart';

class ClubRulesScreen extends StatelessWidget {
  const ClubRulesScreen({super.key});

  static const _rules = [
    _Rule(
      icon: Icons.directions_walk_rounded,
      title: 'Elite Etiquette',
      body: 'Maintain a competitive yet respectful atmosphere. '
          'Excessive noise or unsportsmanlike behavior is strictly prohibited.',
      detail: 'Braxor Zone is built on respect. Every player is expected to '
          'maintain composure whether winning or losing. Verbal abuse, '
          'aggressive behaviour, or deliberate distraction of opponents will '
          'result in immediate removal from the premises.',
    ),
    _Rule(
      icon: Icons.sports_rounded,
      title: 'Equipment Care',
      body: 'Handle cues with precision. Avoid placing drinks or personal '
          'items on the felt or table rails at any time.',
      detail: 'Our tables and cues are premium equipment maintained to '
          'professional standards. Rough handling or placing any items on '
          'the felt surface is strictly forbidden. Damage caused through '
          'negligence may be subject to repair costs.',
    ),
    _Rule(
      icon: Icons.access_time_rounded,
      title: 'Punctual Play',
      body: 'Booking sessions are strict. Please vacate the table '
          '5 minutes before your session ends to allow for sanitation.',
      detail: 'Each booking slot is timed to the minute. Your session begins '
          'at the booked time regardless of your arrival. Overstaying your '
          'slot affects the next player and may incur additional charges.',
    ),
    _Rule(
      icon: Icons.checkroom_outlined,
      title: 'Dress Code',
      body: 'Smart casual attire is required. No athletic swimwear or '
          'flip-flops permitted within the main lounge.',
      detail: 'Braxor Zone is a premium venue and we ask all guests to dress '
          'accordingly. Athletic wear, swimwear, and flip-flops are not '
          'permitted. Management reserves the right to refuse entry.',
    ),
    _Rule(
      icon: Icons.shield_outlined,
      title: 'Fair Play Only',
      body: 'External gambling is prohibited. Use the Braxor Scoreboard '
          'for all official match tracking and ranking.',
      detail: 'All monetary wagering between players is strictly prohibited. '
          'Violations result in membership suspension and potential banning '
          'from all future tournaments.',
    ),
    _Rule(
      icon: Icons.no_photography_outlined,
      title: 'Privacy Protocol',
      body: 'Respect the privacy of other members. Photography and video '
          'recording are limited to your own table only.',
      detail: 'Photography and video are only permitted at your own table '
          'with the consent of everyone visible. Recording other tables or '
          'sharing footage of members without consent may constitute a '
          'legal offence.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Hex background ───────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              AppAssets.bgHome,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AppColors.background),
            ),
          ),

          // ── Subtle dark overlay for readability ──────────────────────
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.22)),
          ),

          // ── Scrollable content ───────────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 36),
                      children: [
                        _titleSection(),
                        const SizedBox(height: 22),
                        ..._rules.map((r) => _RuleCard(
                              rule: r,
                              onTap: () => _showDetail(context, r),
                            )),
                        const SizedBox(height: 22),
                        _footer(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const BraxorLogo(fontSize: 20),
          const Spacer(),
          // RULES badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1),
            ),
            child: Text(
              'RULES',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Back button — white fill + green double-ring
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1C1C1C),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.compare_arrows_rounded,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Title ────────────────────────────────────────────────────────────────

  Widget _titleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Club Rules',
          style: GoogleFonts.montserrat(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'To ensure a premium experience for all competitors, we kindly '
          'ask you to observe our professional conduct guidelines.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────

  Widget _footer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questions?',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Speak to a floor manager.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _showContact(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Help',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Detail sheet ─────────────────────────────────────────────────────────

  void _showDetail(BuildContext context, _Rule rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35)),
                  ),
                  child: Icon(rule.icon,
                      size: 26, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    rule.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 18),
            Text(
              rule.detail,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Got it',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Contact sheet ────────────────────────────────────────────────────────

  void _showContact(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final questionCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            _field('Name', Icons.person_outline_rounded, nameCtrl),
            const SizedBox(height: 12),
            _field('Phone', Icons.phone_outlined, phoneCtrl,
                type: TextInputType.phone),
            const SizedBox(height: 12),
            _field('Question', Icons.help_outline_rounded, questionCtrl,
                lines: 3),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Send',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
    int lines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLines: lines,
          style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: lines == 1
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child:
                        Icon(icon, size: 18, color: AppColors.textHint),
                  )
                : null,
            prefixIconConstraints: lines == 1
                ? const BoxConstraints(minWidth: 44, minHeight: 44)
                : null,
            hintText: lines > 1 ? 'Describe your question…' : null,
          ),
        ),
      ],
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final _Rule rule;
  final VoidCallback onTap;
  const _RuleCard({required this.rule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3828).withValues(alpha: 0.52),
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D2A19).withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Icon(rule.icon,
                        size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rule.body,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _Rule {
  final IconData icon;
  final String title;
  final String body;
  final String detail;
  const _Rule({
    required this.icon,
    required this.title,
    required this.body,
    required this.detail,
  });
}
