import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/offer_service.dart';
import '../providers/progress_provider.dart';
import '../core/widgets/asset_widgets.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../core/widgets/notification_bell.dart';
import '../models/promotion_model.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  static final _doubleBreak = PromotionModel.all[0];
  static final _ironFriday  = PromotionModel.all[1];
  static final _nightGlow   = PromotionModel.all[2];

  final Map<String, int> _remaining = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadRemaining();
  }

  Future<void> _loadRemaining() async {
    final promos = [_doubleBreak, _ironFriday, _nightGlow];
    final Map<String, int> map = {};
    for (final p in promos) {
      map[p.id] = await OfferService.getRemainingUses(p.id);
    }
    if (mounted) setState(() { _remaining.addAll(map); _loaded = true; });
  }

  Future<void> _claim(PromotionModel promo) async {
    final warned = await OfferService.wasWarningShown();
    if (!warned && mounted) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => const _WarningDialog(),
      );
      if (ok != true) return;
      await OfferService.markWarningShown();
    }
    if (!mounted) return;
    _showPromoCode(promo);
  }

  void _showPromoCode(PromotionModel promo) {
    final code = 'BRAXOR-${promo.id.toUpperCase().replaceAll('_', '')}-2026';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PromoCodeSheet(
        promo: promo,
        code: code,
        onDone: () async {
          await OfferService.recordClaim(promo.id);
          _loadRemaining();
        },
      ),
    );
  }

  void _showDetails(PromotionModel promo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DetailsSheet(
        promo: promo,
        remaining: _remaining[promo.id] ?? 2,
        onClaim: () { Navigator.pop(context); _claim(promo); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(child: _TitleSection()),
              SliverToBoxAdapter(
                child: _DoubleBreakCard(
                  promo: _doubleBreak,
                  remaining: _remaining[_doubleBreak.id] ?? 2,
                  onClaim: () => _claim(_doubleBreak),
                ),
              ),
              SliverToBoxAdapter(
                child: _SecondaryCard(
                  promo: _ironFriday,
                  remaining: _remaining[_ironFriday.id] ?? 2,
                  tag: '-20% ALL DAY',
                  tagIcon: Icons.calendar_today_rounded,
                  actionLabel: 'VIEW DETAILS',
                  onAction: () => _showDetails(_ironFriday),
                ),
              ),
              SliverToBoxAdapter(
                child: _SecondaryCard(
                  promo: _nightGlow,
                  remaining: _remaining[_nightGlow.id] ?? 2,
                  tag: 'FROM 18:00',
                  tagIcon: Icons.access_time_rounded,
                  actionLabel: 'BOOK NOW',
                  onAction: () => _showDetails(_nightGlow),
                ),
              ),
              SliverToBoxAdapter(child: _LoyaltyBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const BraxorLogo(fontSize: 20),
          const Spacer(),
          const NotificationBell(),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exclusive Deals',
              style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            'Unlock premium benefits and limited-time\nrewards for your next session.',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card 1 — DOUBLE BREAK (featured, orange border)
// ─────────────────────────────────────────────────────────────────────────────

class _DoubleBreakCard extends StatelessWidget {
  final PromotionModel promo;
  final int remaining;
  final VoidCallback onClaim;

  const _DoubleBreakCard({
    required this.promo,
    required this.remaining,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final exhausted = remaining == 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentOrange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: AssetImg(promo.assetPath,
                    height: 172,
                    width: double.infinity,
                    fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('MOST POPULAR',
                      style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 0.5)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    exhausted ? 'Limit reached' : '$remaining/2 left',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: exhausted
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DOUBLE BREAK',
                    style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text('Pay more, pay less. Second hour is on us!',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sell_rounded,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text('-50% 2ND HOUR',
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: exhausted ? null : onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.surface,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      exhausted ? 'Used up this week' : 'CLAIM OFFER',
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: exhausted ? AppColors.textHint : Colors.black,
                          letterSpacing: 0.5),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Cards 2 & 3 — IRON FRIDAY / NIGHT GLOW (vertical, full-width image)
// ─────────────────────────────────────────────────────────────────────────────

class _SecondaryCard extends StatelessWidget {
  final PromotionModel promo;
  final int remaining;
  final String tag;
  final IconData tagIcon;
  final String actionLabel;
  final VoidCallback onAction;

  const _SecondaryCard({
    required this.promo,
    required this.remaining,
    required this.tag,
    required this.tagIcon,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: AssetImg(promo.assetPath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    remaining == 0 ? 'Limit reached' : '$remaining/2 left',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: remaining == 0
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.title.toUpperCase(),
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(promo.tagline,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tagIcon,
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(tag,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: onAction,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: Text(actionLabel,
                            style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Loyalty Rewards banner
// ─────────────────────────────────────────────────────────────────────────────

class _LoyaltyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final toNext   = progress.visitsToNextMilestone;
    final tier     = progress.currentTier;

    final String label = toNext > 0
        ? "You're $toNext visit${toNext == 1 ? '' : 's'} away from your next reward!"
        : 'You\'ve hit every milestone — Legend status unlocked!';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryDark.withValues(alpha: 0.35),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(Icons.card_membership_rounded,
                  size: 20, color: tier.color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Loyalty Rewards',
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(width: 6),
                    Text(
                      tier.name.toUpperCase(),
                      style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tier.color),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirm claim dialog
// ─────────────────────────────────────────────────────────────────────────────

class _WarningDialog extends StatelessWidget {
  const _WarningDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text('Heads up!',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      content: Text(
        'Each offer can be claimed up to 2 times per week. After that it resets on Monday.',
        style: GoogleFonts.inter(
            color: AppColors.textSecondary, fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Got it',
              style: GoogleFonts.inter(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Promo code bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PromoCodeSheet extends StatelessWidget {
  final PromotionModel promo;
  final String code;
  final VoidCallback onDone;
  const _PromoCodeSheet({required this.promo, required this.code, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AssetImg(promo.assetPath,
                height: 130, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(promo.title.toUpperCase(),
              style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(promo.description,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4)),
          const SizedBox(height: 20),
          Text('YOUR PROMO CODE',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHint,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: AppColors.cardElevated,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                content: Text('Code copied!',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary)),
                duration: const Duration(seconds: 2),
              ));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(code,
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 1.5)),
                  ),
                  const Icon(Icons.copy_rounded,
                      size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Tap the code to copy. Present it at the reception desk.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textHint)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () { onDone(); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Done',
                  style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Details bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _DetailsSheet extends StatelessWidget {
  final PromotionModel promo;
  final int remaining;
  final VoidCallback onClaim;

  const _DetailsSheet({
    required this.promo,
    required this.remaining,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AssetImg(promo.assetPath,
                  height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(promo.title.toUpperCase(),
                style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(promo.tagline,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(promo.description,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 8),
            Text(
              '$remaining uses remaining this week',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: remaining > 0
                      ? AppColors.primary
                      : AppColors.textHint,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: remaining > 0 ? onClaim : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.surface,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  remaining > 0 ? 'Claim Now' : 'Used up this week',
                  style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: remaining > 0
                          ? Colors.black
                          : AppColors.textHint),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
