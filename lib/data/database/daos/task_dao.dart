import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/task_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [TasksTable])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);

  // --- 純粋なTaskの処理 ---
  Stream<List<TaskData>> watchTasksForGoal(int goalId) =>
      (select(tasksTable)..where((t) => t.goalId.equals(goalId))).watch();

  // ---- One-time fetch ----
  Future<List<TaskData>> findTasksByGoalIdOnce(int goalId) {
    return (select(tasksTable)..where((t) => t.goalId.equals(goalId))).get();
  }

  Future<TaskData?> findTaskById(int id) {
    return (select(tasksTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // ---- Insert ----
  Future<int> insertTask(TasksTableCompanion task) {
    return into(tasksTable).insert(task);
  }

  // ---- Update ----
  // UIから送られてきたCompanionを使い、特定のタスクを更新します。
  Future<int> updateTask(int taskId, TasksTableCompanion companion) {
    return (update(tasksTable)..where((t) => t.id.equals(taskId))).write(companion);
  }
  // 不要かも?
  Future<void> saveTasks(List<TasksTableCompanion> tasks) {
    return batch((batch) => batch.insertAll(tasksTable, tasks, mode: InsertMode.insertOrReplace));
  }

  Future<int> deleteTasksByGoalId(int goalId) {
    return (delete(tasksTable)..where((t) => t.goalId.equals(goalId))).go();
  }

  // IDを指定して特定のタスクを安全に削除します。
  Future<int> deleteTask(int taskId) {
    return (delete(tasksTable)..where((t) => t.id.equals(taskId))).go();
  }

  Future<void> changeCompleteTask(TaskData task) {
    return update(tasksTable).replace(
      task.copyWith(isCompleted: !task.isCompleted),
    );
  }



}
