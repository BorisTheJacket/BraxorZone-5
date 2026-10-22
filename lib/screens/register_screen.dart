import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../navigation/app_router.dart';
import '../providers/user_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl    = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _usePassword  = false;
  bool _showPass     = false;
  bool _showConfirm  = false;
  bool _loading      = false;
  String? _nameError;
  String? _passError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name    = _nameCtrl.text.trim();
    final pass    = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    // Validate
    String? nameErr;
    String? passErr;

    if (name.isEmpty) nameErr = 'Please enter your name';

    if (_usePassword) {
      if (pass.length < 6) {
        passErr = 'Password must be at least 6 characters';
      } else if (pass != confirm) {
        passErr = 'Passwords don\'t match';
      }
    }

    if (nameErr != null || passErr != null) {
      setState(() { _nameError = nameErr; _passError = passErr; });
      return;
    }

    setState(() => _loading = true);

    final userProvider  = context.read<UserProvider>();
    final notifProvider = context.read<NotificationProvider>();

    await userProvider.register(
      name: name,
      password: _usePassword ? pass : null,
      usePassword: _usePassword,
    );

    await notifProvider.add(NotificationProvider.makeWelcome(name));

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: HexBackground(
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const BraxorLogo(fontSize: 20),
                  const SizedBox(height: 48),

                  // Heading
                  Text(
                    'Create your\nprofile',
                    style: GoogleFonts.montserrat(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your name to get started',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  _AppField(
                    controller: _nameCtrl,
                    hint: 'Your name',
                    icon: Icons.person_outline_rounded,
                    error: _nameError,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 20),

                  // Toggle: use password
                  _ToggleCard(
                    icon: Icons.lock_outline_rounded,
                    title: 'Protect with password',
                    subtitle: 'Require password when opening the app',
                    value: _usePassword,
                    onChanged: (v) => setState(() {
                      _usePassword = v;
                      _passError   = null;
                    }),
                  ),

                  // Password fields (animated)
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 16),
                        _AppField(
                          controller: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: !_showPass,
                          error: _passError,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _showPass = !_showPass),
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                          ),
                          onChanged: (_) => setState(() => _passError = null),
                        ),
                        const SizedBox(height: 12),
                        _AppField(
                          controller: _confirmCtrl,
                          hint: 'Confirm password',
                          icon: Icons.lock_outline_rounded,
                          obscure: !_showConfirm,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _showConfirm = !_showConfirm),
                            icon: Icon(
                              _showConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                          ),
                          onChanged: (_) => setState(() => _passError = null),
                        ),
                      ],
                    ),
                    crossFadeState: _usePassword
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 260),
                    sizeCurve: Curves.easeOut,
                  ),

                  const SizedBox(height: 28),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.black),
                            )
                          : Text(
                              'Start playing',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? error;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const _AppField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.error,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: GoogleFonts.inter(
          fontSize: 15,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 15, color: AppColors.textHint),
        errorText: error,
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: value ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveThumbColor: AppColors.textHint,
            inactiveTrackColor: AppColors.surface,
          ),
        ],
      ),
    );
  }
}
