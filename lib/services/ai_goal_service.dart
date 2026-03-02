import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/ai_prompts.dart';

class AiGoalService {
  // 環境変数からAPIキーを取得
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  Future<List<dynamic>> decomposeGoal(String goal) async {
    // プロンプト管理ファイルから指示文を取得
    final fullPrompt = AiPrompts.buildGoalPrompt(goal);

    final response = await _model.generateContent([Content.text(fullPrompt)]);

    if (response.text == null) return [];
    return jsonDecode(response.text!);
  }
}