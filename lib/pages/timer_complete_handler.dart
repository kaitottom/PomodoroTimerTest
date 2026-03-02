import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timer_info.dart';
import '../providers/notification_provider.dart';
import '../../utils/haptic_util.dart';

void onTimerComplete(BuildContext context, WidgetRef ref) {
  final style = ref.read(notificationStyleProvider);

  if (style == NotificationStyle.vibration ||
      style == NotificationStyle.both) {
    playCompletionHaptic();
  }

  if (style == NotificationStyle.sound ||
      style == NotificationStyle.both) {
    playGentleBell();
  }

  showTopBanner(
    context,
    message: '集中時間が終了しました',
    duration: const Duration(seconds: 3),
  );
}

void showTopBanner(
    BuildContext context, {
      required String message,
      Duration duration = const Duration(seconds: 3),
    }) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

