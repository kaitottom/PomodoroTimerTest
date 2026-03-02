import 'package:drift/drift.dart';
import '../../../models/goal_with_tasks.dart';
import '../app_database.dart';
import '../tables/goal_settings_table.dart';
import '../tables/task_table.dart';
import 'dart:async';

part 'goal_dao.g.dart';

// ▼▼▼ 自分が操作する可能性のある全てのテーブルをdriftに教える ▼▼▼
@DriftAccessor(tables: [GoalSettingsTable, TasksTable])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(AppDatabase db) : super(db);

  // --- 純粋なGoalの処理 ---
  Stream<List<GoalSettingData>> watchGoals() => select(goalSettingsTable).watch();

  Stream<List<GoalWithTasks>> watchGoalsWithTasks() {
    // 1. まず、全てのGoalのStreamを取得する (これは既に高速)
    final goalsStream = watchGoals();

    // 2. goalのリストが更新されるたびに、
    //    各goalに対応するタスクリストを取得し、合成する
    return goalsStream.asyncMap((goals) async {
      // 結果を格納するためのリスト
      final goalsWithTasksList = <GoalWithTasks>[];

      // 3. 取得した各Goalに対してループ処理
      for (final goal in goals) {
        // 4. 対応するタスクリストを "1回だけ" DBから取得する (非同期)
        final tasks = await (select(tasksTable)..where((t) => t.goalId.equals(goal.id))).get();

        // 5. GoalとTaskを`GoalWithTasks`にまとめてリストに追加
        goalsWithTasksList.add(GoalWithTasks(goal: goal, tasks: tasks));
      }

      // 6. 全ての合成が完了したリストをStreamに流す
      return goalsWithTasksList;
    });
  }

  Future<GoalSettingData?> findGoalById(int id) {
    return (select(goalSettingsTable)..where((g) => g.id.equals(id))).getSingleOrNull();
  }

  Future<List<GoalSettingData>> fetchAllGoalsOnce() =>
      select(goalSettingsTable).get();

  // ---- 新規作成 ----
  Future<int> insertGoal(GoalSettingsTableCompanion goal) {
    return into(goalSettingsTable).insert(goal);
  }

  // ---- 更新 ----
  Future<int> updateGoal(int id, GoalSettingsTableCompanion companion) {
    return (update(goalSettingsTable)..where((g) => g.id.equals(id)))
        .write(companion);
  }

  /*
  Future<void> updateGoalWithTasks(
      int goalId,
      GoalSettingsTableCompanion goalCompanion,
      List<TasksTableCompanion> tasks,
      ) {
    return transaction(() async {
      // 1) Goal を更新（replace 相当）
      // update(...).write() で部分更新もできるが、ここでは完全置換に近い形で
      await (update(goalSettingsTable)..where((g) => g.id.equals(goalId)))
          .write(goalCompanion);

      // 2) その goalId に紐づく Task を全削除
      await (delete(tasksTable)..where((t) => t.goalId.equals(goalId))).go();

      // 3) 新しい Task を挿入（goalId を付与）
      if (tasks.isNotEmpty) {
        final tasksWithGoalId = tasks
            .map((t) => t.copyWith(goalId: Value(goalId)))
            .toList();
        await batch((batch) {
          batch.insertAll(tasksTable, tasksWithGoalId);
        });

        // 4) aiGeneratedTasks フラグを更新（少なくとも 1 件 isAiGenerated が true なら true 表示）
        final hasAi = tasksWithGoalId.any((t) {
          // Companion の場合 `.isAiGenerated` は Value<bool?> 型なので .value を参照
          final val = t.isAiGenerated;
          return val.present && val.value == true;
        });

        if (hasAi) {
          await (update(goalSettingsTable)..where((g) => g.id.equals(goalId))).write(
            GoalSettingsTableCompanion(aiGeneratedTasks: Value('true')),
          );
        } else {
          // 逆にAIフラグをクリアしたければ null にする処理（必要なら有効化）
          await (update(goalSettingsTable)..where((g) => g.id.equals(goalId))).write(
            GoalSettingsTableCompanion(aiGeneratedTasks: const Value(null)),
          );
        }
      } else {
        // tasks が空の場合は aiGeneratedTasks をクリア
        await (update(goalSettingsTable)..where((g) => g.id.equals(goalId))).write(
          GoalSettingsTableCompanion(aiGeneratedTasks: const Value(null)),
        );
      }
    });
  }*/
  Future<void> updateGoalWithTasks(
      int goalId,
      GoalSettingsTableCompanion goalCompanion,
      List<TasksTableCompanion> newTasks,
      ) {
    return transaction(() async {
      // ---- 1. 既存タスクのAI生成フラグを読み込む ----
      final oldTasks = await (select(tasksTable)
        ..where((t) => t.goalId.equals(goalId)))
          .get();

      final oldAiMap = <int, bool>{};
      for (final t in oldTasks) {
        oldAiMap[t.id] = (t.isAiGenerated == 'true');///
            }

      // ---- 2. Goal本体を更新 ----
      await (update(goalSettingsTable)..where((g) => g.id.equals(goalId)))
          .write(goalCompanion);

      // ---- 3. タスクを総入れ替え（削除→挿入） ----
      await (delete(tasksTable)..where((t) => t.goalId.equals(goalId))).go();

      final tasksWithGoalId = newTasks.map((t) {
        bool aiFlag = false;

        // (A) 既存タスクだったら isAiGenerated を継承
        if (t.id.present && oldAiMap.containsKey(t.id.value)) {
          aiFlag = oldAiMap[t.id.value] ?? false;
        }
        // (B) 新規タスク → t.isAiGenerated.present を優先（UI から渡されたもの）
        else if (t.isAiGenerated.present && (t.isAiGenerated.value == 'true')) {
          aiFlag = true;
        }

        return t.copyWith(
          goalId: Value(goalId),
          isAiGenerated: Value(aiFlag ? true : false),
        );
      }).toList();

      await batch((batch) {
        batch.insertAll(tasksTable, tasksWithGoalId);
      });

      // ---- 4. Goal の aiGeneratedTasks フラグを更新 ----
      final hasAiTask = tasksWithGoalId.any(
            (t) => t.isAiGenerated.present && t.isAiGenerated.value == 'true',
      );

      await (update(goalSettingsTable)..where((g) => g.id.equals(goalId))).write(
        GoalSettingsTableCompanion(
          aiGeneratedTasks: Value(hasAiTask ? 'true' : null),
        ),
      );
    });
  }


// 不要かも
  //Future<int> saveGoal(GoalSettingsTableCompanion goal) =>
  //    into(goalSettingsTable).insert(goal, mode: InsertMode.insertOrReplace);

  // --- Taskとの連携処理 ---
  Future<void> createGoalWithTasks(
      GoalSettingsTableCompanion goal,
      List<TasksTableCompanion> tasks,
      ) {
    return transaction(() async {
      final newGoalId = await into(goalSettingsTable).insert(goal);
      final tasksWithGoalId =
      tasks.map((t) => t.copyWith(goalId: Value(newGoalId))).toList();
      await batch((batch) {
        batch.insertAll(tasksTable, tasksWithGoalId);
      });

      final hasAi = tasksWithGoalId.any((t) => t.isAiGenerated.value == true);
      if (hasAi) {
        await (update(goalSettingsTable)..where((g) => g.id.equals(newGoalId))).write(
          GoalSettingsTableCompanion(aiGeneratedTasks: Value('true')),
        );
      }
    });
  }

  Future<void> deleteGoalWithTasks(int goalId) {
    return transaction(() async {
      await (delete(tasksTable)..where((t) => t.goalId.equals(goalId))).go();
      await (delete(goalSettingsTable)..where((g) => g.id.equals(goalId))).go();
    });
  }

  Future<void> completeGoalAndTasks(int goalId) {
    return transaction(() async {
      // 1. Goal を完了状態に更新
      await (update(goalSettingsTable)..where((g) => g.id.equals(goalId))).write(
        GoalSettingsTableCompanion(
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );
      // 2. 紐づくタスクをすべて完了に（より効率的な一括更新）
      await (update(tasksTable)..where((t) => t.goalId.equals(goalId))).write(
        const TasksTableCompanion(isCompleted: Value(true)),
      );
    });
  }

  // 今日完了した目標
  Stream<List<GoalSettingData>> watchGoalsCompletedToday() {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    return (select(goalSettingsTable)
      ..where((g) => g.isCompleted.equals(true) & g.completedAt.isBetweenValues(todayStart, todayEnd)))
        .watch();
  }

// 週間完了目標
  Stream<List<GoalSettingData>> watchGoalsCompletedThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // 月曜始まり
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return (select(goalSettingsTable)
      ..where((g) => g.isCompleted.equals(true) & g.completedAt.isBetweenValues(startOfWeek, endOfWeek)))
        .watch();
  }

// 完了済み Goal + Task をまとめて返す
  Stream<List<GoalWithTasks>> watchCompletedGoalsWithTasks() {
    final goalsStream = (select(goalSettingsTable)
      ..where((g) => g.isCompleted.equals(true))).watch(); // 既存の完了目標

    return goalsStream.asyncMap((goals) async {
      // 全タスクを一括取得（必要十分）
      final allTasks = await select(tasksTable).get();

      return goals.map((g) {
        final relatedTasks =
        allTasks.where((t) => t.goalId == g.id).toList();

        return GoalWithTasks(goal: g, tasks: relatedTasks);
      }).toList();
    });
  }


  Future<void> clearAllData() {
      return transaction(() async {
        await delete(tasksTable).go();
        await delete(goalSettingsTable).go();
      });
    }

    }
