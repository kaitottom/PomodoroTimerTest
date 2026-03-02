import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_timer/data/database/app_database.dart';
import '../../providers/goal_settings_provider.dart';
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
        title: const Text('AIタスク生成'),
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
            child: const Text('AIで生成'),
          ),
        ],
      ),
    );
  }

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
                                  'AIタスク生成',
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
                                      'AIタスク生成',
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
