import 'dart:convert';
import '../utils/score_calculator.dart';

/// JSONで保存されるタスクスコアデータ
/// TaskScoresTableの代わりに使用
class TaskScoreData {
  final int? originalTaskId; // 元のタスクID（分析用、nullable）
  final String taskName; // タスク名
  final int importance; // 重要度（1-5）
  final int difficulty; // 難易度（1-5）
  final int achievePercent; // 達成度（0-100、-1は完了済み）
  final bool? wasCompletedBefore;

  TaskScoreData({
    this.originalTaskId,
    required this.taskName,
    required this.importance,
    required this.difficulty,
    required this.achievePercent,
    this.wasCompletedBefore = false,
  });

  /// JSONに変換
  Map<String, dynamic> toJson() => {
    'originalTaskId': originalTaskId,
    'taskName': taskName,
    'importance': importance,
    'difficulty': difficulty,
    'achievePercent': achievePercent,
    'wasCompletedBefore' : wasCompletedBefore,
  };

  /// JSONから作成
  factory TaskScoreData.fromJson(Map<String, dynamic> json) => TaskScoreData(
    originalTaskId: json['originalTaskId'] as int?,
    taskName: json['taskName'] as String,
    importance: json['importance'] as int,
    difficulty: json['difficulty'] as int,
    achievePercent: json['achievePercent'] as int,
    wasCompletedBefore: json['wasCompletedBefore'] as bool,
  );

  /// スコア計算用ヘルパー（表示時に使用）
  double calculateWeightedScore(int concentrationLevel) {
    if (achievePercent == -1) return 0.0; // 完了済みはスコア0
    return ScoreCalculator.calculateTaskScore(
      importance: importance,
      difficulty: difficulty,
      achievePercent: achievePercent,
      concentrationLevel: concentrationLevel,
    );
  }

  /// TaskScoresTableData互換性のためのプロパティ
  /// （既存コードとの互換性を保つため）
  int get id => originalTaskId ?? 0; // 仮のID（実際には使用しない）
  
  /// コピー作成
  TaskScoreData copyWith({
    int? originalTaskId,
    String? taskName,
    int? importance,
    int? difficulty,
    int? achievePercent,
    bool? wasCompletedBefore,
  }) {
    return TaskScoreData(
      originalTaskId: originalTaskId ?? this.originalTaskId,
      taskName: taskName ?? this.taskName,
      importance: importance ?? this.importance,
      difficulty: difficulty ?? this.difficulty,
      achievePercent: achievePercent ?? this.achievePercent,
      wasCompletedBefore: wasCompletedBefore ?? this.wasCompletedBefore,
    );
  }
}

/// JSON文字列とTaskScoreDataリストの変換ヘルパー
class TaskScoreDataJsonConverter {
  /// TaskScoreDataリストをJSON文字列に変換
  static String toJson(List<TaskScoreData> tasks) {
    if (tasks.isEmpty) return '[]';
    return jsonEncode(tasks.map((t) => t.toJson()).toList());
  }

  /// JSON文字列からTaskScoreDataリストに変換
  static List<TaskScoreData> fromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty || jsonStr == '[]') return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((json) => TaskScoreData.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // JSON解析エラーの場合は空リストを返す
      return [];
    }
  }
}


