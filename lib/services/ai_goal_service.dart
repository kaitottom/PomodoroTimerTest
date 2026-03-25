import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/database/app_database.dart';
import '../utils/ai_prompts.dart';

/*
import 'package:http/http.dart' as http;


class AiGoalService {
  // 1. APIキーの取得（--dart-define または 直書き）
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<List<dynamic>> decomposeGoal(GoalSettingData goal) async {
    try {
      debugPrint('--- AI生成開始 (Direct HTTP) ---');

      // プロンプトの構築
      final fullPrompt = AiPrompts.buildGoalPrompt(
        userGoal: goal.goal,
        importance: goal.importance,
        impact: goal.impact,
        limit: goal.limit,
      );

      // 2. エンドポイントを「v1」に固定
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey'
      );

      // 3. POSTリクエストの送信
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': fullPrompt}]
            }
          ],
          'generationConfig': {
            'response_mime_type': 'application/json', // JSON形式で返却を強制
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint('APIエラーレスポンス: ${response.body}');
        throw Exception('API接続失敗: ${response.statusCode}');
      }

      // 4. レスポンスの解析
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String text = data['candidates'][0]['content']['parts'][0]['text'];

      debugPrint('!!! AIからの生レスポンス: $text');

      // 文字列として返ってきたJSONをListに変換
      return jsonDecode(text) as List<dynamic>;

    } catch (e) {
      debugPrint('AiGoalServiceで例外発生: $e');
      rethrow;
    }
  }
}
*/

class AiGoalService {
  // 環境変数からAPIキーを取得
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static final Map<String, List<dynamic>> _cache = {};

  Future<List<dynamic>> decomposeGoal(GoalSettingData goal) async {

    if (_apiKey.isEmpty) {
      debugPrint('CRITICAL ERROR: GEMINI_API_KEY が設定されていません。');
      debugPrint('--dart-define=GEMINI_API_KEY=あなたのキー をビルド時に指定してください。');
      throw Exception('APIキー未設定');
    }

    if (_cache.containsKey(goal.goal)) {
      print('キャッシュから取得: ${goal.goal}');
      return _cache[goal.goal]!;
    }

    // モデル名のリスト（優先順位順・2026年3月時点）
    final List<String> modelNames = [
      'gemini-2.5-flash',        // 最新・最速・バランス型（推奨）
      'gemini-2.0-flash',        // 安定・従来型（後方互換）
      'gemini-2.5-flash-lite',   // 軽量・低コスト・超高速
      'gemini-2.5-pro',          // 高精度・推論重視（やや低速）
      'gemini-2.0-flash-lite',   // レガシー・最低��スト
    ];

    for (var modelName in modelNames) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );

        debugPrint('AI生成開始: モデル候補数 ${modelNames.length}  使用モデル：$modelName');
        //debugPrint("検証用 - キーの長さ: ${const String.fromEnvironment('GEMINI_API_KEY').length}");

        final fullPrompt = AiPrompts.buildGoalPrompt(
          userGoal: goal.goal,
          importance: goal.importance,
          impact: goal.impact,
          limit: goal.limit,
        );

        final response = await model
            .generateContent([Content.text(fullPrompt)])
            .timeout(const Duration(seconds: 60));

        if (response.text == null) return [];

        final decoded = jsonDecode(response.text!);
        debugPrint('JSONパース成功: $decoded');
        return decoded;// 成功したらリターン
      } on TimeoutException {
        debugPrint('エラー: 60秒以内に応答がありませんでした（タイムアウト）');
        rethrow;
      } catch (e) {
        debugPrint('$modelName でエラーが発生しました。次のモデルを試します: $e');
        // 最後のモデルも失敗した場合は、ループを抜けて catch ブロックへ
        if (modelName == modelNames.last) rethrow;
        continue;
      }
    }
    throw Exception('すべてのモデルで生成に失敗しました');
  }
}

