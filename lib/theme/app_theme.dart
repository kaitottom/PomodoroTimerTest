import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // シードカラーから全体の色相を生成し、一貫性を保つ
      colorScheme: ColorScheme.fromSeed(
        seedColor: ParadiseColors.primaryTeal,
        primary: ParadiseColors.primaryTeal,
        secondary: ParadiseColors.accentGold,
        surface: ParadiseColors.skyBackground,
      ),

      // AppBar：高級感を出すためにセンタータイトルと透過感を設定
      appBarTheme: const AppBarTheme(
        backgroundColor: ParadiseColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // 入力欄：画像のような清潔感を出すため、白背景と細い枠線
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ParadiseColors.skyBackground,
        hoverColor: ParadiseColors.groundBlue,
        focusColor: ParadiseColors.crystalRock,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ParadiseColors.primaryTeal),
        ),
      ),

      // スライダー：ゴールドとティールの組み合わせ
      sliderTheme: const SliderThemeData(
        activeTrackColor: ParadiseColors.subaccentGold,
        thumbColor: ParadiseColors.accentGold,
        inactiveTrackColor: ParadiseColors.cloudGrey,
      ),
    );
  }
}