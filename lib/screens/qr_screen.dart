import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/services/qr_crypto_service.dart';
import '../core/widgets/asset_widgets.dart';
import '../core/widgets/hex_background.dart';
import '../core/widgets/braxor_logo.dart';
import '../core/widgets/notification_bell.dart';
import '../providers/progress_provider.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool _activated = false;

  void _resetScan() => setState(() => _activated = false);

  // Камеру та дозвіл на неї повністю обробляє сканер-сторінка нижче
  // (mobile_scanner сам запитує AVCaptureDevice-дозвіл на iOS / камеру на
  // Android) — тут лише відкриваємо її, без жодної окремої перевірки.
  Future<void> _openCamera() async {
    final scanned = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _FullScreenScannerPage(),
      ),
    );

    if (scanned == true && mounted) {
      HapticFeedback.mediumImpact();
      context.read<ProgressProvider>().recordVisit(package: '', time: DateTime.now());
      setState(() => _activated = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activated) return _SuccessView(onReset: _resetScan);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                _titleSection(),
                _scanIllustration(),
                _buttons(),
                _testQrSection(),
                _nearbyTables(),
                const SizedBox(height: 32),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activate Table',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Press SCAN NOW and point your camera at the QR code on the billiards table.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanIllustration() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to Scan',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap SCAN NOW to open the camera',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _openCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    'SCAN NOW',
                    style: GoogleFonts.montserrat(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _showManualEntry,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'ENTER CODE MANUALLY',
                style: GoogleFonts.montserrat(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntry() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Table Code',
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Paste the encrypted code from your table receipt.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Paste encrypted code here',
                hintStyle: GoogleFonts.inter(color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final input = ctrl.text.trim();
                  Navigator.pop(context);
                  if (input.isEmpty) return;
                  if (QrCryptoService.validate(input)) {
                    context.read<ProgressProvider>().recordVisit(package: '', time: DateTime.now());
                    setState(() => _activated = true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.cardElevated,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: Text('Invalid code',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text('Activate',
                    style: GoogleFonts.montserrat(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text('TEST QR CODE',
                      style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('Scan this code with the camera to verify',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  QrImageView(
                    data: QrCryptoService.encryptedWord,
                    version: QrVersions.auto,
                    size: 160,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                    dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text('Contains: "${QrCryptoService.secretWord}" (encrypted)',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textHint),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _testQrSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('YOUR TABLE QR CODE',
                    style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Print this QR and place it on your billiard table. Then scan it with the camera above.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: QrCryptoService.encryptedWord,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square, color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Word: "${QrCryptoService.secretWord}"',
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textHint, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nearbyTables() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('NEARBY TABLES',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Active Now',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TableChip(table: 'Table #07', zone: 'VIP Ring')),
              const SizedBox(width: 10),
              Expanded(child: _TableChip(table: 'Table #12', zone: 'Braxor Central')),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Повноекранний сканер ─────────────────────────────────────────────────────

class _FullScreenScannerPage extends StatefulWidget {
  const _FullScreenScannerPage();

  @override
  State<_FullScreenScannerPage> createState() => _FullScreenScannerPageState();
}

class _FullScreenScannerPageState extends State<_FullScreenScannerPage> {
  late final MobileScannerController _ctrl;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      formats: [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    for (final bc in capture.barcodes) {
      final raw = bc.rawValue;
      if (raw == null) continue;

      final trimmed = raw.trim();

      if (QrCryptoService.validate(trimmed)) {
        _detected = true;
        HapticFeedback.mediumImpact();
        _ctrl.stop();
        Navigator.pop(context, true);
      } else {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF2A1A1A),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
            content: Row(children: [
              const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF5350)),
              const SizedBox(width: 10),
              Text('Wrong QR — not a BRAXOR table',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            ]),
          ));
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Камера на весь екран. mobile_scanner сам запитує дозвіл на
          // камеру (AVCaptureDevice на iOS) при старті контролера — якщо
          // користувач відмовив чи дозвіл заблокований, тут показуємо
          // підказку з переходом у Налаштування, без зовнішніх хаків.
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
            errorBuilder: (context, error) =>
                _ScannerErrorView(error: error),
          ),

          // Затемнення + рамка
          _ScanOverlay(),

          // Верхня панель
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                    onPressed: () => _ctrl.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),

          // Підказка знизу
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Text(
                  'Point at the QR code on the table',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Показується замість перегляду камери, коли mobile_scanner не зміг її
/// запустити — найчастіше через те, що користувач відхилив системний
/// запит на доступ до камери, або вимкнув його в Налаштуваннях раніше.
class _ScannerErrorView extends StatelessWidget {
  final MobileScannerException error;
  const _ScannerErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final isPermissionIssue =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 40, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                isPermissionIssue
                    ? 'Camera access is required to scan QR codes.'
                    : 'Could not start the camera.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              if (isPermissionIssue) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: openAppSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Open Settings',
                        style: GoogleFonts.montserrat(
                            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Close',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const frameSize = 260.0;
    final screenW = MediaQuery.sizeOf(context).width;
    final screenH = MediaQuery.sizeOf(context).height;
    final left = (screenW - frameSize) / 2;
    final top = (screenH - frameSize) / 2 - 40;

    return CustomPaint(
      painter: _OverlayPainter(
        Rect.fromLTWH(left, top, frameSize, frameSize),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect frame;
  _OverlayPainter(this.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, shadow);

    final corner = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const r = 16.0;
    const len = 28.0;
    final l = frame.left;
    final t = frame.top;
    final ri = frame.right;
    final b = frame.bottom;

    // top-left
    canvas.drawLine(Offset(l + r, t), Offset(l + r + len, t), corner);
    canvas.drawLine(Offset(l, t + r), Offset(l, t + r + len), corner);
    canvas.drawArc(Rect.fromLTWH(l, t, r * 2, r * 2), -3.14, 1.57, false, corner);
    // top-right
    canvas.drawLine(Offset(ri - r - len, t), Offset(ri - r, t), corner);
    canvas.drawLine(Offset(ri, t + r), Offset(ri, t + r + len), corner);
    canvas.drawArc(Rect.fromLTWH(ri - r * 2, t, r * 2, r * 2), -1.57, 1.57, false, corner);
    // bottom-left
    canvas.drawLine(Offset(l + r, b), Offset(l + r + len, b), corner);
    canvas.drawLine(Offset(l, b - r - len), Offset(l, b - r), corner);
    canvas.drawArc(Rect.fromLTWH(l, b - r * 2, r * 2, r * 2), 1.57, 1.57, false, corner);
    // bottom-right
    canvas.drawLine(Offset(ri - r - len, b), Offset(ri - r, b), corner);
    canvas.drawLine(Offset(ri, b - r - len), Offset(ri, b - r), corner);
    canvas.drawArc(Rect.fromLTWH(ri - r * 2, b - r * 2, r * 2, r * 2), 0, 1.57, false, corner);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Допоміжні віджети ────────────────────────────────────────────────────────

class _TableChip extends StatelessWidget {
  final String table;
  final String zone;
  const _TableChip({required this.table, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(table,
              style: GoogleFonts.montserrat(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(zone,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onReset;
  const _SuccessView({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: HexBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: AssetImg(AppAssets.successQr,
                    width: double.infinity, fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onReset,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Scan Another Table',
                        style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
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
