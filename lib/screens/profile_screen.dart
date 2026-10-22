import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/asset_widgets.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../navigation/app_router.dart';
import '../models/loyalty_tier_model.dart';
import '../providers/progress_provider.dart';
import '../providers/user_provider.dart';
import '../core/widgets/notification_bell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final userName = context.watch<UserProvider>().displayName;

    final tier   = progress.currentTier;
    final next   = progress.nextTier;
    final xp     = progress.totalXp;
    final nextXp = next?.requiredAmount ?? tier.requiredAmount;
    final prog   = next == null ? 1.0 : (xp / nextXp).clamp(0.0, 1.0);
    final tiers  = LoyaltyTierModel.tiers;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(context, userName)),
              SliverToBoxAdapter(
                child: _loyaltyCard(tier, next, xp, nextXp, prog, userName),
              ),
              SliverToBoxAdapter(child: _tierRoadmap(tiers, tier.name)),
              SliverToBoxAdapter(
                child: _unlockNext(context, next, tier, xp, nextXp, prog)),
              SliverToBoxAdapter(child: _challenges(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: logo (left) + gear (far right) ──
          Row(
            children: [
              const BraxorLogo(fontSize: 20),
              const Spacer(),
              const NotificationBell(),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRouter.accountSettings),
                child: const Icon(Icons.settings_outlined,
                    color: AppColors.textSecondary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Row 2: title + CARD + ⇄ ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'My Loyalty',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'CARD',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ⇄ double-ring green button with bounce animation
              _BounceTap(
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.clubRules),
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
                        color: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.compare_arrows_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ── Row 3: username (prominent) ──
          Text(
            userName,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          // ── Row 4: subtitle ──
          Text(
            'Track your progress and unlock elite perks.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Loyalty Card ──────────────────────────────────────────────────────────

  Widget _loyaltyCard(
    LoyaltyTierModel tier,
    LoyaltyTierModel? next,
    int xp,
    int nextXp,
    double prog,
    String userName,
  ) {
    final xpLeft = next == null ? 0 : nextXp - xp;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Level + XP row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEMBERSHIP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'LEVEL: ${tier.name.toUpperCase()}',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$xp XP',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    userName,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── XP progress labels ──
          Row(
            children: [
              Text(
                next == null ? '$xp XP' : '$xp / $nextXp XP',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                next == null
                    ? 'Max tier reached'
                    : '$xpLeft XP to next level',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Progress bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prog,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 14),
          // ── Info banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    next == null
                        ? 'You\'ve reached Legend status. Enjoy all perks!'
                        : 'Earn $xpLeft more XP to unlock ${next.name.toUpperCase()} status.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tier Roadmap ──────────────────────────────────────────────────────────

  Widget _tierRoadmap(
      List<LoyaltyTierModel> tiers, String currentTierName) {
    final currentIndex =
        tiers.indexWhere((t) => t.name == currentTierName);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TIER ROADMAP',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          Container(height: 1, color: AppColors.divider),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('LEVEL', style: _colHead)),
                Expanded(
                    flex: 2,
                    child: Text('REQUIREMENT',
                        textAlign: TextAlign.center,
                        style: _colHead)),
                Expanded(
                    flex: 2,
                    child: Text('BENEFITS',
                        textAlign: TextAlign.end, style: _colHead)),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.divider),
          // Rows
          ...tiers.asMap().entries.map((e) {
            final i = e.key;
            final t = e.value;
            final isActive   = t.name == currentTierName;
            final isUnlocked = i < currentIndex;

            return Container(
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.07)
                    : Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        _tierIcon(isActive, isUnlocked),
                        const SizedBox(width: 8),
                        Text(
                          t.name.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      t.requiredAmount == 0
                          ? '0 XP'
                          : '${t.requiredAmount} XP',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      t.benefit,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _tierIcon(bool isActive, bool isUnlocked) {
    if (isActive) {
      return Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
      );
    }
    if (isUnlocked) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.45),
        ),
      );
    }
    return const Icon(Icons.lock_outline_rounded,
        size: 14, color: AppColors.textHint);
  }

  // ── Unlock Next ───────────────────────────────────────────────────────────

  Widget _unlockNext(
    BuildContext context,
    LoyaltyTierModel? next,
    LoyaltyTierModel current,
    int xp,
    int nextXp,
    double prog,
  ) {
    final title = next == null
        ? '${current.cashbackPercent}% Cashback — Max!'
        : '${next.cashbackPercent}% Instant Cashback';
    final sub = next == null
        ? 'You\'ve reached Legend status. Enjoy all perks!'
        : 'Unlocked at ${next.requiredAmount} XP. Valid on all bookings.';
    final badge =
        next == null ? 'MAX TIER' : '${next.name.toUpperCase()} PERK';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            'UNLOCK NEXT',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        _BounceTap(
          onTap: () =>
              _showPerkDetail(context, next, current, xp, nextXp, prog),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15)),
                      child: AssetImg(
                        AppAssets.unlockNextBg,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              sub,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textHint, size: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPerkDetail(
    BuildContext context,
    LoyaltyTierModel? next,
    LoyaltyTierModel current,
    int xp,
    int nextXp,
    double prog,
  ) {
    final isMax = next == null;
    final tier = isMax ? current : next;
    final xpLeft = isMax ? 0 : nextXp - xp;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with badge
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: AssetImg(
                  AppAssets.unlockNextBg,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 14,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isMax
                        ? 'MAX TIER'
                        : '${tier.name.toUpperCase()} PERK',
                    style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
              ),
              // handle bar
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  isMax
                      ? '${current.cashbackPercent}% Cashback — Max!'
                      : '${tier.cashbackPercent}% Instant Cashback',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isMax
                      ? 'You\'ve unlocked the highest tier. All perks are active.'
                      : 'Reach ${tier.name} status to earn ${tier.cashbackPercent}% back on every booking.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: AppColors.divider),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _statChip(
                      label: 'CASHBACK',
                      value: '${tier.cashbackPercent}%',
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      label: isMax ? 'STATUS' : 'REQUIRED',
                      value: isMax ? 'MAX' : '${tier.requiredAmount} XP',
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      label: isMax ? 'XP' : 'REMAINING',
                      value: isMax ? '$xp XP' : '$xpLeft XP',
                      highlight: !isMax,
                    ),
                  ],
                ),
                if (!isMax) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Progress to ${tier.name}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      const Spacer(),
                      Text('${(prog * 100).round()}%',
                          style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: prog,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 7,
                    ),
                  ),
                ],
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
                      elevation: 0,
                    ),
                    child: Text(
                      isMax ? 'Awesome!' : 'Keep playing!',
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlight
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHint,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: highlight
                        ? AppColors.primary
                        : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  // ── Challenges ────────────────────────────────────────────────────────────

  Widget _challenges(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Challenges',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'More quests',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.tasks),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'GO',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared text style ────────────────────────────────────────────────────────

final _colHead = GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: AppColors.textHint,
  letterSpacing: 0.5,
);

// ─── Bounce-tap wrapper ───────────────────────────────────────────────────────

class _BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BounceTap({required this.child, required this.onTap});

  @override
  State<_BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<_BounceTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
