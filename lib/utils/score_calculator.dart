import 'dart:math' as math;

class ScoreCalculator {
  /// 集中時間と集中度から、ベースとなる集中スコアを計算します。
  /// [totalMinutes]: 実働集中時間（分）
  /// [concentrationLevel]: 集中度（1〜100）
  static double calculateConcentrationPart(int totalMinutes, int concentrationLevel) {
    // --- ベーススコア計算 ---
    // 10分ごとに1点 (10分未満でも1点)
    double baseScore = (totalMinutes / 10).ceil().toDouble();
    if (baseScore < 1) baseScore = 1;

    // --- ガウス関数によるボーナス計算 (150分でピーク) ---
    const peakTime = 150.0;
    const peakBonusMultiplier = 2.2;
    const spread = 90.0;
    final x = totalMinutes.toDouble();

    // exp(-((x - μ)^2) / (2σ^2))
    final exponent = -math.pow(x - peakTime, 2) / (2 * math.pow(spread, 2));
    final bonusMultiplier = 1.0 + (peakBonusMultiplier - 1.0) * math.exp(exponent);

    final finalBaseScore = baseScore * bonusMultiplier;

    // --- 集中度による補正 ---
    final validConcentration = concentrationLevel.clamp(1, 100);

    // (ベーススコア * 集中度) / 10
    return (finalBaseScore * validConcentration) / 10;
  }


  /// タスク1つあたりの重み付きスコアを計算します。
  /// [difficulty]: 難易度 (1-5)
  /// [importance]: 重要度 (1-5)
  /// [achievePercent]: 達成度 (0-100)
  /// [concentrationLevel]: 集中度 (1-100) ※タスクスコアの計算係数にも使用されます
  static double calculateTaskScore({
    required int importance,
    required int difficulty,
    required int achievePercent,
    required int concentrationLevel,
  }) {
    final validAchieve = achievePercent.clamp(0, 100);

    // 集中度による補正係数 (例: 集中度60なら1.6倍、100なら2.0倍)
    // score.dart: 1.0 + (concentrationLevel.clamp(1, 100) / 100) * 1.0;
    final validConcentrationMultiplier = 1.0 + (concentrationLevel.clamp(1, 100) / 100) * 1.0;

    // スコア式: (difficulty + importance) × 10 × (achieve / 100) × concentrationMultiplier
    return (difficulty + importance) * 10 * (validAchieve / 100) * validConcentrationMultiplier;
  }


  /// セッション全体の合計スコアを算出します。
  /// [taskWeightedScores]: 各タスクの計算済みスコアのリスト (合計計算用)
  /// [totalMinutes]: 集中時間
  /// [concentrationLevel]: 集中度
  static double calculateTotalScore({
    required List<double> taskWeightedScores,
    required int totalMinutes,
    required int concentrationLevel,
  }) {
    // まず集中度部分のスコアを計算
    final concentrationPart = calculateConcentrationPart(totalMinutes, concentrationLevel);

    if (taskWeightedScores.isEmpty) {
      // タスクなしの場合のボーナス係数 (score.dart: const noTaskBonusMultiplier = 2.4)
      const noTaskBonusMultiplier = 2.4;
      return concentrationPart * noTaskBonusMultiplier;
    } else {
      // タスクありの場合: タスクスコアの合計 + 集中度スコア
      final taskSum = taskWeightedScores.fold<double>(
        0.0,
            (sum, score) => sum + score,
      );
      return taskSum + concentrationPart;
    }
  }

}
