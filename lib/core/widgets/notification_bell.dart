import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../models/app_notification.dart';
import '../../navigation/app_router.dart';
import '../../navigation/main_shell.dart';
import '../../providers/notification_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bell icon with unread badge — drop in any screen header
// ─────────────────────────────────────────────────────────────────────────────

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showNotificationsSheet(context),
      child: Consumer<NotificationProvider>(
        builder: (_, notifProvider, __) {
          final unread = notifProvider.unreadCount;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded,
                  size: 26, color: AppColors.textSecondary),
              if (unread > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Open the notifications bottom sheet from any context
// ─────────────────────────────────────────────────────────────────────────────

void showNotificationsSheet(BuildContext context) {
  final shell = ShellTabController.of(context);
  context.read<NotificationProvider>().markAllRead();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => NotificationsSheet(
      onNavigate: (action) {
        if (action == null) return;
        switch (action) {
          case 'tasks':
            if (context.mounted) Navigator.pushNamed(context, AppRouter.tasks);
          case 'profile':
            shell?.switchTab(4);
          case 'booking':
            shell?.switchTab(2);
          case 'offers':
            shell?.switchTab(1);
        }
      },
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications sheet (draggable)
// ─────────────────────────────────────────────────────────────────────────────

class NotificationsSheet extends StatelessWidget {
  final void Function(String? action) onNavigate;
  const NotificationsSheet({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (_, notifProvider, __) {
        final notifs = notifProvider.notifications;
        return DraggableScrollableSheet(
          initialChildSize: notifs.isEmpty ? 0.35 : 0.65,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollCtrl) => Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                    if (notifs.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${notifs.length}',
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (notifs.isNotEmpty)
                      TextButton(
                        onPressed: () => notifProvider.clearAll(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Clear all',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      ),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.divider),
              Expanded(
                child: notifs.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        itemCount: notifs.length,
                        separatorBuilder: (_, __) => Container(
                            height: 1,
                            color: AppColors.divider,
                            margin:
                                const EdgeInsets.symmetric(vertical: 4)),
                        itemBuilder: (_, i) => NotifTile(
                          notif: notifs[i],
                          onNavigate: (action) {
                            Navigator.pop(context);
                            Future.microtask(() => onNavigate(action));
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('No notifications yet',
              style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            'Achievements, bookings and updates will appear here.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single notification tile
// ─────────────────────────────────────────────────────────────────────────────

class NotifTile extends StatelessWidget {
  final AppNotification notif;
  final void Function(String? action) onNavigate;
  const NotifTile({super.key, required this.notif, required this.onNavigate});

  static IconData iconFor(String type) => switch (type) {
        'achievement' => Icons.emoji_events_outlined,
        'booking'     => Icons.calendar_today_rounded,
        'tier'        => Icons.shield_outlined,
        _             => Icons.waving_hand_rounded,
      };

  static Color accentFor(String type) =>
      type == 'achievement' ? AppColors.accentOrange : AppColors.primary;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day} ${_months[t.month - 1]}';
  }

  void _openDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => NotifDetailDialog(
        notif: notif,
        onOpen: notif.action != null ? () => onNavigate(notif.action) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon   = iconFor(notif.iconType);
    final accent = accentFor(notif.iconType);

    return GestureDetector(
      onTap: () => _openDetail(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo(notif.timestamp),
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail dialog
// ─────────────────────────────────────────────────────────────────────────────

class NotifDetailDialog extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback? onOpen;
  const NotifDetailDialog(
      {super.key, required this.notif, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final icon   = NotifTile.iconFor(notif.iconType);
    final accent = NotifTile.accentFor(notif.iconType);
    final time   = NotifTile.timeAgo(notif.timestamp);

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 22, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(notif.title,
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(time,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textHint)),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 14),
            Text(notif.body,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Close',
                        style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ),
                ),
                if (onOpen != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onOpen!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Open',
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
