import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/asset_widgets.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Package data — shared with BookingScreen
// ─────────────────────────────────────────────────────────────────────────────

class PackageData {
  final String id;
  final IconData icon;
  final String name;
  final String desc;
  final String price;
  final String? badge;
  const PackageData({
    required this.id,
    required this.icon,
    required this.name,
    required this.desc,
    required this.price,
    this.badge,
  });
}

const kPackages = <PackageData>[
  PackageData(
    id: 'Clean Shot — 1 Hour',
    icon: Icons.directions_walk_rounded,
    name: 'CLEAN SHOT',
    desc: '1 hour of clean play.\nFocus. Accuracy.',
    price: '25',
  ),
  PackageData(
    id: 'Game Shift — 3 Hours',
    icon: Icons.access_time_rounded,
    name: 'GAME SHIFT',
    desc: '3 hours of gameplay.\nBest value.',
    price: '65',
    badge: 'BEST VALUE',
  ),
  PackageData(
    id: 'No Break — 5 Hours',
    icon: Icons.all_inclusive_rounded,
    name: 'NO BREAK',
    desc: '5 hours non-stop.\nPlay without limits.',
    price: '99',
  ),
  PackageData(
    id: 'Night Series — Whole Night',
    icon: Icons.nights_stay_rounded,
    name: 'NIGHT SERIES',
    desc: 'For night owls.\nAll night long.',
    price: '149',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TariffSelectionScreen extends StatefulWidget {
  final String? initial;
  const TariffSelectionScreen({super.key, this.initial});

  @override
  State<TariffSelectionScreen> createState() => _TariffSelectionScreenState();
}

class _TariffSelectionScreenState extends State<TariffSelectionScreen> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  Future<void> _pick(String id) async {
    setState(() => _selected = id);
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── logo row ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: const BraxorLogo(fontSize: 20),
              ),
              // ── title ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Tariff',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Premium billiard experiences tailored for your competitive edge.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              // ── tariff cards ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: kPackages
                      .map((pkg) => _TariffCard(
                            pkg: pkg,
                            selected: _selected == pkg.id,
                            onTap: () => _pick(pkg.id),
                          ))
                      .toList(),
                ),
              ),
              // ── equipment section ─────────────────────────────────────────
              _EquipmentSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tariff card
// ─────────────────────────────────────────────────────────────────────────────

class _TariffCard extends StatelessWidget {
  final PackageData pkg;
  final bool selected;
  final VoidCallback onTap;
  const _TariffCard(
      {required this.pkg, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.7)
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Icon(
                  pkg.icon,
                  size: 52,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 14),
                Text(
                  pkg.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pkg.desc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                // green SELECT button — always green, matching mockup
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      selected ? 'SELECTED  ✓' : 'SELECT',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (pkg.badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    pkg.badge!,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Equipment section
// ─────────────────────────────────────────────────────────────────────────────

class _EquipmentSection extends StatelessWidget {
  const _EquipmentSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PREMIUM TABLES badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'PREMIUM TABLES',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // image card with overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                AssetImg(
                  AppAssets.unlockNextBg,
                  width: double.infinity,
                  height: 148,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 16,
                  child: Text(
                    'World-Class Equipment',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Selected by the pros for the ultimate break.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _featureRow(
            icon: Icons.group_outlined,
            title: 'Up to 6 players',
            subtitle: 'All tariffs include equipment',
          ),
          const SizedBox(height: 12),
          _featureRow(
            icon: Icons.verified_outlined,
            title: 'Certified Tables',
            subtitle: 'Tournament standard felt',
          ),
        ],
      ),
    );
  }

  Widget _featureRow(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
