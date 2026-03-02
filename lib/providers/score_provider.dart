import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/score.dart';
import 'package:pomo_timer/data/database/daos/score_dao.dart'; // ScoreDao, ScoreStatistics, ScoreWithDetails
import 'package:pomo_timer/providers/database_provider.dart'; // scoreDaoProviderがある場所

// 現在のセッションスコアを管理するプロバイダー
final currentSessionScoreProvider =
    StateNotifierProvider<CurrentSessionScoreNotifier, Score?>((ref) {
      return CurrentSessionScoreNotifier();
    });
/*
// スコア履歴を管理するプロバイダー
final scoreHistoryProvider =
    StateNotifierProvider<ScoreHistoryNotifier, List<Score>>((ref) {
      return ScoreHistoryNotifier();
    });
*/

// 日付計算のヘルパー関数
DateTime _getTodayStart() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _getTodayEnd() => _getTodayStart().add(const Duration(days: 1));

DateTime _getThisWeekStart() {
  final now = DateTime.now();
  // 月曜始まりにする (日曜始まりなら days: now.weekday)
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
}

DateTime _getThisWeekEnd() => _getThisWeekStart().add(const Duration(days: 7));

/*
// 今日の統計
final todayStatsProvider = FutureProvider<ScoreStatistics>((ref) async {
  final dao = ref.watch(scoreDaoProvider);
  return dao.getStatsByRange(_getTodayStart(), _getTodayEnd());
});

// 今週の統計
final thisWeekStatsProvider = FutureProvider<ScoreStatistics>((ref) async {
  final dao = ref.watch(scoreDaoProvider);
  return dao.getStatsByRange(_getThisWeekStart(), _getThisWeekEnd());
});

// ---------------------------------------------------------
// リスト取得用プロバイダー (詳細画面用)
// 期間を指定してスコア一覧を取得するファミリープロバイダー
// 引数として (start, end) のRecordを受け取る
final scoresInDateRangeProvider = FutureProvider.family<List<ScoreWithDetails>, ({DateTime start, DateTime end})>((ref, range) async {
  final dao = ref.watch(scoreDaoProvider);
  return dao.getScoresByDateRange(range.start, range.end);
});
*/
// ---------------------------------------------------------
// 統計データ取得用プロバイダー
// ---------------------------------------------------------

// 今日の統計 (StreamProviderに変更)
// データベースが更新されると自動的に再計算されて画面に反映されます
final todayStatsProvider = StreamProvider<ScoreStatistics>((ref) {
  final dao = ref.watch(scoreDaoProvider);
  return dao.watchStatsByRange(_getTodayStart(), _getTodayEnd());
});

// 今週の統計 (StreamProviderに変更)
final thisWeekStatsProvider = StreamProvider<ScoreStatistics>((ref) {
  final dao = ref.watch(scoreDaoProvider);
  return dao.watchStatsByRange(_getThisWeekStart(), _getThisWeekEnd());
});

final draftScoresProvider = StreamProvider(
  (ref) => ref.watch(scoreDaoProvider).watchDraftScores(),
);

// ---------------------------------------------------------
// リスト取得用プロバイダー (詳細画面用)
// ---------------------------------------------------------

// 期間を指定してスコア一覧を取得するファミリープロバイダー (StreamProviderに変更)
final scoresInDateRangeProvider =
    StreamProvider.family<
      List<ScoreWithDetails>,
      ({DateTime start, DateTime end})
    >((ref, range) {
      final dao = ref.watch(scoreDaoProvider);
      return dao.watchScoresByDateRange(range.start, range.end);
    });

// 振り返りがある記録を取得するプロバイダー（全期間）
final reflectionsProvider = StreamProvider<List<ScoreWithDetails>>((ref) {
  final dao = ref.watch(scoreDaoProvider);
  // 専用メソッドを使用して振り返りがある記録を取得
  return dao.watchReflections();
});

/*
// スコア統計情報を提供するプロバイダー-----------------------
final scoreStatisticsProvider = Provider<ScoreStatistics>((ref) {
  final history = ref.watch(scoreHistoryProvider);
  return ScoreStatistics.fromScores(history);
});
*/

/*
// 今日のスコア統計を提供するプロバイダー
final todayScoreStatisticsProvider = Provider<ScoreStatistics>((ref) {
  final history = ref.watch(scoreHistoryProvider);
  final todayScores = ScoreUtils.getTodayScores(history);
  return ScoreStatistics.fromScores(todayScores);
});

// 今週のスコア統計を提供するプロバイダー
final thisWeekScoreStatisticsProvider = Provider<ScoreStatistics>((ref) {
  final history = ref.watch(scoreHistoryProvider);
  final weekScores = ScoreUtils.getThisWeekScores(history);
  return ScoreStatistics.fromScores(weekScores);
});*/

/// 現在のセッションスコアを管理するノーティファイア
class CurrentSessionScoreNotifier extends StateNotifier<Score?> {
  CurrentSessionScoreNotifier() : super(null);

  /*
  int get nextId {
    // 履歴から最大IDを取得して+1
    // 現在のセッションがある場合はそれも考慮
    int maxId = 0;
    if (state != null) {
      maxId = state!.id;
    }
    return maxId + 1;
  }

  /// 新しいセッションを開始
  ///
  /// [startedAt] 開始時刻
  /// [endedAt] 終了時刻
  /// [totalMinutes] 実働集中時間（分）
  /// [goal] 関連する目標（nullの場合は目標なし）
  void startNewSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int totalMinutes,
    GoalWithTasks? goal,
  }) {
    final score = ScoreUtils.createNewScore(
      id: 1,///
      startedAt: startedAt,
      endedAt: endedAt,
      totalMinutes: totalMinutes,
      goal: goal,
    );

    state = score;
  }

  /// 集中度を更新
  ///
  /// [level] 集中度（0〜100）

  void updateConcentration(int level) {
    if (state != null) {
      state = state!.updateConcentration(level);
    }
  }

  /// 評価方法を更新
  ///
  /// [mode] 評価方法

  void updateEvaluationMode(EvaluationMode mode) {
    if (state != null) {
      state = state!.updateEvaluationMode(mode);
    }
  }

  /// まとめて評価で達成度を更新
  ///
  /// [percent] 達成度（0〜100）
  void applyAchieveAggregate(int percent) {
    if (state != null) {
      state = state!.applyAchieveAggregate(percent);
    }
  }

  /// 個別タスクの達成度を更新
  ///
  /// [taskIndex] タスクのインデックス
  /// [percent] 達成度（0〜100）
  void updateAchievePerTask(int taskIndex, int percent) {
    if (state != null) {
      state = state!.updateAchievePerTask(taskIndex, percent);
    }
  }

  /// スコアを再計算
  void recalc() {
    if (state != null) {
      state = state!.recalc();
    }
  }

  /// セッションを確定して履歴に追加
  ///
  /// 戻り値: 確定されたセッションスコア（履歴に追加済み）
  Score? finalize() {
    if (state != null) {
      // 最終計算
      recalc();

      // 確定されたセッションを返す
      final finalizedScore = state!;

      // 状態をクリア
      state = null;

      return finalizedScore;
    }
    return null;
  }

  /// セッションをキャンセル
  void cancel() {
    state = null;
  }*/
}


/*
/// スコア履歴を管理するノーティファイア
class ScoreHistoryNotifier extends StateNotifier<List<Score>> {
  ScoreHistoryNotifier() : super([]);

  /// スコア履歴に追加
  ///
  /// [score] 追加するスコア
  void addScore(Score score) {
    state = [...state, score];
  }

  /// 指定IDのスコアを削除
  ///
  /// [id] 削除するスコアのID
  /*
  void removeScore(int id) {
    state = state.where((score) => score.id != id).toList();
  }
  */

  /// 指定日付範囲のスコアを取得
  ///
  /// [startDate] 開始日
  /// [endDate] 終了日
  /// 戻り値: フィルタリングされたスコアリスト
  List<Score> getScoresByDateRange(DateTime startDate, DateTime endDate) {
    return ScoreUtils.filterScoresByDateRange(state, startDate, endDate);
  }

  /// 今日のスコアを取得
  ///
  /// 戻り値: 今日のスコアリスト
  List<Score> getTodayScores() {
    return ScoreUtils.getTodayScores(state);
  }

  /// 今週のスコアを取得
  ///
  /// 戻り値: 今週のスコアリスト
  List<Score> getThisWeekScores() {
    return ScoreUtils.getThisWeekScores(state);
  }

  /// 指定目標のスコアを取得
  ///
  /// [goalId] 目標ID
  /// 戻り値: 該当目標のスコアリスト
  List<Score> getScoresByGoal(int goalId) {
    return state.where((score) => score.goalId == goalId).toList();
  }

  /// 全履歴をクリア
  void clearAll() {
    state = [];
  }
}

 */

