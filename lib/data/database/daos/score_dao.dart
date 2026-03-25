import 'package:drift/drift.dart';
import 'package:pomo_timer/models/score.dart';
import 'package:pomo_timer/models/task_score_data.dart';
import '../app_database.dart'; // データベース本体
import '../tables/score_tables.dart'; // テーブル定義

part 'score_dao.g.dart'; // ビルド後に生成されるファイル名

@DriftAccessor(tables: [ScoresTable]) // ★変更: TaskScoresTableを削除
class ScoreDao extends DatabaseAccessor<AppDatabase> with _$ScoreDaoMixin {
  ScoreDao(super.db);

  // ---------------------------------------------------------
  // JSON変換ヘルパー
  // ---------------------------------------------------------
  List<TaskScoreData> _parseTaskDataJson(String? jsonStr) {
    return TaskScoreDataJsonConverter.fromJson(jsonStr);
  }

  String _toTaskDataJson(List<TaskScoreData> tasks) {
    return TaskScoreDataJsonConverter.toJson(tasks);
  }

  // ---------------------------------------------------------
  // 1. 保存処理
  // ---------------------------------------------------------
  Future<void> createScoreWithTasks(
    ScoresTableCompanion score,
    List<TaskScoreData> tasks,
  ) {
    // ★変更: JSONで保存（Transaction不要）
    return into(
      scoresTable,
    ).insert(score.copyWith(taskDataJson: Value(_toTaskDataJson(tasks))));
  }

  // ---------------------------------------------------------
  // 2. 取得処理
  // ---------------------------------------------------------
  // 特定のスコアをタスク付きで取得
  Future<ScoreWithDetails?> getScoreById(int id) async {
    final scoreRecord = await (select(
      scoresTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (scoreRecord == null) return null;

    final tasks = _parseTaskDataJson(scoreRecord.taskDataJson);

    return ScoreWithDetails(score: scoreRecord, tasks: tasks);
  }

  // 指定期間のスコアとタスクを全て取得
  Future<List<ScoreWithDetails>> getScoresByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final scoreRecords =
        await (select(scoresTable)
              ..where((t) => t.startedAt.isBetweenValues(start, end))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.startedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    return scoreRecords.map((score) {
      final tasks = _parseTaskDataJson(score.taskDataJson);
      return ScoreWithDetails(score: score, tasks: tasks);
    }).toList();
  }

  // ---------------------------------------------------------
  // 3. 更新処理 (後で評価用)
  // ---------------------------------------------------------
  // スコアとタスクを一括更新する
  Future<void> updateScoreWithTasks(
    ScoresTableCompanion score,
    List<TaskScoreData> tasks,
  ) {
    // ★変更: JSONで更新
    if (score.id.present) {
      return (update(scoresTable)..where((t) => t.id.equals(score.id.value)))
          .write(score.copyWith(taskDataJson: Value(_toTaskDataJson(tasks))));
    }
    throw Exception('Score ID is required for update');
  }

  // ---------------------------------------------------------
  // 後で評価（ドラフト）機能用メソッド
  // ---------------------------------------------------------

  // 1. 「後で評価」として保存 (isDraft = true)
  Future<void> addScoreDraft(
    SessionData sessionData,
    List<TaskData> tasks, // アプリ内のTaskモデル
  ) {
    // TaskDataからTaskScoreDataに変換
    final taskScoreDataList = tasks
        .map(
          (task) => TaskScoreData(
            originalTaskId: task.id,
            taskName: task.task,
            importance: task.importance,
            difficulty: task.difficulty,
            achievePercent: task.isCompleted ? -1 : 0, // 完了タスクと未完のものとの区別
            wasCompletedBefore: task.isCompleted,
          ),
        )
        .toList();

    return into(scoresTable).insert(
      ScoresTableCompanion.insert(
        goalId: sessionData.goal != null
            ? Value(sessionData.goal!.goal.id)
            : const Value.absent(),
        goalName: sessionData.goal != null
            ? Value(sessionData.goal!.goal.goal)
            : const Value.absent(),
        startedAt: sessionData.startedAt,
        endedAt: sessionData.endedAt,
        totalMinutes: sessionData.focusMinutes, // ★修正: 集中時間（focusMinutes）を保存
        evaluationMode: 0,
        totalScore: 0.0, // ドラフト時はスコア未計算なので0
        concentrationLevel: 0,
        isDraft: const Value(true), // ★ドラフトフラグ ON
        taskDataJson: Value(_toTaskDataJson(taskScoreDataList)),
        goodPoints:  Value(sessionData.goodPoints),
        improvementPoints: Value(sessionData.improvementPoints),
        futurePlans: Value(sessionData.futurePlans),
      ),
    );
  }

  // 2. 未評価（ドラフト）リストの監視
  Stream<List<ScoreWithDetails>> watchDraftScores() {
    return (select(scoresTable)
          ..where((t) => t.isDraft.equals(true))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) {
          return rows.map((score) {
            final tasks = _parseTaskDataJson(score.taskDataJson);
            return ScoreWithDetails(score: score, tasks: tasks);
          }).toList();
        });
  }

  // 3. 個別のタスク状態を更新 (後で評価画面でのチェックボックス操作用)
  // ★変更: スコアIDとタスクインデックスで更新
  /*
  Future<void> updateTaskStatusInDb(int scoreId, int taskIndex, int achievePercent) async {
    final scoreRecord = await (select(scoresTable)..where((t) => t.id.equals(scoreId))).getSingleOrNull();
    if (scoreRecord == null) return;

    final tasks = _parseTaskDataJson(scoreRecord.taskDataJson);
    if (taskIndex < 0 || taskIndex >= tasks.length) return;

    // 該当タスクの達成度を更新
    final updatedTasks = List<TaskScoreData>.from(tasks);
    updatedTasks[taskIndex] = updatedTasks[taskIndex].copyWith(achievePercent: achievePercent);

    // JSONを更新
    await (update(scoresTable)..where((t) => t.id.equals(scoreId))).write(
      ScoresTableCompanion(
        taskDataJson: Value(_toTaskDataJson(updatedTasks)),
      ),
    );
  }

   */
  // 4. 評価完了（ドラフト解除）
  Future<void> finalizeDraftScore({
    required int scoreId,
    required int concentration,
    required double totalScore,
    required int evaluationMode,
    required int focusMinutes, // ★追加: 集中時間を明示的に受け取る
    List<TaskScoreData>? updatedTasks, // ★追加: タスクデータも更新可能に
    String? goodPoints, // ★追加: 良かった点
    String? improvementPoints, // ★追加: 改善点
    String? futurePlans, // ★追加: 今後の方針
  }) async {
    final updateCompanion = ScoresTableCompanion(
      concentrationLevel: Value(concentration),
      totalScore: Value(totalScore),
      totalMinutes: Value(focusMinutes), // ★修正: 集中時間を更新
      isDraft: const Value(false), // ★ドラフトフラグ OFF
      evaluationMode: Value(evaluationMode),
      goodPoints: goodPoints != null ? Value(goodPoints) : const Value.absent(),
      improvementPoints: improvementPoints != null
          ? Value(improvementPoints)
          : const Value.absent(),
      futurePlans: futurePlans != null
          ? Value(futurePlans)
          : const Value.absent(),
    );

    // タスクデータも更新する場合
    if (updatedTasks != null) {
      await (update(scoresTable)..where((t) => t.id.equals(scoreId))).write(
        updateCompanion.copyWith(
          taskDataJson: Value(_toTaskDataJson(updatedTasks)),
        ),
      );
    } else {
      await (update(
        scoresTable,
      )..where((t) => t.id.equals(scoreId))).write(updateCompanion);
    }
  }

  // 設定外タスクとして評価完了
  Future<void> finalizeDraftAsOther({
    required int scoreId,
    required int concentration,
    required double totalScore,
    required int focusMinutes, // ★追加: 集中時間を明示的に受け取る
    required String newGoalName,
    String? goodPoints, // ★追加: 良かった点
    String? improvementPoints, // ★追加: 改善点
    String? futurePlans, // ★追加: 今後の方針
  }) {
    return (update(scoresTable)..where((t) => t.id.equals(scoreId))).write(
      ScoresTableCompanion(
        concentrationLevel: Value(concentration),
        totalScore: Value(totalScore),
        totalMinutes: Value(focusMinutes), // ★修正: 集中時間を更新
        evaluationMode: const Value(0), // まとめて評価扱い
        isDraft: const Value(false), // ドラフト解除
        goalName: Value(newGoalName), // 名前を「設定外...」に変更
        goalId: const Value(null), // 元の目標IDとの紐付けを解除
        taskDataJson: const Value('[]'), // タスクなし
        goodPoints: goodPoints != null ? Value(goodPoints) : const Value.absent(),
        improvementPoints: improvementPoints != null
            ? Value(improvementPoints)
            : const Value.absent(),
        futurePlans: futurePlans != null
            ? Value(futurePlans)
            : const Value.absent(),
      ),
    );
  }

  // ---------------------------------------------------------
  // 4. 統計処理 (期間指定)
  // ---------------------------------------------------------
  // 指定期間の統計情報をまとめて取得する関数
  Future<ScoreStatistics> getStatsByRange(DateTime start, DateTime end) async {
    final scores = await (select(
      scoresTable,
    )..where((t) => t.startedAt.isBetweenValues(start, end))).get();

    if (scores.isEmpty) return const ScoreStatistics();

    final totalSessions = scores.length;
    final totalScoreSum = scores.fold<double>(
      0.0,
      (sum, s) => sum + s.totalScore,
    );
    final totalMinutesSum = scores.fold<int>(
      0,
      (sum, s) => sum + s.totalMinutes,
    );
    final totalConcentrationSum = scores.fold<int>(
      0,
      (sum, s) => sum + s.concentrationLevel,
    );

    return ScoreStatistics(
      totalSessions: totalSessions,
      totalScore: totalScoreSum,
      averageScore: totalScoreSum / totalSessions,
      totalMinutes: totalMinutesSum,
      averageMinutes: totalMinutesSum / totalSessions,
      averageConcentration: totalConcentrationSum / totalSessions,
    );
  }

  // ---------------------------------------------------------
  // 6. リアルタイム監視用 (Stream)
  // ---------------------------------------------------------

  // 指定期間のスコアとタスクを監視する (データ変更時に自動通知)
  Stream<List<ScoreWithDetails>> watchScoresByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(scoresTable)
          ..where((t) => t.startedAt.isBetweenValues(start, end))
          ..where((t) => t.isDraft.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((scoreRecords) {
          return scoreRecords.map((score) {
            final tasks = _parseTaskDataJson(score.taskDataJson);
            return ScoreWithDetails(score: score, tasks: tasks);
          }).toList();
        });
  }

  Stream<ScoreStatistics> watchStatsByRange(DateTime start, DateTime end) {
    return (select(scoresTable)
          ..where((t) => t.startedAt.isBetweenValues(start, end))
          ..where((t) => t.isDraft.equals(false)))
        .watch()
        .map((scores) {
          if (scores.isEmpty) return const ScoreStatistics();

          final totalSessions = scores.length;
          final totalScoreSum = scores.fold<double>(
            0.0,
            (sum, s) => sum + s.totalScore,
          );
          final totalMinutesSum = scores.fold<int>(
            0,
            (sum, s) => sum + s.totalMinutes,
          );
          final totalConcentrationSum = scores.fold<int>(
            0,
            (sum, s) => sum + s.concentrationLevel,
          );

          return ScoreStatistics(
            totalSessions: totalSessions,
            totalScore: totalScoreSum,
            averageScore: totalScoreSum / totalSessions,
            totalMinutes: totalMinutesSum,
            averageMinutes: totalMinutesSum / totalSessions,
            averageConcentration: totalConcentrationSum / totalSessions,
          );
        });
  }

  // 振り返りがある記録を取得する（全期間、ドラフト解除済みのみ）
  Stream<List<ScoreWithDetails>> watchReflections() {
    return (select(scoresTable)
          ..where((t) => t.isDraft.equals(false))
          ..where(
            (t) =>
                t.goodPoints.isNotNull() |
                t.improvementPoints.isNotNull() |
                t.futurePlans.isNotNull(),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((scoreRecords) {
          return scoreRecords
              .map((score) {
                final tasks = _parseTaskDataJson(score.taskDataJson);
                return ScoreWithDetails(score: score, tasks: tasks);
              })
              .where((scoreWithDetails) {
                // 空文字列を除外（データベースレベルではNULLチェックのみなので、空文字列も除外）
                final s = scoreWithDetails.score;
                final hasGoodPoints =
                    s.goodPoints != null && s.goodPoints!.isNotEmpty;
                final hasImprovementPoints =
                    s.improvementPoints != null &&
                    s.improvementPoints!.isNotEmpty;
                final hasFuturePlans =
                    s.futurePlans != null && s.futurePlans!.isNotEmpty;

                // デバッグ用ログ
                /*if (hasGoodPoints || hasImprovementPoints || hasFuturePlans) {
                  debugPrint(
                    '振り返り記録: ID=${s.id}, 日時=${s.startedAt}, goodPoints=${hasGoodPoints}, improvementPoints=${hasImprovementPoints}, futurePlans=${hasFuturePlans}',
                  );
                }
                 */

                return hasGoodPoints || hasImprovementPoints || hasFuturePlans;
              })
              .toList();
        });
  }

  // ---------------------------------------------------------
  // 5. 削除処理
  // ---------------------------------------------------------
  Future<void> deleteScore(int id) async {
    // ★変更: TaskScoresTableの削除は不要（JSONは自動削除）
    await (delete(scoresTable)..where((t) => t.id.equals(id))).go();
  }

  // score_dao.dart に追加
  Future<void> clearReflectionOnly(int id) {
    return (update(scoresTable)..where((t) => t.id.equals(id))).write(
      const ScoresTableCompanion(
        goodPoints: Value(null),
        improvementPoints: Value(null),
        futurePlans: Value(null),
      ),
    );
  }
}

// ※ Daoからの戻り値用の一時クラス（DTO）
class ScoreWithDetails {
  final ScoresTableData score;
  final List<TaskScoreData> tasks; // ★変更: TaskScoresTableDataからTaskScoreDataに

  const ScoreWithDetails({required this.score, required this.tasks});

  @override
  String toString() {
    return 'ScoreWithDetails(score: ${score.id}, tasks: ${tasks.length})';
  }
}

// --- Daoファイルの下部などに統計結果用のクラスを定義 ---

class ScoreStatistics {
  final int totalSessions;
  final double totalScore;
  final double averageScore;
  final int totalMinutes;
  final double averageMinutes;
  final double averageConcentration;

  const ScoreStatistics({
    this.totalSessions = 0,
    this.totalScore = 0,
    this.averageScore = 0,
    this.totalMinutes = 0,
    this.averageMinutes = 0,
    this.averageConcentration = 0,
  });
}
