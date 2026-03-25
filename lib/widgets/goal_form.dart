import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:pomo_timer/theme/app_colors.dart';
import '../data/database/app_database.dart';

// 2025/11/18 引数をGoalSettingDataからGoalSaveCallbackという差分返すように変えた。
// 親に渡すコールバックの型定義を変更
typedef GoalSaveCallback = void Function(GoalSettingsTableCompanion companion);

// 1. StatefulWidgetに変更します
class GoalForm extends StatefulWidget {
  final GoalSettingData? initialGoal;
  //final Function(GoalSettingData) onSave;
  final GoalSaveCallback onSave; // ★型を修正

  final String submitButtonText;

  const GoalForm({
    super.key,
    this.initialGoal,
    required this.onSave,
    this.submitButtonText = '保存',
  });

  // 2. Stateクラスの型を公開クラスに変更します
  @override
  GoalFormState createState() => GoalFormState();
}

// 3. クラス名を `_GoalFormState` から `GoalFormState` に変更します
class GoalFormState extends State<GoalForm> {
  final TextEditingController _goalController = TextEditingController();
  int _importance = 3;
  int _impact = 3;
  late DateTime _limit;

  @override
  void initState() {
    super.initState();
    // initialGoalがnullでも動作するように初期値を設定します
    _limit = DateTime.now().add(const Duration(days: 21));

    if (widget.initialGoal != null) {
      _goalController.text = widget.initialGoal!.goal;
      _importance = widget.initialGoal!.importance;
      _impact = widget.initialGoal!.impact;
      _limit = widget.initialGoal!.limit;
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  // 4. 外部からフォームの保存をトリガーするための公開メソッドを追加します
  void saveForm() {
    _handleSave();
  }

  void _handleSave() {
    final goalText = _goalController.text.trim();
    if (goalText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目標を入力してください')),
        );
      }
      return;
    }


    /*final goalSettings = GoalSettingData(
      id: widget.initialGoal?.id ?? 0,
      goal: goalText,
      importance: _importance,
      impact: _impact,
      limit: _limit,
      isCompleted: widget.initialGoal?.isCompleted ?? false,
    );*/

    //widget.onSave(goalSettings);
    // ★★★ 変更点 ★★★
    // フォームの入力内容から `Companion` を作成する
    final companion = GoalSettingsTableCompanion(
      goal: drift.Value(_goalController.text), // 例
      importance: drift.Value(_importance), // 例
      impact: drift.Value(_impact), // 例
      limit: drift.Value(_limit), // 例

    );
    // 作成した Companion をコールバックで親に渡す
    widget.onSave(companion);


    // このフォーム内のボタンが押された時だけSnackBarを表示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.submitButtonText}しました')),
      );
    }
  }

  // --- buildメソッド以下は、あなたの既存のコードをほぼそのまま使用します ---
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('目標：', style: TextStyle(fontSize: 15)),
        TextField(
          controller: _goalController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '目標を入力',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('重要度：', style: TextStyle(fontSize: 15)),
            Text('$_importance', style: const TextStyle(fontSize: 15)),
          ],
        ),
        Slider(
          value: _importance.toDouble(),
          min: 1, max: 5, divisions: 4,
          label: '$_importance',
          onChanged: (value) => setState(() => _importance = value.round()),
          thumbColor: ParadiseColors.skyDeepBlue,
          activeColor: ParadiseColors.crystalRock,
          inactiveColor: ParadiseColors.cloudGrey,
        ),
        // ... (影響度スライダーも同様)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('影響度：', style: TextStyle(fontSize: 15)),
            Text('$_impact', style: const TextStyle(fontSize: 15)),
          ],
        ),
        Slider(
          value: _impact.toDouble(),
          min: 1, max: 5, divisions: 4,
          label: '$_impact',
          onChanged: (value) => setState(() => _impact = value.round()),
          thumbColor: ParadiseColors.groundBlue,
          activeColor: ParadiseColors.crystalRock,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('期限：', style: TextStyle(fontSize: 15)),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _limit,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _limit = picked);
              },
              child: Text('${_limit.year}/${_limit.month}/${_limit.day}', style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(widget.submitButtonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
