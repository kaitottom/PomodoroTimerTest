import 'timer_info.dart';

/// 休憩画面の背景タイプ
enum BreakBackgroundType {
  forest, // 森
  sea,    // 海
  undersea, // 海中
  onsen,  // 温泉
  sky,   //空
  lavender, //ラベンダー
  snow,  //雪空

  // 今後キャラクターを追加する場合:
  // character1,
  // character2,
  // etc.
}

/// アプリ設定
class AppSettings {
  final bool showBreakScreen; // 休憩画面を表示するか
  final BreakBackgroundType breakBackgroundType; // 休憩画面の背景タイプ
  final NotificationStyle notificationStyle; // 通知スタイル（既存のenumを使用）
  final bool isBackgroundEnabled;

  const AppSettings({
    this.showBreakScreen = true,
    this.breakBackgroundType = BreakBackgroundType.forest,
    this.notificationStyle = NotificationStyle.vibration,
    this.isBackgroundEnabled = false,
  });

  AppSettings copyWith({
    bool? showBreakScreen,
    BreakBackgroundType? breakBackgroundType,
    NotificationStyle? notificationStyle,
    bool? isBackgroundEnabled,
  }) {
    return AppSettings(
      showBreakScreen: showBreakScreen ?? this.showBreakScreen,
      breakBackgroundType: breakBackgroundType ?? this.breakBackgroundType,
      notificationStyle: notificationStyle ?? this.notificationStyle,
      isBackgroundEnabled: isBackgroundEnabled ?? this.isBackgroundEnabled,
    );
  }

  /// SharedPreferences用のMapに変換
  Map<String, dynamic> toJson() {
    return {
      'showBreakScreen': showBreakScreen,
      'breakBackgroundType': breakBackgroundType.index,
      'notificationStyle': notificationStyle.index,
      'isBackgroundEnabled': isBackgroundEnabled, // 追加: バックグラウンドでのタイマー動作の有効/無効'
    };
  }

  /// SharedPreferencesのMapから作成
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      showBreakScreen: json['showBreakScreen'] as bool? ?? true,
      breakBackgroundType: BreakBackgroundType.values[
        json['breakBackgroundType'] as int? ?? 0
      ],
      notificationStyle: NotificationStyle.values[
        json['notificationStyle'] as int? ?? 1
      ],
    );
  }
}

