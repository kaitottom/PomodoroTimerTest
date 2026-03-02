import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timer_info.dart';
import '../models/pomodoro_settings.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

import '../utils/haptic_util.dart';
import 'notification_provider.dart';

final timerInfoProvider = StateNotifierProvider<TimerInfoNotifier, TimerInfo>((
  ref,
) {
  return TimerInfoNotifier(ref);
});

class TimerInfoNotifier extends StateNotifier<TimerInfo> {
  TimerInfoNotifier(this.ref) : super(const TimerInfo());

  final Ref ref;
  final AudioPlayer _player = AudioPlayer();

  void startTimer(PomodoroSettings settings) {
    final focusSeconds = settings.focusTotalSeconds;
    final now = DateTime.now();
    final endTime = now.add(Duration(seconds: focusSeconds)).add(const Duration(milliseconds: 500));
    state = state.copyWith(
      state: TimerState.running,
      type: TimerType.focus,
      remainingSeconds: focusSeconds,
      currentCycle: 1,
      totalCycles: settings.cycles,
      endTime: endTime,
      startTime: now, // 開始時刻を記録
    );
  }

  void pauseTimer() {
    if (state.state == TimerState.running) {
      state = state.copyWith(state: TimerState.paused);
    }
  }

  void resumeTimer() {
    if (state.state == TimerState.paused) {
      final remainingSeconds = state.remainingSeconds;
      final endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
      state = state.copyWith(state: TimerState.running, endTime: endTime);
    }
  }

  void stopTimer() {
    state = const TimerInfo();
  }

  void updateRemainingSeconds(int seconds) {
    state = state.copyWith(remainingSeconds: seconds);
  }

  Future<void> switchToBreak(PomodoroSettings settings) async {
    // 音を再生中は一時的にタイマーを停止
    state = state.copyWith(state: TimerState.paused);

    // 音を再生
    await _playNotificationSound();

    // 音が鳴り終わったら休憩時間を開始
    final breakSeconds = settings.breakTotalSeconds;
    final now = DateTime.now();
    final endTime = now.add(Duration(seconds: breakSeconds)).add(const Duration(milliseconds: 500));;

    state = state.copyWith(
      state: TimerState.running,
      type: TimerType.break_,
      remainingSeconds: breakSeconds,
      endTime: endTime,
    );
  }

  Future<void> switchToFocus(PomodoroSettings settings) async {
    // 音を再生中は一時的にタイマーを停止
    state = state.copyWith(state: TimerState.paused);

    // 音を再生
    await _playNotificationSound();

    // 音が鳴り終わったら集中時間を開始
    final focusSeconds = settings.focusTotalSeconds;
    final now = DateTime.now();
    final endTime = now.add(Duration(seconds: focusSeconds)).add(const Duration(milliseconds: 500));;
    final nextCycle = state.currentCycle + 1;

    state = state.copyWith(
      state: TimerState.running,
      type: TimerType.focus,
      remainingSeconds: focusSeconds,
      currentCycle: nextCycle,
      endTime: endTime,
    );
  }

  void stopTimerWithSettings(PomodoroSettings settings) {
    state = TimerInfo(
      state: TimerState.stopped,
      type: TimerType.focus,
      remainingSeconds: settings.focusTotalSeconds,
      currentCycle: 1,
      totalCycles: settings.cycles,
      endTime: null,
    );
  }

  Future<void> _playNotificationSound() async {
    final style = ref.read(notificationStyleProvider);

    if (style == NotificationStyle.vibration ||
        style == NotificationStyle.both) {
      playCompletionHaptic();
    }

    try {
      // 3回連続で音を再生
      if (style == NotificationStyle.sound ||
          style == NotificationStyle.both) {
        for (int i = 0; i < 3; i++) {
          await _player.play(AssetSource('sounds/beep.mp3'));

          // 音の再生時間を待つ（beep.mp3の長さに応じて調整）
          await Future.delayed(const Duration(milliseconds: 300));
          await _player.stop();

          // 音の間隔を少し空ける（0.2秒）
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } catch (e) {
      // エラーが発生してもタイマーの動作に影響しないようにする
      //print('音声再生エラー: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final formattedTimeProvider = Provider<String>((ref) {
  final timerInfo = ref.watch(timerInfoProvider);
  final minutes = timerInfo.remainingSeconds ~/ 60;
  final seconds = timerInfo.remainingSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
});

final timerStateTextProvider = Provider<String>((ref) {
  final timerInfo = ref.watch(timerInfoProvider);
  switch (timerInfo.type) {
    case TimerType.focus:
      return '集中時間';
    case TimerType.break_:
      return '休憩時間';
    default:
      return '';
  }
});
