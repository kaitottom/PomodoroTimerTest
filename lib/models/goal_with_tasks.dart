// GoalSettingData と TaskDataをまとめて使うため。

import '../data/database/app_database.dart';

class GoalWithTasks {
  final GoalSettingData goal;
  final List<TaskData> tasks;

  GoalWithTasks({required this.goal, required this.tasks});

  // TaskData のコピー付き更新用
  GoalWithTasks copyWith({GoalSettingData? goal, List<TaskData>? tasks}) {
    return GoalWithTasks(
      goal: goal ?? this.goal,
      tasks: tasks ?? this.tasks,
    );
  }
}
