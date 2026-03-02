import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_info.dart';

final notificationStyleProvider =
StateNotifierProvider<NotificationStyleNotifier, NotificationStyle>(
      (ref) => NotificationStyleNotifier(),
);

class NotificationStyleNotifier extends StateNotifier<NotificationStyle> {
  NotificationStyleNotifier() : super(NotificationStyle.silent) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('notificationStyle') ?? 1;
    state = NotificationStyle.values[index];
  }

  Future<void> setStyle(NotificationStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationStyle', style.index);
  }
}
