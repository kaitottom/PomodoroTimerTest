import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_settings.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, Task>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<Task> {
  TaskNotifier() : super(Task(task: '', limit: DateTime.now()));

  void updateTask(String task) {
    state = state.copyWith(task: task);
  }

  void updateDifficulty(int difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void updateImpact(int importance) {
    state = state.copyWith(importance: importance);
  }

  void updateLimit(DateTime limit) {
    state = state.copyWith(limit: limit);
  }

  void updateIsCompleted(bool isCompleted) {
    state = state.copyWith(isCompleted: isCompleted);
  }

  void deleteTask() {
    state = state.copyWith(
      task: '',
      importance: 3,
      difficulty: 3,
      limit: DateTime.now(),
    );
  }



}
