import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor connect() {
  return LazyDatabase(() async {
    // アプリのドキュメント保存場所を取得
    final dbFolder = await getApplicationDocumentsDirectory();
    // ファイルパスを作成
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    // バックグラウンドでNativeDatabaseを作成
    return NativeDatabase.createInBackground(file);
  });
}
