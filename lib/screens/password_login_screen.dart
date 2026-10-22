import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../navigation/app_router.dart';
import '../providers/user_provider.dart';

class PasswordLoginScreen extends StatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  State<PasswordLoginScreen> createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final _ctrl     = TextEditingController();
  bool  _show     = false;
  bool  _loading  = false;
  String? _error;
  int   _attempts = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final input = _ctrl.text;
    if (input.isEmpty) {
      setState(() => _error = 'Enter your password');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final saved = await AuthService.getPassword();
    if (!mounted) return;

    if (input == saved) {
      Navigator.pushReplacementNamed(context, AppRouter.main);
    } else {
      _attempts++;
      setState(() {
        _loading = false;
        _error = _attempts >= 3
            ? 'Wrong password ($_attempts attempts)'
            : 'Wrong password, try again';
        _ctrl.clear();
      });
    }
  }

  Future<void> _forgotPassword() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Forgot password?',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(
          'To reset your password, you\'ll need to log out and create a new profile.',
          style: GoogleFonts.inter(
              color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log out',
                style: GoogleFonts.inter(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await context.read<UserProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.splash, (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<UserProvider>().displayName;

    final screenH = MediaQuery.of(context).size.height;
    final isSmall = screenH < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: HexBackground(
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, isSmall ? 20 : 0, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenH -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      (isSmall ? 44 : 32),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                  SizedBox(height: isSmall ? 16 : 32),
                  const BraxorLogo(fontSize: 22),
                  const Spacer(),

                  // Greeting
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.inter(
                        fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Password field
                  TextField(
                    controller: _ctrl,
                    obscureText: !_show,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 15, color: AppColors.textHint),
                      errorText: _error,
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.textHint, size: 20),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _show = !_show),
                        icon: Icon(
                          _show
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.error, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
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
                              'Sign in',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                    ],
                  ),   // Column
                ),     // IntrinsicHeight
              ),       // ConstrainedBox
            ),         // SingleChildScrollView
          ),           // GestureDetector
        ),             // SafeArea
      ),               // HexBackground
    );
  }
}
