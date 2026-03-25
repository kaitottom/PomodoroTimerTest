import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_timer/data/database/app_database.dart';
import '../../providers/goal_settings_provider.dart';
import '../../services/ai_goal_service.dart';
import '../../widgets/goal_form.dart';
import '../../widgets/goal_tasks_bottom_sheet.dart';
import '../../widgets/confirm_back_wrapper.dart';
import 'dart:core';


class GoalNewPage extends ConsumerStatefulWidget {
  const GoalNewPage({super.key});

  @override
  ConsumerState<GoalNewPage> createState() => _GoalNewPageState();
}

class _GoalNewPageState extends ConsumerState<GoalNewPage> {
  //bool _initialized = false;
  final _confirmKey =  GlobalKey<ConfirmBackWrapperState>();

  @override
  void initState() {
    super.initState();
    // 新規作成なので tempGoal を初期化
    //ref.read(tempGoalProvider.notifier).reset();
    final emptyGoal = GoalSettingData(
      id: -1,
      goal: '',
      importance: 3,
      impact: 3,
      limit: DateTime.now(),
      isCompleted: false,
      createdAt: DateTime.now(),
      aiGeneratedTasks: null,
      completedAt: null,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tempGoalProvider.notifier).setInitialState(emptyGoal, []);
    });
  }
  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    final uri = Uri.parse(routeName);
    final initFromLatest = uri.queryParameters['initFromLatest'] == 'true';
    //final fromReview = widget.fromReview;

    //if (fromReview) {       レビューから戻ってきた場合は一時データを保持} else
      if (initFromLatest) {
      final goalList = ref.read(goalsProvider);
      final latestGoal = goalList.isNotEmpty ? goalList.last : null;
      if (latestGoal != null) {
        ref.read(tempGoalProvider.notifier).setTempGoal(latestGoal);
      }
    } else {
      // 新規開始の場合は前回の一時データをクリア
      ref.read(tempGoalProvider.notifier).reset();//TempGoal();
    }

    _initialized = true;
  }*/

  void _showAiUsageDialog(GoalSettingData goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AIタスク生成 (月に1回まで：残り 1 / 1 回)'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('目標に基づいてAIがタスクを自動生成しますか？'),
            SizedBox(height: 12),
            Text(
              '• AIが関連するタスクを提案します\n'
              '• 生成されたタスクは後で編集・削除できます\n'
              '• 手動でタスクを設定することも可能です',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _prepareForManualTaskSetting(goal);
            },
            child: const Text('手動で設定'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _prepareForAiTaskGeneration(goal);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('AIで生成(残り 1 / 1 回)'),
          ),
        ],
      ),
    );
  }

/*
  void _prepareForAiTaskGeneration(GoalSettingData goal) {///
    ref.read(tempGoalProvider.notifier).setInitialState(goal, []);
    final sampleTasks = [
      TaskData(
        id: 0, // 一時データなのでIDは仮で 0
        goalId: goal.id,
        task: '目標の詳細分析を行う',
        importance: 5,
        difficulty: 4,
        limit: DateTime.now().add(const Duration(days: 2)),
        isCompleted: false,
        isAiGenerated: true,
      ),
      TaskData(
        id: 1,
        goalId: goal.id,
        task: '具体的なアクションプランを作成',
        importance: 4,
        difficulty: 5,
        limit: DateTime.now().add(const Duration(days: 3)),
        isCompleted: false,
        isAiGenerated: true,
      ),
    ];
    ref.read(tempGoalProvider.notifier).addAiGeneratedTasks(sampleTasks);

    _openTaskBottomSheet();

  }

// 1. 利用制限チェック
    final canUseAi = ref.read(canUseAiProvider);
    if (!canUseAi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AIタスク生成は月1回まで利用可能です。')),
      );
      return;
    }
 */

  List<TaskData> _getFallbackTasks(int goalId) {
    final List<Map<String, dynamic>> masterData = [
      {'name': '目標達成の最大の障害を1つ特定し、その対策を「もし〜なら〜する」の形でメモする', 'importance': 5, 'difficulty': 2, 'days': 2},
      {'name': 'この目標に活かせる自分の「過去の成功体験」や「得意なこと」を3つ書き出す', 'importance': 4, 'difficulty': 2, 'days': 2},
      {'name': '今から「20秒以内」にできる、最も小さく簡単な一歩（例：本を開く）を今すぐ実行する', 'importance': 5, 'difficulty': 1, 'days': 1},
      {'name': '目標達成後に「最高に嬉しい自分」を想像し、達成の瞬間を1分間だけ鮮明に描く', 'importance': 3, 'difficulty': 1, 'days': 1},
      {'name': '最終目標までの道のりを3つの「中間チェックポイント」に分割して日付を決める', 'importance': 4, 'difficulty': 3, 'days': 4},
      {'name': '目標達成時に一緒に喜んでくれる「仲間」や「家族」への報告とお祝い内容を決める', 'importance': 3, 'difficulty': 2, 'days': 7},
      {'name': '集中を妨げるもの（スマホ等）を、作業中は「物理的に見えない場所」へ隔離する', 'importance': 5, 'difficulty': 2, 'days': 3},
      {'name': '明日から1週間のカレンダーに、この目標に集中する時間「25分」をあらかじめ予約する', 'importance': 5, 'difficulty': 2, 'days': 1},
      {'name': '自分が一番集中できる「場所」と「時間帯」を特定し、そこでの作業を優先する', 'importance': 4, 'difficulty': 3, 'days': 4},
      {'name': '目標達成のための「3つの異なるルート」を書き出し、今の自分に最適なものを1つ選ぶ', 'importance': 4, 'difficulty': 3, 'days': 2},
      {'name': '設定した計画をどのように楽しくすすめていきたいかを考える', 'importance': 4, 'difficulty': 2, 'days': 2},
    ];

    // シャッフルして5つ取り出す
    masterData.shuffle();
    return masterData.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return TaskData(
        id: -index - 100, // 生成タスクと被らない負のID
        goalId: goalId,
        task: data['name'],
        importance: data['importance'],
        difficulty: data['difficulty'],
        limit: DateTime.now().add(Duration(days: data['days'])),
        isCompleted: false,
        isAiGenerated: true,
      );
    }).toList();
  }

  Future<void> _prepareForAiTaskGeneration(GoalSettingData goal) async {

    // 2. ローディング表示（インジケーター等）
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false, // ローディング中に戻るボタンで閉じられないようにする
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.lightBlueAccent),
                SizedBox(height: 16),
                Text(
                  "AIがタスクを生成中...",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 2. AIサービスを呼び出してJSONリストを取得
      debugPrint('UI: AI生成処理を開始します');
      final aiService = AiGoalService();
      final List<dynamic> jsonList = await aiService.decomposeGoal(goal);

      // 3. JSON（Map形式）を TaskData オブジェクトのリストに変換
      final aiGeneratedTasks = jsonList.asMap().entries.map((entry) {
        final index = entry.key; // 0, 1, 2... という連番
        final data = entry.value as Map<String, dynamic>;

        return TaskData(
          id: index, // 一時的なIDとして連番を割り当て
          goalId: goal.id,
          task: data['name'] ?? 'タスク$index',
          importance: (data['importance'] as num?)?.toInt() ?? 3, // 整数に変換
          difficulty: (data['difficulty'] as num?)?.toInt() ?? 3, // 整数に変換
          // deadline_days を元に現在時刻からの期限を計算
          limit: DateTime.now().add(Duration(days: (data['deadline_days'] as num?)?.toInt() ?? 7)),
          isCompleted: false,
          isAiGenerated: true,
        );
      }).toList();

      // 4. Providerの状態を更新
      ref.read(tempGoalProvider.notifier).setInitialState(goal, []);
      ref.read(tempGoalProvider.notifier).addAiGeneratedTasks(aiGeneratedTasks);

      // 5. ボトムシートを開く
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _openTaskBottomSheet();
      }
    } catch (e) {
      debugPrint('UIエラー捕捉: $e'); // ログを一番先に取る

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

        // 2. エラー内容に応じてメッセージを分かりやすく分岐（任意）
        String errorMessage = 'AIタスク生成に失敗しました。';
        if (e.toString().contains('FormatException')) {
          errorMessage = 'AIの回答を解析できませんでした。もう一度お試しください。';
        } else if (e.toString().contains('GenerativeAIException')) {
          errorMessage = '通信エラーが発生しました。接続を確認してください。';
        }
        debugPrint('エラー内容: $errorMessage');

      final randomTasks = _getFallbackTasks(goal.id);

      ref.read(tempGoalProvider.notifier).setInitialState(goal, []);
      ref.read(tempGoalProvider.notifier).addAiGeneratedTasks(randomTasks);

      if (mounted) _openTaskBottomSheet();
        // 3. スナックバーを表示。失敗しても「手動設定」へ誘導するアクションを追加
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('AI生成が制限中のため、達成のヒントとなるタスクをセットしました。'),
            action: SnackBarAction(label: '了解', onPressed: () {}),
          ),
        );

    }
  }

  void _prepareForManualTaskSetting(GoalSettingData goal) {
    ref.read(tempGoalProvider.notifier).setInitialState(goal, []);
    _openTaskBottomSheet();

  }

  void _openTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GoalTasksBottomSheet(
        onComplete: () {
          _confirmKey.currentState?.allowNextPop(); // ← ★ 追加
          context.push('/goal/review');
        },//onComplete: () => context.push('/goal/review'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tempGoal = ref.watch(tempGoalProvider);

    return ConfirmBackWrapper(
      key: _confirmKey,
      onConfirmPop: ()  {
        ref.read(tempGoalProvider.notifier).reset();
        Navigator.pop(context);
        },
      message: '今この画面から戻ると入力内容が失われます。よろしいですか？',
      child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(//
          builder: (context, constraints) {//
            if (constraints.maxWidth < 600) {//
              // スマホ向け
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        '新規目標設定',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '＜目標設定のコツ＞',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '具体的で測定可能な目標を設定しましょう。\n'
                                  '重要度と難易度を考慮して優先順位を決めます。\n'
                                  'なるべく障害の予測とその対策を考えましょう。',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'AIタスク生成　(月に1回まで)',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '目標設定後、AIが関連するタスクを自動生成できます。\n手動でタスクを設定することも可能です。',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 目標設定フォーム
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GoalForm(
                          initialGoal: tempGoal?.goal,
                          onSave: (companion) {//goalData
                            /*
                            ref
                                .read(tempGoalProvider.notifier)
                                .setInitialState(goalData,[]);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  //fromReview ? '目標を修正しました' :
                                  '目標を一時保存しました',
                                ),
                              ),
                            );
                            */
                            // ★★★ 変更点 ★★★
                            // フォームからの変更で、一時データのGoal情報だけを更新
                            ref.read(tempGoalProvider.notifier).updateGoalFields(companion);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('目標を一時保存しました')),
                            );

                            // 更新後の最新のGoal情報を取得して次の処理に渡す
                            final updatedGoal = ref.read(tempGoalProvider)!.goal;


                            _showAiUsageDialog(updatedGoal);

                          },
                          submitButtonText: '次へ（タスク設定へ）移動',
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            } else {
              // タブレット・PC向け
              return Center(
                child: SizedBox(
                  width: 800,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            '新規目標設定',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  '＜目標設定のコツ＞',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '具体的で測定可能な目標を設定しましょう。\n重要度と難易度を考慮して優先順位を決めます。',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: const Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'AIタスク生成　(月に1回まで)',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '目標設定後、AIが関連するタスクを自動生成できます。\n手動でタスクを設定することも可能です。',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),

                          // 目標設定フォーム
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: GoalForm(
                              initialGoal: tempGoal?.goal,
                              onSave: (companion) {//goalData
                                /*ref
                                    .read(tempGoalProvider.notifier)
                                    .setInitialState(goalData, []);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      //fromReview ? '目標を修正しました' :
                                      '目標を一時保存しました',
                                    ),
                                  ),
                                );
                                                       */
// ★★★ 変更点 ★★★
                                // フォームからの変更で、一時データのGoal情報だけを更新
                                ref.read(tempGoalProvider.notifier).updateGoalFields(companion);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('目標を一時保存しました')),
                                );

                                // 更新後の最新のGoal情報を取得して次の処理に渡す
                                final updatedGoal = ref.read(tempGoalProvider)!.goal;


                                _showAiUsageDialog(updatedGoal);

                              },
                              submitButtonText:
                              //(fromReview) ? '修正を完了する' :
                              '次へ（タスク設定へ）',
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    ),
    );
  }
}
