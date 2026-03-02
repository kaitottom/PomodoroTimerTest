import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../models/timer_info.dart';

/// アプリ設定のプロバイダー
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  /// SharedPreferencesから設定を読み込み
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('appSettings');
      
      if (settingsJson != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(settingsJson);
        state = AppSettings.fromJson(jsonMap);
      }
    } catch (e) {
      // エラー時はデフォルト値を使用
      state = const AppSettings();
    }
  }

  /// 設定を保存
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(state.toJson());
      await prefs.setString('appSettings', settingsJson);
    } catch (e) {
      // エラーハンドリング（必要に応じて）
    }
  }

  /// 休憩画面表示の設定を更新
  Future<void> setShowBreakScreen(bool show) async {
    state = state.copyWith(showBreakScreen: show);
    await _save();
  }

  /// 休憩画面の背景タイプを更新
  Future<void> setBreakBackgroundType(BreakBackgroundType type) async {
    state = state.copyWith(breakBackgroundType: type);
    await _save();
  }

  /// 通知スタイルを更新
  Future<void> setNotificationStyle(NotificationStyle style) async {
    state = state.copyWith(notificationStyle: style);
    await _save();
  }

  Future<void> setIsBackgroundEnabled(bool isEnabled) async {
    state = state.copyWith(isBackgroundEnabled: isEnabled);
    await _save();
  }

  /// 設定を一括更新
  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _save();
  }
}

