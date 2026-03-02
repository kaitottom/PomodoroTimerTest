import 'package:drift/drift.dart';

// スコア全体の記録テーブル
class ScoresTable extends Table {
  // IDと日時
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();

  // ConcentrationScore の内容
  IntColumn get totalMinutes => integer()();
  IntColumn get concentrationLevel => integer()(); // 0-100

  // Goalのスナップショット
  IntColumn get goalId => integer().nullable()(); // 分析用リンク
  TextColumn get goalName => text().nullable()(); // 名前保存

  // EvaluationMode (Enumをintとして保存: 0=aggregate, 1=perTask)
  IntColumn get evaluationMode => integer()();

  // 計算結果
  RealColumn get totalScore => real()();

  BoolColumn get isDraft => boolean().withDefault(const Constant(false))();

  // ★追加: JSONでタスク情報を保存
  // フォーマット: [{"originalTaskId":1,"taskName":"タスク名","difficulty":3,"impact":4,"achievePercent":80}, ...]
  TextColumn get taskDataJson => text().nullable()();

  // ★追加: 振り返り情報
  TextColumn get goodPoints => text().nullable()(); // 良かった点（感想）
  TextColumn get improvementPoints => text().nullable()(); // 改善点
  TextColumn get futurePlans => text().nullable()(); // 今後の方針
}
