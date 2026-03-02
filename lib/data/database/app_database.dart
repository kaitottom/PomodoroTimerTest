/*import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/goal_settings_table.dart';
import 'tables/task_table.dart';
import 'daos/goal_dao.dart';
import 'daos/task_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    GoalSettingsTable,
    TasksTable,
  ],
  daos: [
    GoalDao,
    TaskDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
*/

//import 'dart:io';
import 'package:drift/drift.dart';
//import 'package:drift/native.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:path/path.dart' as p;

// ▼▼▼ アプリで使う全ての「テーブル」と「DAO」をインポート ▼▼▼
import 'tables/goal_settings_table.dart';
import 'tables/task_table.dart';
import 'daos/goal_dao.dart';
import 'daos/task_dao.dart';
import 'daos/score_dao.dart';

import 'tables/score_tables.dart';

// ★追加: 作成したconnectionファイルを 'impl' という名前でimport
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

// ▼▼▼【最重要】tablesとdaosの両方をdriftに教えます ▼▼▼
@DriftDatabase(
  tables: [
    GoalSettingsTable,
    TasksTable,
    ScoresTable,
  ], // ★変更: TaskScoresTableを削除
  daos: [GoalDao, TaskDao, ScoreDao],
)
class AppDatabase extends _$AppDatabase {
  //AppDatabase() : super(_openConnection());
  // ★修正: コンストラクタで impl.connect() を呼ぶ
  // これにより、実行環境に応じて勝手に Web用 か Native用 か選ばれます
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 5;

  // ★マイグレーション処理を追加
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // バージョン2で追加されたテーブルを作成する
        await m.createTable(scoresTable);
        // 注意: バージョン2ではTaskScoresTableも作成されていたが、
        // バージョン3で削除されるため、ここでは作成しない
      }
      if (from < 3) {
        // バージョン3: ScoresTableにtaskDataJsonカラムを追加
        // 既存のTaskScoresTableデータをJSONに変換して保存する必要がある場合は
        // ここでマイグレーション処理を追加
        await m.addColumn(scoresTable, scoresTable.taskDataJson);
        // TaskScoresTableは削除（既存データの移行が必要な場合は別途処理）
        // await m.deleteTable('task_scores_table'); // 必要に応じて
      }
      if (from < 4) {
        // バージョン4: ScoresTableに振り返りカラムを追加
        // Driftのマイグレーションでは、カラム定義を直接参照する
        await m.addColumn(scoresTable, scoresTable.goodPoints);
        await m.addColumn(scoresTable, scoresTable.improvementPoints);
        await m.addColumn(scoresTable, scoresTable.futurePlans);
      }
      if (from < 5) {
        // バージョン5: 目標（Goal）には重要度と影響度でタスク（Task）には重要度と難易度に変更
        await m.database.customStatement(
            'ALTER TABLE tasks_table RENAME COLUMN impact TO importance;'
        );
      }
    },
  );
}

// データベース接続（単一のファイル 'db.sqlite' を使う）
/*
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
*/
