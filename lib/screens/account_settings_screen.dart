import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/hex_background.dart';
import '../navigation/app_router.dart';
import '../providers/user_provider.dart';
import '../providers/progress_provider.dart';
import 'password_setup_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: context.read<UserProvider>().name,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await context.read<UserProvider>().updateName(name);
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name updated',
              style: GoogleFonts.inter(color: AppColors.textPrimary)),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _openPasswordSetup({bool isChange = false}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => PasswordSetupScreen(isChange: isChange)),
    );
  }

  Future<void> _removePassword() async {
    final ok = await _confirm(
      title: 'Remove password?',
      message: 'The app will open directly without asking for a password.',
      action: 'Remove',
      color: AppColors.error,
    );
    if (ok && mounted) {
      await context.read<UserProvider>().removePassword();
    }
  }

  Future<void> _logout() async {
    final ok = await _confirm(
      title: 'Log out?',
      message: 'You will need to re-enter your name on next launch.',
      action: 'Log out',
      color: AppColors.error,
    );
    if (ok && mounted) {
      await context.read<UserProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.splash, (_) => false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final ok = await _confirm(
      title: 'Delete account?',
      message:
          'All your data will be erased permanently. This cannot be undone.',
      action: 'Delete',
      color: AppColors.error,
    );
    if (ok && mounted) {
      context.read<ProgressProvider>().reset();
      await context.read<UserProvider>().deleteAccount();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.splash, (_) => false);
      }
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    required Color color,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(title,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(message,
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action,
                style:
                    GoogleFonts.inter(color: color, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                    Text(
                      'Account',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    // ── Profile ───────────────────────────────────────────
                    _sectionLabel('Profile'),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Player name',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameCtrl,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  cursorColor: AppColors.primary,
                                  decoration: InputDecoration(
                                    hintText: 'Your name',
                                    hintStyle: GoogleFonts.inter(
                                        color: AppColors.textHint),
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary, width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _saveName,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    'Save',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Security ──────────────────────────────────────────
                    _sectionLabel('Security'),
                    _card(
                      child: Column(
                        children: [
                          // Toggle: password on launch
                          Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Password on launch',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary)),
                                    Text('Require password when opening app',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: user.usePassword,
                                onChanged: user.hasPassword
                                    ? (v) => context
                                        .read<UserProvider>()
                                        .toggleUsePassword(v)
                                    : null,
                                activeColor: AppColors.primary,
                                inactiveThumbColor: AppColors.textHint,
                                inactiveTrackColor: AppColors.surface,
                              ),
                            ],
                          ),

                          const Divider(color: AppColors.border, height: 24),

                          // Set / Change password
                          _rowTap(
                            icon: Icons.password_rounded,
                            label: user.hasPassword
                                ? 'Change password'
                                : 'Set password',
                            onTap: () => _openPasswordSetup(
                                isChange: user.hasPassword),
                          ),

                          if (user.hasPassword) ...[
                            const Divider(color: AppColors.border, height: 24),
                            _rowTap(
                              icon: Icons.no_encryption_outlined,
                              label: 'Remove password',
                              onTap: _removePassword,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Danger zone ───────────────────────────────────────
                    _sectionLabel('Account'),
                    _card(
                      child: Column(
                        children: [
                          _dangerRow(
                            icon: Icons.logout_rounded,
                            label: 'Log out',
                            onTap: _logout,
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          _dangerRow(
                            icon: Icons.delete_forever_rounded,
                            label: 'Delete account',
                            onTap: _deleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textHint,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );

  Widget _rowTap({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      );

  Widget _dangerRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      );
}
