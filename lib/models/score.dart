import '../models/goal_with_tasks.dart';

class SessionData {
  final GoalWithTasks? goal; // 目標データ (Driftの型)
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMinutes; // 経過時間(分)
  final int focusMinutes;
  final int concentrationLevel; // ユーザー入力の集中度
  final String? goodPoints; // 良かった点（感想）
  final String? improvementPoints; // 改善点
  final String? futurePlans; // 今後の方針

  const SessionData({
    required this.goal,
    required this.startedAt,
    required this.endedAt,
    required this.durationMinutes,
    required this.focusMinutes,
    required this.concentrationLevel,
    this.goodPoints,
    this.improvementPoints,
    this.futurePlans,
  });
}

// 評価方法の種類
/*
enum EvaluationMode {
  aggregate, // まとめて評価
  perTask, // 一つずつ評価
}
 */

// 集中時間からスコア化するクラス
class ConcentrationScore {
  final int totalMinutes; // 実働集中時間（分）
  final int concentrationLevel; // 集中度（1〜100）
  final double sessionMultiplier; // セッション倍率

  const ConcentrationScore({
    required this.totalMinutes,
    required this.concentrationLevel,
    this.sessionMultiplier = 1.0,
  });

  ConcentrationScore copyWith({
    int? totalMinutes,
    int? concentrationLevel,
    double? sessionMultiplier,
  }) {
    return ConcentrationScore(
      totalMinutes: totalMinutes ?? this.totalMinutes,
      concentrationLevel: concentrationLevel ?? this.concentrationLevel,
      sessionMultiplier: sessionMultiplier ?? this.sessionMultiplier,
    );
  }

  /*
  double calculateConcentrationScore() {
    final validConcentration = concentrationLevel.clamp(1, 100);
    final baseScore = calculateBaseScore(totalMinutes);
    return (baseScore * validConcentration) / 10;
  }

  // ベーススコアを計算（10分未満でも1点）
  double calculateBaseScore(int totalMinutes) {
    // 10分ごとに1点

    double baseScore = (totalMinutes / 10).ceil().toDouble();
    if (baseScore < 1) baseScore = 1;

    // --- 150分でピークを迎えるボーナス係数を乗算 ---
    const peakTime = 150.0;
    const peakBonusMultiplier = 2.2;
    const spread = 90.0;
    final x = totalMinutes.toDouble();

    // ガウス関数 `exp(-((x - μ)^2) / (2σ^2))` の指数部分を計算
    final exponent = -math.pow(x - peakTime, 2) / (2 * math.pow(spread, 2));
    //eの指数乗を計算し、ボーナス係数を算出
    final bonusMultiplier = 1.0 + (peakBonusMultiplier - 1.0) * math.exp(exponent);

    // 基本スコアにボーナス係数を乗算
    return baseScore * bonusMultiplier;
  }


  // セッション倍率を計算
  double calculateSessionMultiplier() {
    // 長時間のセッションにボーナス（最大+20%）
    //return 1.0 + (totalMinutes / 100).clamp(0.0, 1.0) * 0.2;
    return 1.0;
  }

  // 集中度スコアを更新
  ConcentrationScore updateConcentration(int newLevel) {
    final validLevel = newLevel.clamp(0, 100);
    final newMultiplier = calculateSessionMultiplier();
    return copyWith(
      concentrationLevel: validLevel,
      sessionMultiplier: newMultiplier,
    );
  }*/
}

// タスクごとのスコア計算クラス
class TaskScore {
  final int id;
  final String taskName;
  final int importance; // Taskのimportance（1〜5）
  final int difficulty; // Taskのdifficulty（1〜5）
  int achievePercent; // 達成度（0〜100）
  final double weightedScore; // 計算された重み付きスコア

  TaskScore({
    required this.id,
    required this.taskName,
    required this.importance,
    required this.difficulty,
    this.achievePercent = 0,
    this.weightedScore = 0.0,
  });

  TaskScore copyWith({
    int? id,
    String? taskName,
    int? importance,
    int? difficulty,
    int? achievePercent,
    double? weightedScore,
  }) {
    return TaskScore(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      importance: importance ?? this.importance,
      difficulty: difficulty ?? this.difficulty,
      achievePercent: achievePercent ?? this.achievePercent,
      weightedScore: weightedScore ?? this.weightedScore,
    );
  }

  // タスクスコアを計算
  /*
  double calculateTaskScore(int concentrationLevel) {
    final validAchieve = achievePercent.clamp(0, 100);

    //final validConcentration = concentrationLevel.clamp(1, 100);
    // 集中度による補正係数 (例: 集中度60なら1.0倍, 100なら1.2倍)
    final validConcentration = 1.0 + (concentrationLevel.clamp(1, 100) / 100) * 1.0;

    // スコア式: (difficulty + importance) × (achieve × concentration/10000)
    return (difficulty + importance) * 10 * (validAchieve / 100) * validConcentration;

  }

  // 達成度を更新
  TaskScore updateAchieve(int newAchieve) {
    final validAchieve = newAchieve.clamp(0, 100);
    return copyWith(achievePercent: validAchieve);
  }

  // 重み付きスコアを更新
  TaskScore updateWeightedScore(int concentrationLevel) {
    final score = calculateTaskScore(concentrationLevel);
    return copyWith(weightedScore: score);
  }*/
}

// スコア合計を管理するクラス
class Score {
  //final int id;
  final DateTime startedAt; // セッション開始時刻
  final DateTime endedAt; // セッション終了時刻
  final ConcentrationScore concentrationScore; // 集中度スコア
  //final EvaluationMode evaluationMode; // 評価方法
  final int? goalId; // 関連する目標ID
  final String? goalName; // 目標名
  final List<TaskScore> taskScores; // タスクスコアのリスト
  final double totalScore; // 合計スコア
  final String? goodPoints; // 良かった点（感想）
  final String? improvementPoints; // 改善点
  final String? futurePlans; // 今後の方針

  const Score({
    //required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.concentrationScore,
    //required this.evaluationMode,
    this.goalId,
    this.goalName,
    this.taskScores = const [],
    this.totalScore = 0.0,
    this.goodPoints,
    this.improvementPoints,
    this.futurePlans,
  });

  Score copyWith({
    //int? id,
    DateTime? startedAt,
    DateTime? endedAt,
    ConcentrationScore? concentrationScore,
    //EvaluationMode? evaluationMode,
    int? goalId,
    String? goalName,
    List<TaskScore>? taskScores,
    double? totalScore,
    String? goodPoints,
    String? improvementPoints,
    String? futurePlans,
  }) {
    return Score(
      //id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      concentrationScore: concentrationScore ?? this.concentrationScore,
      //evaluationMode: evaluationMode ?? this.evaluationMode,
      goalId: goalId ?? this.goalId,
      goalName: goalName ?? this.goalName,
      taskScores: taskScores ?? this.taskScores,
      totalScore: totalScore ?? this.totalScore,
      goodPoints: goodPoints ?? this.goodPoints,
      improvementPoints: improvementPoints ?? this.improvementPoints,
      futurePlans: futurePlans ?? this.futurePlans,
    );
  }

  // 合計スコアを計算
  /*
  double calculateTotalScore() {
    final concentrationPart = concentrationScore.calculateConcentrationScore();

    if (taskScores.isEmpty) {
    //タスクなしの場合のボーナス係数  この値を調整することで、タスクありの場合のスコア感に近づける
    const noTaskBonusMultiplier = 2.4;

    return concentrationPart * noTaskBonusMultiplier;

    } else {
    // タスクスコアの合計 × セッション倍率
    final taskSum = taskScores.fold<double>(
      0.0,
      (sum, task) => sum + task.weightedScore,
    );
    return taskSum + concentrationPart;
    }
  }

  // 集中度を更新
  Score updateConcentration(int newLevel) {
    final updatedConcentrationScore = concentrationScore.updateConcentration(
      newLevel,
    );
    return copyWith(concentrationScore: updatedConcentrationScore);
  }

  // 評価方法を更新
  /*
  Score updateEvaluationMode(EvaluationMode mode) {
    return copyWith(evaluationMode: mode);
  }
  */

  // まとめて評価で達成度を更新
  Score applyAchieveAggregate(int percent) {
    final validPercent = percent.clamp(0, 100);
    final updatedTaskScores = taskScores
        .map(
          (task) => task
              .updateAchieve(validPercent)
              .updateWeightedScore(concentrationScore.concentrationLevel),
        )
        .toList();

    return copyWith(taskScores: updatedTaskScores);
  }

  // 個別タスクの達成度を更新
  Score updateAchievePerTask(int taskIndex, int percent) {
    if (taskIndex < 0 || taskIndex >= taskScores.length) {
      return this;
    }

    final updatedTaskScores = List<TaskScore>.from(taskScores);
    updatedTaskScores[taskIndex] = updatedTaskScores[taskIndex]
        .updateAchieve(percent)
        .updateWeightedScore(concentrationScore.concentrationLevel);

    return copyWith(taskScores: updatedTaskScores);
  }

  // スコアを再計算
  Score recalc() {
    final totalScore = calculateTotalScore();
    return copyWith(totalScore: totalScore);
  }*/
}

/*
// スコア履歴の統計情報
class ScoreStatistics {
  final int totalSessions;
  final double totalScore;
  final double averageScore;
  final int totalMinutes;
  final double averageConcentration;
  final DateTime? lastSessionDate;

  const ScoreStatistics({
    this.totalSessions = 0,
    this.totalScore = 0.0,
    this.averageScore = 0.0,
    this.totalMinutes = 0,
    this.averageConcentration = 0.0,
    this.lastSessionDate,
  });

  // リストから統計を計算
  factory ScoreStatistics.fromScores(List<Score> scores) {
    if (scores.isEmpty) {
      return const ScoreStatistics();
    }

    final totalScore = scores.fold<double>(
      0.0,
      (sum, score) => sum + score.totalScore,
    );
    final totalMinutes = scores.fold<int>(
      0,
      (sum, score) => sum + score.concentrationScore.totalMinutes,
    );
    final totalConcentration = scores.fold<int>(
      0,
      (sum, score) => sum + score.concentrationScore.concentrationLevel,
    );

    return ScoreStatistics(
      totalSessions: scores.length,
      totalScore: totalScore,
      averageScore: totalScore / scores.length,
      totalMinutes: totalMinutes,
      averageConcentration: totalConcentration / scores.length,
      lastSessionDate: scores.last.endedAt,
    );
  }
}
*/
