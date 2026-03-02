class PomodoroSettings {
  final int focusMinutes;
  final int focusSeconds;
  final int breakMinutes;
  final int breakSeconds;
  final int cycles;

  const PomodoroSettings({
    this.focusMinutes = 25,
    this.focusSeconds = 0,
    this.breakMinutes = 5,
    this.breakSeconds = 0,
    this.cycles = 4,
  });

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? focusSeconds,
    int? breakMinutes,
    int? breakSeconds,
    int? cycles,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      cycles: cycles ?? this.cycles,
    );
  }

  // 集中時間を秒単位で取得
  int get focusTotalSeconds => focusMinutes * 60 + focusSeconds;

  // 休憩時間を秒単位で取得
  int get breakTotalSeconds => breakMinutes * 60 + breakSeconds;
}
