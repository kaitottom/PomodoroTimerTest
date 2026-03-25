// データの管理のみで データベースには書かない
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../data/database/app_database.dart';
import '../models/goal_with_tasks.dart';
import 'database_provider.dart'; // GoalSettingData, TaskData のため

// 1. メモリ上で管理する状態の定義
// GoalとTaskのペアを保持するシンプルなクラス
class TempGoalHolder {
  final GoalSettingData goal;
  final List<TaskData> tasks;

  TempGoalHolder({required this.goal, required this.tasks});

  // 状態のコピーを簡単にするためのcopyWithメソッド
  TempGoalHolder copyWith({
    GoalSettingData? goal,
    List<TaskData>? tasks,
  }) {
    return TempGoalHolder(
      goal: goal ?? this.goal,
      tasks: tasks ?? this.tasks,
    );
  }
}


// 2. StateNotifier の実装
class TempGoalNotifier extends StateNotifier<TempGoalHolder?> {
  TempGoalNotifier() : super(null);

  // 編集開始時に、外部から初期状態を設定する
  void setInitialState(GoalSettingData goal, List<TaskData> tasks) {
    state = TempGoalHolder(goal: goal, tasks: tasks);
  }


  // ★これを追加：タスクリストだけをセットする
  void setTasks(List<TaskData> newTasks) {
    if (state == null) return; // Goalがなければ何もしない
    state = state!.copyWith(tasks: newTasks);
  }

  // タスクを追加する
  void addTask(TaskData task) {
    if (state == null) return;
    state = state!.copyWith(tasks: [...state!.tasks, task]);
  }

  // AI生成タスクをまとめて追加
  void addAiGeneratedTasks(List<TaskData> tasks) {
    if (state == null) return;
    state = state!.copyWith(tasks: [...state!.tasks, ...tasks]);
  }

  // フォームなどからGoalの情報だけ更新する
  void updateGoalFields(GoalSettingsTableCompanion companion) {
    if (state == null) return; // 状態がなければ何もしない
    // 既存のgoal情報を、companionの内容で部分的に更新する
    final updatedGoal = state!.goal.copyWithCompanion(companion);
    // タスクリストはそのままに、goal情報だけを差し替える
    state = state!.copyWith(goal: updatedGoal);
  }


  // タスクを更新する
  void updateTask(TaskData updatedTask) {
    if (state == null) return;
    state = state!.copyWith(
      tasks: state!.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList(),
    );
  }

  // タスクを削除する (IDで比較するのが安全)
  void deleteTask(int taskId) {
    if (state == null) return;
    state = state!.copyWith(tasks: state!.tasks.where((t) => t.id != taskId).toList());
  }

  // 編集状態をリセットする
  void reset() {
    state = null;
  }


  void updateGoal(GoalSettingData newGoal) {
    if (state != null) {
      state = state!.copyWith(goal: newGoal);
    }
  }

  void updateTasks(List<TaskData> newTasks) {
    if (state != null) {
      state = state!.copyWith(tasks: newTasks);
    }
  }


}

// 3. StateNotifierProvider の定義
final tempGoalProvider = StateNotifierProvider<TempGoalNotifier, TempGoalHolder?>((ref) {
  return TempGoalNotifier();
});

// データベースより現在設定中の目標を取り出す
final currentGoalProvider = StreamProvider<GoalWithTasks?>((ref) {
  final goalDao = ref.watch(goalDaoProvider);
  final taskDao = ref.watch(taskDaoProvider);

  // Goal の Stream を監視
  return goalDao.watchGoals().asyncMap((goals) async {
    // 未完了の目標だけに絞る
    final incompleteGoals = goals.where((g) => g.isCompleted == false).toList();
    if (incompleteGoals.isEmpty) return null;

    // 最新の未完了Goalを取得（作成日時順などで選ぶ）
    final goal = incompleteGoals.last;

    // Goalに紐づくTaskを取得（非同期）
    final tasks = await taskDao.findTasksByGoalIdOnce(goal.id);

    return GoalWithTasks(goal: goal, tasks: tasks);
  });
});

//　AIの最終使用日時
final lastAiUsageProvider = StateProvider<DateTime?>((ref) => null);

// AIが利用可能かどうかを判定するProvider
final canUseAiProvider = Provider<bool>((ref) {
  final lastUsage = ref.watch(lastAiUsageProvider);
  if (lastUsage == null) return true;

  final now = DateTime.now();
  // 月または年が異なれば利用可能（月1回制限）
  return now.month != lastUsage.month || now.year != lastUsage.year;
});

//----------------------------------------------------------------------------


/*

// 現在の目標を管理するプロバイダー
final currentGoalProvider = StreamProvider<GoalSettings?>((ref) {
  final db = ref.watch(databaseProvider);

  final goalStream = (db.select(db.goalSettingsTable)
    ..where((tbl) => tbl.isCompleted.equals(false))
    ..orderBy([(tbl) => OrderingTerm(expression: tbl.limit, mode: OrderingMode.desc)])
    ..limit(1))
      .watchSingleOrNull();

  return goalStream.asyncMap((goalRow) async {
    if (goalRow == null) return null;

    //final tasks = await db.watchTasksForGoal(goalRow.id).first;
    // ← ★ tasks をストリームで監視する
    final tasksStream = db.watchTasksForGoal(goalRow.id);
    final taskRows = await tasksStream.first;

    return goalRow.toModel(
      taskRows.map((t) => t.toModel()).toList(),
    );
  });
});


// データベースの変更を監視し、自動で最新の目標リストを提供するStreamProvider
final goalListProvider = StreamProvider<List<GoalSettings>>((ref) {
  // データベースインスタンスを取得
  final db = ref.watch(databaseProvider);

  return db.watchGoals().asyncMap((goalRows) async {
    // 各目標に紐づく Task をロードしてモデルに変換
    final result = <GoalSettings>[];

    for (final goal in goalRows) {
      final taskRows = await db.watchTasksForGoal(goal.id).first;
      final tasks = taskRows.map((t) => t.toModel()).toList();
      result.add(goal.toModel(tasks));
    }

    return result;
  });
});


// 目標作成・編集フロー中の一時保存用プロバイダー
final tempGoalProvider = StateNotifierProvider<TempGoalNotifier, GoalSettings?>(
  (ref) {
    return TempGoalNotifier();
  },
);

// 完了済み目標の履歴を管理するプロバイダー
final completedGoalsProvider = Provider<List<GoalSettings>>((ref) {
  final allGoalsAsync = ref.watch(goalListProvider);
  final allGoals = allGoalsAsync.value ?? [];

  return allGoals
      .where((g) => g.isCompleted && g.completedAt != null)
      .toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
});

final todayCompletedGoalsProvider = Provider<List<GoalSettings>>((ref) {
  final allGoalsAsync = ref.watch(goalListProvider);
  final allGoals = allGoalsAsync.value ?? [];
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return allGoals.where((g) =>
  g.isCompleted &&
      g.completedAt != null &&
      g.completedAt!.isAfter(startOfDay) &&
      g.completedAt!.isBefore(endOfDay)
  ).toList();
});

final weeklyCompletedGoalsProvider = Provider<List<GoalSettings>>((ref) {
  final allGoalsAsync = ref.watch(goalListProvider);
  final allGoals = allGoalsAsync.value ?? [];
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // 月曜始まり
  return allGoals.where((g) =>
  g.isCompleted &&
      g.completedAt != null &&
      g.completedAt!.isAfter(startOfWeek)
  ).toList();
});



// 現在の目標と完了済み目標の両方を監視するコンバインドプロバイダー
final goalSummaryProvider = Provider<GoalSummary>((ref) {
  final currentGoalAsync = ref.watch(currentGoalProvider);
  final completedGoals = ref.watch(completedGoalsProvider);

  final currentGoal = currentGoalAsync.value; // AsyncValue → GoalSetting?

  return GoalSummary(
    currentGoal: currentGoal,
    completedGoals: completedGoals,
    totalCompleted: completedGoals.length,
    hasCurrentGoal: currentGoal != null,
  );
});

// 目標サマリー情報
class GoalSummary {
  final GoalSettings? currentGoal;
  final List<GoalSettings> completedGoals;
  final int totalCompleted;
  final bool hasCurrentGoal;

  GoalSummary({
    required this.currentGoal,
    required this.completedGoals,
    required this.totalCompleted,
    required this.hasCurrentGoal,
  });
}

// 現在の目標を管理するノーティファイア
class CurrentGoalNotifier extends StateNotifier<GoalSettings?> {
  CurrentGoalNotifier() : super(null);

  int get nextId {
    // 完了済み目標から最大IDを取得して+1
    // 現在の目標がある場合はそれも考慮
    int maxId = 0;
    if (state != null) {
      maxId = state!.id;
    }
    return maxId + 1;
  }


  /// 既存の goal を「そのまま currentGoal にセット」する（編集時の使用）
  /// createdAt は更新するが id は上書きしない。
  void setGoal(GoalSettings goal) {
    // goal.id が 0 (未設定) の場合は新規として id を振る
    if (goal.id != 0) {
      state = goal; // そのままセット（createdAt も保持）
    } else {
      state = goal.copyWith(id: nextId, createdAt: DateTime.now());
    }
  }

  /// 新規に currentGoal を作る（explicit な新規作成を呼びたい場合に使う）
  void createNewGoal(GoalSettings goal) {
    state = goal.copyWith(id: nextId, createdAt: DateTime.now());
  }
  // 新しい目標を設定
  //void setGoal(GoalSettings goal) {
  //  state = goal.copyWith(id: nextId, createdAt: DateTime.now());
  //}

  // 目標を更新
  void updateGoal(GoalSettings updated) {
    if (state != null && state!.id == updated.id) {
      state = updated;
    }
  }

  // 目標名を更新
  void updateGoalName(String goal) {
    if (state != null) {
      state = state!.copyWith(goal: goal);
    }
  }

  // 重要度を更新
  void updateImportance(int importance) {
    if (state != null) {
      state = state!.copyWith(importance: importance);
    }
  }

  // 影響度を更新
  void updateImpact(int impact) {
    if (state != null) {
      state = state!.copyWith(impact: impact);
    }
  }

  // 目標達成期限を更新
  void updateLimit(DateTime limit) {
    if (state != null) {
      state = state!.copyWith(limit: limit);
    }
  }

  // タスクを更新
  void updateTasks(List<Task> tasks) {
    if (state != null) {
      state = state!.copyWith(tasks: tasks);
    }
  }

  // タスクを追加
  void addTask(Task task) {
    if (state != null) {
      state = state!.copyWith(tasks: [...state!.tasks, task]);
    }
  }

  // AI生成タスクを一括追加
  void addAiGeneratedTasks(List<Task> aiTasks) {
    if (state != null) {
      final tasksWithAiFlag = aiTasks
          .map((task) => task.copyWith(isAiGenerated: true))
          .toList();
      state = state!.copyWith(
        tasks: [...state!.tasks, ...tasksWithAiFlag],
        aiGeneratedTasks: 'AI生成タスク: ${aiTasks.length}個',
      );
    }
  }

  // タスクを削除
  void deleteTask(String taskName) {
    if (state != null) {
      state = state!.copyWith(
        tasks: state!.tasks.where((t) => t.task != taskName).toList(),
      );
    }
  }

  // タスクを更新
  void updateTask(Task updatedTask) {
    if (state != null) {
      state = state!.copyWith(
        tasks: state!.tasks
            .map((t) => t.task == updatedTask.task ? updatedTask : t)
            .toList(),
      );
    }
  }

  // タスクを完了
  void completeTask(String taskName) {
    if (state != null) {
      state = state!.copyWith(
        tasks: state!.tasks
            .map((t) => t.task == taskName ? t.copyWith(isCompleted: true) : t)
            .toList(),
      );
    }
  }

  // 目標を完了（履歴に移動）
  void completeGoal(CompletedGoalsNotifier completedGoalsNotifier) {
    if (state != null) {
      // 完了済み目標として履歴に追加（完了日時を付与）
      final completedGoal = state!.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      for (var task in completedGoal.tasks) {
        if (task.isCompleted != true){
          task = task.copyWith(isCompleted: true);
        }
      }
      completedGoalsNotifier.addCompletedGoal(completedGoal);
      state = null; // 現在の目標をクリア
    }
  }

  // 目標を削除
  void clearGoal() {
    state = null;
  }
}

// 目標作成・編集フロー中の一時保存用ノーティファイア
class TempGoalNotifier extends StateNotifier<GoalSettings?> {
  TempGoalNotifier() : super(null);

  void setTempGoal(GoalSettings goal) {
    state = goal;
  }

  void updateTempGoal(GoalSettings updated) {
    state = updated;
  }


  /// すべての一時データを初期化
  void reset() {
    state = null; // Goal も Task も丸ごと初期化
  }

  // タスク追加
  void addTask(Task task) {
    if (state != null) {
      state = state!.copyWith(tasks: [...state!.tasks, task]);
    }
  }

  // タスク更新
  void updateTask(Task updatedTask) {
    if (state != null) {
      state = state!.copyWith(
        tasks: state!.tasks
            .map((t) => t.task == updatedTask.task ? updatedTask : t)
            .toList(),
      );
    }
  }

  // タスク削除
  void deleteTask(String taskName) {
    if (state != null) {
      state = state!.copyWith(
        tasks: state!.tasks.where((t) => t.task != taskName).toList(),
      );
    }
  }

  // タスク完了
  void completeTask(String taskName) {
    if (state != null) {
      state = state!.copyWith(
        tasks: state!.tasks
            .map((t) => t.task == taskName ? t.copyWith(isCompleted: true) : t)
            .toList(),
      );
    }
  }

  // AI生成タスク一括追加
  void addAiGeneratedTasks(List<Task> aiTasks) {
    if (state != null) {
      final tasksWithAiFlag = aiTasks
          .map((task) => task.copyWith(isAiGenerated: true))
          .toList();
      state = state!.copyWith(tasks: [...state!.tasks, ...tasksWithAiFlag]);
    }
  }
}

// 完了済み目標の履歴を管理するノーティファイア
class CompletedGoalsNotifier extends StateNotifier<List<GoalSettings>> {
  CompletedGoalsNotifier() : super([]);

  // 完了済み目標を追加
  void addCompletedGoal(GoalSettings goal) {
    state = [goal, ...state]; // 新しい完了目標を先頭に追加
  }

  // 完了済み目標を削除
  void removeCompletedGoal(int goalId) {
    state = state.where((g) => g.id != goalId).toList();
  }

  // 完了済み目標を取得（日付順）
  List<GoalSettings> getGoalsByDate() {
    final sorted = List<GoalSettings>.from(state);
    sorted.sort((a, b) => b.limit.compareTo(a.limit)); // 新しい順
    return sorted;
  }

  // 完了済み目標を取得（重要度順）
  List<GoalSettings> getGoalsByImportance() {
    final sorted = List<GoalSettings>.from(state);
    sorted.sort((a, b) => b.importance.compareTo(a.importance));
    return sorted;
  }

  // 完了済み目標を取得（影響度順）
  List<GoalSettings> getGoalsByImpact() {
    final sorted = List<GoalSettings>.from(state);
    sorted.sort((a, b) => b.impact.compareTo(a.impact));
    return sorted;
  }
}

// 後方互換性のためのプロバイダー（既存のコードが動作するように）
final goalSettingsListProvider =
    StateNotifierProvider<GoalSettingsListNotifier, List<GoalSettings>>((ref) {
      return GoalSettingsListNotifier();
    });

class GoalSettingsListNotifier extends StateNotifier<List<GoalSettings>> {
  GoalSettingsListNotifier() : super([]);

  int get nextId => state.isEmpty
      ? 1
      : state.map((g) => g.id).reduce((a, b) => a > b ? a : b) + 1;

  void addGoal(GoalSettings goal) {
    state = [...state, goal.copyWith(id: nextId)];
  }

  void deleteGoal(int id) {
    state = state.where((g) => g.id != id).toList();
  }

  void updateGoal(GoalSettings updated) {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
  }

  void updateGoalName(int goalId, String goal) {
    // 目標名を更新する
    state = state
        .map((g) => g.id == goalId ? g.copyWith(goal: goal) : g)
        .toList();
  }

  void updateImportance(int goalId, int importance) {
    // 重要度を更新する
    state = state
        .map((g) => g.id == goalId ? g.copyWith(importance: importance) : g)
        .toList();
  }

  void updateImpact(int goalId, int impact) {
    // 影響度を更新する
    state = state
        .map((g) => g.id == goalId ? g.copyWith(impact: impact) : g)
        .toList();
  }

  void updateLimit(int goalId, DateTime limit) {
    // 目標達成期限を更新する
    state = state
        .map((g) => g.id == goalId ? g.copyWith(limit: limit) : g)
        .toList();
  }

  void updateTasks(int goalId, List<Task> tasks) {
    // タスクを更新する
    state = state
        .map((g) => g.id == goalId ? g.copyWith(tasks: tasks) : g)
        .toList();
  }

  void updateIsCompleted(int goalId, bool isCompleted) {
    // 目標達成時に、isCompletedをtrueにする
    state = state
        .map((g) => g.id == goalId ? g.copyWith(isCompleted: isCompleted) : g)
        .toList();
  }

  void completeGoal(int id) {
    // 目標達成時に、タスクのisCompletedをtrueにする
    state = state
        .map((g) => g.id == id ? g.copyWith(isCompleted: true) : g)
        .toList();
  }

  void addTask(int goalId, Task task) {
    // タスクを追加する
    state = state
        .map((g) => g.id == goalId ? g.copyWith(tasks: [...g.tasks, task]) : g)
        .toList();
  }

  void deleteTask(int goalId, String taskName) {
    // タスクを削除する
    state = state
        .map(
          (g) => g.id == goalId
              ? g.copyWith(
                  tasks: g.tasks.where((t) => t.task != taskName).toList(),
                )
              : g,
        )
        .toList();
  }

  void updateTask(int goalId, Task updatedTask) {
    // タスクを更新する
    state = state
        .map(
          (g) => g.id == goalId
              ? g.copyWith(
                  tasks: g.tasks
                      .map((t) => t.task == updatedTask.task ? updatedTask : t)
                      .toList(),
                )
              : g,
        )
        .toList();
  }

  void completeTask(int goalId, String taskName) {
    // タスクを達成時に、isCompletedをtrueにする
    state = state
        .map(
          (g) => g.id == goalId
              ? g.copyWith(
                  tasks: g.tasks
                      .map(
                        (t) => t.task == taskName
                            ? t.copyWith(isCompleted: true)
                            : t,
                      )
                      .toList(),
                )
              : g,
        )
        .toList();
  }
}

*/

