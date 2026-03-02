class GoalSettings {
  final int id;
  final String goal;
  final int importance; // 1~5の数値で重要度を表す  Sliderで表示
  final int impact; // 1~5の数値で影響度を表す  Sliderで表示
  final DateTime limit; // 目標達成期限
  final List<Task> tasks;
  final bool isCompleted;
  final DateTime? createdAt; // 作成日時（DifyAI連携用）
  final String? aiGeneratedTasks; // AI生成タスクの記録（DifyAI連携用）
  final DateTime? completedAt; // 完了日時（履歴表示用）

  const GoalSettings({
    required this.id,
    required this.goal,
    this.importance = 3,
    this.impact = 3,
    required this.limit,
    this.tasks = const [],
    this.isCompleted = false,
    this.createdAt,
    this.aiGeneratedTasks,
    this.completedAt,
  });

  GoalSettings copyWith({
    int? id,
    String? goal,
    int? importance,
    int? impact,
    DateTime? limit,
    List<Task>? tasks,
    bool? isCompleted,
    DateTime? createdAt,
    String? aiGeneratedTasks,
    DateTime? completedAt,
  }) {
    return GoalSettings(
      id: id ?? this.id,
      goal: goal ?? this.goal,
      importance: importance ?? this.importance,
      impact: impact ?? this.impact,
      limit: limit ?? this.limit,
      tasks: tasks ?? this.tasks,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      aiGeneratedTasks: aiGeneratedTasks ?? this.aiGeneratedTasks,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Task {
  final String task;
  final int importance; // 1~5の数値で重要度を表す  Sliderで表示
  final int difficulty; // 1~5の数値で難易度を表す  Sliderで表示
  final DateTime limit; // タスク達成期限
  final bool isCompleted;
  final bool isAiGenerated; // AI生成タスクかどうか（DifyAI連携用）

  const Task({
    required this.task,
    this.importance = 3,
    this.difficulty = 3,
    required this.limit,
    this.isCompleted = false,
    this.isAiGenerated = false,
  });

  Task copyWith({
    String? task,
    int? importance,
    int? difficulty,
    DateTime? limit,
    bool? isCompleted,
    bool? isAiGenerated,
  }) {
    return Task(
      task: task ?? this.task,
      importance: importance ?? this.importance,
      difficulty: difficulty ?? this.difficulty,
      limit: limit ?? this.limit,
      isCompleted: isCompleted ?? this.isCompleted,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    );
  }
}
