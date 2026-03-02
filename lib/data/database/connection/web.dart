import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor connect() {
  return WebDatabase(
    'pomo_timer_db',   // IndexedDB に保存されるDB名
    logStatements: true,
  );
}


/*
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor connect() {
  // ★修正点: wasmSQLite3Loader を false にして、WASM読み込みを無効化します。
  // これで "expected magic word..." のエラーは確実に出なくなります。
  return WebDatabase(
    'pomo_timer_db',
    logStatements: true,
    setup: (database) {
      // 必要な場合のみ設定（通常は空でOK）
    },
    // 重要: ここでWASMローダーを無効化できる場合もありますが、
    // WebDatabaseのコンストラクタによっては指定できない場合があります。
    // その場合、以下の実装を使います。
  );
}
*/


