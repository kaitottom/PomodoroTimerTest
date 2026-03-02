/*import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pomodoro_settings.dart';

final pomodoroSettingsProvider =
    StateNotifierProvider<PomodoroSettingsNotifier, PomodoroSettings>((ref) {
      return PomodoroSettingsNotifier();
    });

class PomodoroSettingsNotifier extends StateNotifier<PomodoroSettings> {
  PomodoroSettingsNotifier() : super(const PomodoroSettings());

  void updateFocusMinutes(int minutes) {
    state = state.copyWith(focusMinutes: minutes);
  }

  void updateBreakMinutes(int minutes) {
    state = state.copyWith(breakMinutes: minutes);
  }

  void updateCycles(int cycles) {
    state = state.copyWith(cycles: cycles);
  }
}

 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加
import '../models/pomodoro_settings.dart';

// 設定を保存するためのキー定数
const _kFocusMinutesKey = 'focus_minutes';
const _kFocusSecondsKey = 'focus_seconds';
const _kBreakMinutesKey = 'break_minutes';
const _kBreakSecondsKey = 'break_seconds';
const _kCyclesKey = 'cycles';

final pomodoroSettingsProvider =
    StateNotifierProvider<PomodoroSettingsNotifier, PomodoroSettings>((ref) {
      return PomodoroSettingsNotifier();
    });

class PomodoroSettingsNotifier extends StateNotifier<PomodoroSettings> {
  // コンストラクタで初期化と同時にロードを開始
  PomodoroSettingsNotifier() : super(const PomodoroSettings()) {
    _loadSettings();
  }

  // 設定を読み込む
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final focusMinutes = prefs.getInt(_kFocusMinutesKey);
    final focusSeconds = prefs.getInt(_kFocusSecondsKey);
    final breakMinutes = prefs.getInt(_kBreakMinutesKey);
    final breakSeconds = prefs.getInt(_kBreakSecondsKey);
    final cycles = prefs.getInt(_kCyclesKey);

    // 保存された値がある場合のみ更新 (なければモデルの初期値のまま)
    if (focusMinutes != null ||
        focusSeconds != null ||
        breakMinutes != null ||
        breakSeconds != null ||
        cycles != null) {
      state = state.copyWith(
        focusMinutes: focusMinutes ?? state.focusMinutes,
        focusSeconds: focusSeconds ?? state.focusSeconds,
        breakMinutes: breakMinutes ?? state.breakMinutes,
        breakSeconds: breakSeconds ?? state.breakSeconds,
        cycles: cycles ?? state.cycles,
      );
    }
  }

  // 設定を保存するヘルパー関数
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFocusMinutesKey, state.focusMinutes);
    await prefs.setInt(_kFocusSecondsKey, state.focusSeconds);
    await prefs.setInt(_kBreakMinutesKey, state.breakMinutes);
    await prefs.setInt(_kBreakSecondsKey, state.breakSeconds);
    await prefs.setInt(_kCyclesKey, state.cycles);
  }

  // --- 更新用メソッド (更新後に保存を実行) ---

  void updateFocusMinutes(int minutes) {
    state = state.copyWith(focusMinutes: minutes);
    _saveSettings(); // 保存
  }

  void updateFocusSeconds(int seconds) {
    state = state.copyWith(focusSeconds: seconds);
    _saveSettings(); // 保存
  }

  void updateBreakMinutes(int minutes) {
    state = state.copyWith(breakMinutes: minutes);
    _saveSettings(); // 保存
  }

  void updateBreakSeconds(int seconds) {
    state = state.copyWith(breakSeconds: seconds);
    _saveSettings(); // 保存
  }

  void updateCycles(int cycles) {
    state = state.copyWith(cycles: cycles);
    _saveSettings(); // 保存
  }
}
