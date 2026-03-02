import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../models/goal_with_tasks.dart';
import '../../providers/goal_settings_provider.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/task_card.dart';
import '../../widgets/confirm_back_wrapper.dart';
import '../../data/database/app_database.dart';
import '../../providers/database_provider.dart';

class GoalReviewPage extends ConsumerStatefulWidget {
  const GoalReviewPage({super.key});

  @override
  ConsumerState<GoalReviewPage> createState() => _GoalReviewPageState();
}

class _GoalReviewPageState extends ConsumerState<GoalReviewPage> {
  //const GoalReviewPage({super.key});
  bool _isSaving = false;


  @override
  Widget build(BuildContext context) {
    final currentGoal = ref.watch(tempGoalProvider);
    final confirmKey =  GlobalKey<ConfirmBackWrapperState>();

    if (currentGoal == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('目標が設定されていません'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/goal/new'),
                  child: const Text('目標を設定'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ConfirmBackWrapper(
       key: confirmKey,
      //onConfirmPop: () => context.go('/goal'),
      onConfirmPop: ()  {
        ref.read(tempGoalProvider.notifier).reset();
        context.go('/goal/new');
      },
        message: '編集内容が失われるかもしれません。戻ってよろしいですか？',
        child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // スマホ向け
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        '目標確認',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // 目標表示
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '設定した目標',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // goalwithtasks に移してから
                            GoalCard(
                                goalWithTasks: GoalWithTasks(
                                  goal: currentGoal.goal,
                                  tasks: currentGoal.tasks,
                                ),
                                onDelete: null,
                                onEdit: null,
                                showActions: false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // タスク一覧
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '設定したタスク',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '${currentGoal.tasks.length}個',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (currentGoal.tasks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'タスクが設定されていません',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              ...currentGoal.tasks.map(
                                (task) =>
                                    TaskCard(task: task, showActions: false),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // アクションボタン
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  context.push('/goal/edit?from=review'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('目標・タスクを修正'),
                            ),
                          ),
                          //const SizedBox(width: 12),

                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _confirmGoal(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '目標を確定',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                            '目標確認',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50),

                          // 目標表示
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '設定した目標',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GoalCard(
                                    goalWithTasks: GoalWithTasks(
                                      goal: currentGoal.goal,
                                      tasks: currentGoal.tasks,
                                    ),
                                    onDelete: null,
                                    onEdit: null,
                                    showActions: false),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // タスク一覧
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '設定したタスク',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      '${currentGoal.tasks.length}個',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (currentGoal.tasks.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'タスクが設定されていません',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  ...currentGoal.tasks.map(
                                    (task) => TaskCard(
                                      task: task,
                                      showActions: false,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),

                          // アクションボタン
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          ElevatedButton(
                                onPressed: () =>
                                    context.push('/goal/edit?from=review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('目標・タスクを修正'),
                              ),

                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              onPressed: () => _confirmGoal(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '目標を確定',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  void _confirmGoal(BuildContext context, WidgetRef ref) {
    if (_isSaving) return; // 二重押し防止
    _isSaving = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を確定'),
        content: const Text('この目標とタスクで確定しますか？\n確定後は変更できません。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isSaving = false; // キャンセル時もフラグを戻す
            },
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentGoal = ref.read(tempGoalProvider);
              if (currentGoal == null) return;

              final db = ref.read(goalDaoProvider);

              final goalCompanion = GoalSettingsTableCompanion.insert(
                goal: currentGoal.goal.goal,
                importance: Value(currentGoal.goal.importance),
                impact: Value(currentGoal.goal.impact),
                limit: currentGoal.goal.limit,
                isCompleted: Value(false),
                createdAt: Value(DateTime.now()),
                //aiGeneratedTasks: Value(currentGoal.goal.aiGeneratedTasks),
                completedAt: const Value(null),
              );

              // TaskData → TasksTableCompanion に変換
              final taskCompanions = currentGoal.tasks.map((task) {
                return TasksTableCompanion.insert(
                  task: task.task,
                  importance: Value(task.importance),
                  difficulty: Value(task.difficulty),
                  limit: task.limit,
                  isCompleted: Value(task.isCompleted),
                  isAiGenerated: Value(task.isAiGenerated),
                  goalId: -1,//あとからgoalIdとリンク
                );
              }).toList();

              // DBに新規保存
              await db.createGoalWithTasks(goalCompanion, taskCompanions);
              ref.read(tempGoalProvider.notifier).reset();

              if (!context.mounted) return;
              Navigator.of(context).pop();
              context.go('/goal');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('目標が確定されました')),
              );

              _isSaving = false; // 完了後にフラグ解除
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

}
