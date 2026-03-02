// プロバイダーのエクスポートファイル
export 'providers/pomodoro_settings_provider.dart';
export 'providers/timer_provider.dart';
export 'providers/goal_settings_provider.dart';
export 'providers/task_provider.dart';
export 'providers/score_provider.dart';
export 'providers/app_settings_provider.dart';
export 'providers/notification_provider.dart';
export 'providers/database_provider.dart';

// 既存のプロバイダー（後で削除予定）
import 'package:flutter_riverpod/flutter_riverpod.dart';

final endTimeProvider = StateProvider<DateTime?>((ref) => null);

// 残り秒数を計算するProvider
final remainingSecondsProvider = Provider<int>((ref) {
  final endTime = ref.watch(endTimeProvider);
  if (endTime == null) return 0;

  final now = DateTime.now();
  final diff = endTime.difference(now);
  return diff.inSeconds > 0 ? diff.inSeconds : 0;
});
