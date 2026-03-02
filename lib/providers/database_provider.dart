import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import '../data/database/daos/goal_dao.dart';
import '../data/database/daos/task_dao.dart';
import '../data/database/daos/score_dao.dart';
import '../models/goal_with_tasks.dart';

// --- データベース本体とDAOのProvider ---

// 1. 司令塔（AppDatabase）のProvider
// アプリ内でただ一つ存在すれば良いので、通常のProviderで定義します。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// 2. 目標担当（GoalDao）データベースのProvider
// AppDatabaseに依存しているので、appDatabaseProviderをwatchして生成します。
final goalDaoProvider = Provider<GoalDao>((ref) {
  // .g.dartファイルが自動的に `goalDao` というgetterを生成してくれます。
  return ref.watch(appDatabaseProvider).goalDao;
});

// 3. タスク担当（TaskDao）データベースのProvider
// こちらも同様です。
final taskDaoProvider = Provider<TaskDao>((ref) {
  return ref.watch(appDatabaseProvider).taskDao;
});


final scoreDaoProvider = Provider<ScoreDao>((ref) => ref.watch(appDatabaseProvider).scoreDao);



// --- UIで使うためのデータを提供するStreamProvider ---

// 4. 全ての目標リストを監視するStreamProvider
// UIは、この`goalsProvider`を監視（watch）すれば、目標の変更が自動で反映されます。
final goalsProvider = StreamProvider<List<GoalSettingData>>((ref) {
  return ref.watch(goalDaoProvider).watchGoals();
});

// 5. 特定の目標に紐づくタスクリストを監視する表示用 StreamProvider
// `family`を使うことで、`goalId`を引数として渡せるようになります。
final tasksForGoalProvider = StreamProvider.family<List<TaskData>, int>((ref, goalId) {
  return ref.watch(taskDaoProvider).watchTasksForGoal(goalId);
});

// 今日完了した目標
final todayCompletedGoalsProvider =
StreamProvider<List<GoalSettingData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.goalDao.watchGoalsCompletedToday();
});

// 今週完了した目標
final weeklyCompletedGoalsProvider =
StreamProvider<List<GoalSettingData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.goalDao.watchGoalsCompletedThisWeek();
});

// すべての完了目標
final completedGoalsWithTasksProvider =
StreamProvider<List<GoalWithTasks>>((ref) {
  final dao = ref.watch(goalDaoProvider);
  return dao.watchCompletedGoalsWithTasks();
});

final allGoalsWithTasksProvider = StreamProvider<List<GoalWithTasks>>((ref) {
  return ref.watch(goalDaoProvider).watchGoalsWithTasks();
});



