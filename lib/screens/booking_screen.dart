import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/asset_widgets.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../providers/user_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/notification_provider.dart';
import 'tariff_screen.dart';
import '../core/widgets/notification_bell.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _selectedPackage;
  String _selectedClub = 'Braxor Central';
  bool _loading = false;


  static const _clubs = <_ClubData>[
    _ClubData('Braxor Central', 'MAIN HUB', Icons.apartment_rounded),
    _ClubData('Braxor Night Hall', 'NOCTURNAL PLAY', Icons.nights_stay_outlined),
    _ClubData('Braxor Arena', 'TOURNAMENT LEVEL', Icons.emoji_events_outlined),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nameCtrl.text.isEmpty) {
      final name = context.read<UserProvider>().displayName;
      if (name != 'Player') _nameCtrl.text = name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a package',
              style: GoogleFonts.inter(color: Colors.black)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final progressProvider = context.read<ProgressProvider>();
    final notifProvider    = context.read<NotificationProvider>();
    final pkg  = _selectedPackage ?? '';
    final club = _selectedClub;

    await Future.delayed(const Duration(seconds: 1));
    await progressProvider.recordVisit(package: pkg, time: DateTime.now());
    await notifProvider.add(NotificationProvider.makeBooking(pkg, club));

    if (!mounted) return;
    setState(() => _loading = false);
    _showSuccess();
  }

  void _showSuccess() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const _SuccessScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _titleSection()),
                SliverToBoxAdapter(child: _fields()),
                SliverToBoxAdapter(child: _packageSection()),
                SliverToBoxAdapter(child: _clubSection()),
                SliverToBoxAdapter(child: _bookButton()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
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

  Widget _titleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book a Table',
            style: GoogleFonts.montserrat(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Secure your spot at the premium billiards club. Choose your package and venue.',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _fields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.person_outline_rounded,
                    size: 20, color: AppColors.textSecondary),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 16),
          _label('Phone Number'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))
            ],
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '+44 7123 456 789',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.phone_outlined,
                    size: 20, color: AppColors.textSecondary),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            validator: (v) =>
                (v == null || v.trim().length < 7) ? 'Enter a valid phone number' : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _clubSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Select Club'),
          const SizedBox(height: 12),
          ..._clubs.map((c) {
            final sel = _selectedClub == c.name;
            return GestureDetector(
              onTap: () => setState(() => _selectedClub = c.name),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // icon block
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(c.icon, size: 20,
                          color: sel ? AppColors.primary : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 14),
                    // text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(c.subtitle,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.textHint,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    // radio circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sel ? AppColors.primary : Colors.transparent,
                        border: sel
                            ? null
                            : Border.all(
                                color: AppColors.border, width: 2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _bookButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.border,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Book Table',
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: Colors.black),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _packageSection() {
    final selected = _selectedPackage != null
        ? kPackages.firstWhere((p) => p.id == _selectedPackage,
            orElse: () => kPackages.first)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Select Package'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      TariffSelectionScreen(initial: _selectedPackage),
                  transitionsBuilder: (_, anim, __, child) {
                    final curved = CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic);
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(1, 0), end: Offset.zero)
                          .animate(curved),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 250),
                ),
              );
              if (result != null) setState(() => _selectedPackage = result);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected != null
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected?.icon ?? Icons.sell_outlined,
                    size: 20,
                    color: selected != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: selected != null
                        ? Row(
                            children: [
                              Text(
                                selected.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selected.price,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          )
                        : Text(
                            'Choose your tariff',
                            style: GoogleFonts.inter(
                                fontSize: 14, color: AppColors.textHint),
                          ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppColors.textHint),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _ClubData {
  final String name;
  final String subtitle;
  final IconData icon;
  const _ClubData(this.name, this.subtitle, this.icon);
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: AssetImg(
                  AppAssets.successBilliard,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((r) => r.isFirst || r.settings.name == '/main'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Menu',
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
