/*import 'package:pomo_timer/models/goal_with_tasks.dart';

import '../models/score.dart';

/// スコア計算に関するユーティリティクラス
class ScoreUtils {
  /// 集中度スコアを計算
  ///
  /// [concentrationScore] 集中度スコア情報
  /// 戻り値: 計算された集中度スコア
  static double calculateConcentrationScore(
    ConcentrationScore concentrationScore,
  ) {
    return concentrationScore.calculateConcentrationScore();
  }

  /// タスクスコアを計算
  ///
  /// [taskScore] タスクスコア情報
  /// [concentrationLevel] 集中度（0〜100）
  /// 戻り値: 計算されたスコア
  static double calculateTaskScore(
    TaskScore taskScore,
    int concentrationLevel,
  ) {
    return taskScore.calculateTaskScore(concentrationLevel);
  }

  /// 合計スコアを計算
  ///
  /// [score] スコア情報
  /// 戻り値: 合計スコア
  static double calculateTotalScore(Score score) {
    return score.calculateTotalScore();
  }

  /// 入力値のバリデーション
  ///
  /// [concentrationLevel] 集中度
  /// [achievePercent] 達成度
  /// 戻り値: バリデーション結果（エラーメッセージがあれば）
  static String? validateInputs(int concentrationLevel, int achievePercent) {
    if (concentrationLevel < 0 || concentrationLevel > 100) {
      return '集中度は0〜100の範囲で入力してください';
    }
    if (achievePercent < 0 || achievePercent > 100) {
      return '達成度は0〜100の範囲で入力してください';
    }
    return null;
  }

  /// スコアの評価レベルを取得
  ///
  /// [score] スコア値
  /// 戻り値: 評価レベル（S, A, B, C, D）
  static String getScoreLevel(double score) {
    if (score >= 80) return 'S';
    if (score >= 60) return 'A';
    if (score >= 40) return 'B';
    if (score >= 20) return 'C';
    return 'D';
  }

  /// 日付範囲でスコアをフィルタリング
  ///
  /// [scores] スコアリスト
  /// [startDate] 開始日
  /// [endDate] 終了日
  /// 戻り値: フィルタリングされたスコアリスト
  static List<Score> filterScoresByDateRange(
    List<Score> scores,
    DateTime startDate,
    DateTime endDate,
  ) {
    return scores.where((score) {
      final scoreDate = score.endedAt;
      return scoreDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          scoreDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 今日のスコアを取得
  ///
  /// [scores] スコアリスト
  /// 戻り値: 今日のスコアリスト
  static List<Score> getTodayScores(List<Score> scores) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return filterScoresByDateRange(scores, today, tomorrow);
  }

  /// 今週のスコアを取得
  ///
  /// [scores] スコアリスト
  /// 戻り値: 今週のスコアリスト
  static List<Score> getThisWeekScores(List<Score> scores) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekEndDate = weekStartDate.add(const Duration(days: 7));

    return filterScoresByDateRange(scores, weekStartDate, weekEndDate);
  }

  /// 新しいスコアを作成
  ///
  /// [id] スコアID
  /// [startedAt] 開始時刻
  /// [endedAt] 終了時刻
  /// [totalMinutes] 実働集中時間（分）
  /// [goal] 関連する目標（nullの場合は目標なし）
  /// 戻り値: 新しいスコア
  static Score createNewScore({
    required int id,
    required DateTime startedAt,
    required DateTime endedAt,
    required int totalMinutes,
    GoalWithTasks? goal,
  }) {
    // 目標からタスクスコアを生成
    final taskScores =
        goal?.tasks
            .map(
              (task) => TaskScore(
                id: task.id,
                taskName: task.task,
                difficulty: task.difficulty,
                impact: task.impact,
                achievePercent: 0, // 初期値は0
              ),
            )
            .toList() ??
        [];

    // 集中度スコアを作成
    final concentrationScore = ConcentrationScore(
      totalMinutes: totalMinutes,
      concentrationLevel: 60, // デフォルト値
    );

    return Score(
      //id: id,
      startedAt: startedAt,
      endedAt: endedAt,
      concentrationScore: concentrationScore,
      //evaluationMode: EvaluationMode.aggregate, // デフォルトはまとめて
      goalId: goal?.goal.id,
      goalName: goal?.goal.goal,
      taskScores: taskScores,
    );
  }
}
*/