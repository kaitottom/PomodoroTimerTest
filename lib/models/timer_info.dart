enum TimerState {
  stopped, // 停止中
  running, // 実行中
  paused, // 一時停止中
}

enum TimerType {
  focus, // 集中時間
  break_, // 休憩時間
}

class TimerInfo {
  final TimerState state;
  final TimerType type;
  final int remainingSeconds;
  final int currentCycle;
  final int totalCycles;
  final DateTime? endTime;
  final DateTime? startTime; // 開始時刻（スコア計算用）

  const TimerInfo({
    this.state = TimerState.stopped,
    this.type = TimerType.focus,
    this.remainingSeconds = 0,
    this.currentCycle = 1,
    this.totalCycles = 4,
    this.endTime,
    this.startTime,
  });

  TimerInfo copyWith({
    TimerState? state,
    TimerType? type,
    int? remainingSeconds,
    int? currentCycle,
    int? totalCycles,
    DateTime? endTime,
    DateTime? startTime,
  }) {
    return TimerInfo(
      state: state ?? this.state,
      type: type ?? this.type,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      endTime: endTime ?? this.endTime,
      startTime: startTime ?? this.startTime,
    );
  }
}

//タイマー終了時の通知
enum NotificationStyle {
  silent,
  vibration,
  sound,
  both,
}

