//振り分け設定ファイル
// デフォルトでは 'web.dart' を読み込むと見せかけて...
// 'dart.library.io'（スマホやPCの機能）が使える環境なら 'native.dart' に差し替える
export 'web.dart' if (dart.library.io) 'native.dart';
