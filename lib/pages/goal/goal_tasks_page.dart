// Not necessary
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/goal_settings_provider.dart';
import '../../models/goal_settings.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_form_modal.dart';

class GoalTasksPage extends ConsumerStatefulWidget {

  const GoalTasksPage({super.key});

  @override
  ConsumerState<GoalTasksPage> createState() => _GoalTasksPageState();
}

class _GoalTasksPageState extends ConsumerState<GoalTasksPage> {
  final int maxTasks = 5;

  // AI生成タスクの一時保存用
  List<Task> _aiSuggestedTasks = [];
  bool _aiTasksLoaded = false;

  @override
  void initState() {
    super.initState();
    // AI生成タスクが必要な場合は初回のみセット
    final currentGoal = ref.read(tempGoalProvider);
    if (currentGoal != null &&
        currentGoal.tasks.isEmpty &&
        _aiSuggestedTasks.isNotEmpty &&
        !_aiTasksLoaded) {
      ref
          .read(tempGoalProvider.notifier)
          .addAiGeneratedTasks(_aiSuggestedTasks);
      setState(() {
        _aiTasksLoaded = true;
      });
    }
  }

  // 仮: 外部からAIタスクを受け取るメソッド（実際は引数やProvider経由で渡す）
  void receiveAiTasks(List<Task> aiTasks) {
    setState(() {
      _aiSuggestedTasks = aiTasks;
      _aiTasksLoaded = true;
    });
  }

  void _handleAiGeneratedTasks() {
    final currentGoal = ref.read(tempGoalProvider);
    if (currentGoal != null && currentGoal.tasks.isEmpty) {
      // 初回設定時のみAIタスクを生成

      // 現在はサンプルタスクを追加（実際のAI連携時は削除）
      _addSampleAiTasks();
    }
  }

  void _addSampleAiTasks() {
    // サンプルAI生成タスク（将来的にDifyAIから取得）
    // 注意: 実際の実装では、AI使用の選択に基づいてこの処理を実行
    final sampleTasks = [
      Task(
        task: '目標の詳細分析を行う',
        difficulty: 4,
        impact: 5,
        limit: DateTime.now().add(const Duration(days: 2)),
        isAiGenerated: true,
      ),
      Task(
        task: '具体的なアクションプランを作成',
        difficulty: 5,
        impact: 4,
        limit: DateTime.now().add(const Duration(days: 3)),
        isAiGenerated: true,
      ),
    ];

    ref.read(tempGoalProvider.notifier).addAiGeneratedTasks(sampleTasks);
  }

  void _showTaskFormModal({Task? editingTask}) {
    final currentGoal = ref.read(tempGoalProvider);
    if (currentGoal == null) return;

    showDialog(
      context: context,
      builder: (context) => TaskFormModal(
        initialTask: editingTask,
        currentTaskCount: currentGoal.tasks.length,
        maxTasks: maxTasks,
        onSave: (task) {
          if (editingTask != null) {
            ref.read(tempGoalProvider.notifier).updateTask(task);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('タスクを更新しました')));
          } else {
            ref.read(tempGoalProvider.notifier).addTask(task);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('タスクを追加しました')));
          }
        },
      ),
    );
  }

  void _deleteTask(String taskName) {
    ref.read(tempGoalProvider.notifier).deleteTask(taskName);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('タスクを削除しました')));
  }

  void _editTask(Task task) {
    _showTaskFormModal(editingTask: task);
  }

  void _completeTask(String taskName) {
    ref.read(tempGoalProvider.notifier).completeTask(taskName);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('タスクを完了しました')));
  }

  // 編集後はgoal_review_pageに直接戻るようにする
  void _onEditComplete() {
    context.go('/goal/review');
  }

  @override
  Widget build(BuildContext context) {
    final currentGoal = ref.watch(tempGoalProvider);
    // GoRouterのクエリパラメータからfromReviewを取得
    final uri = GoRouterState.of(context).uri;
    final fromReview = uri.queryParameters['fromReview'] == 'true';

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

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // スマホ向け
              return Column(
                children: [
                  // ヘッダー
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go('/goal'),//--------------------
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const Expanded(
                              child: Text(
                                'タスク設定',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 48), // バランス調整
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '目標: ${currentGoal.goal}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // タスク一覧
                  Expanded(
                    child: currentGoal.tasks.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'タスクがありません',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 247, 130, 130),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'タスクを追加してください',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 236, 147, 147),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: currentGoal.tasks.length,
                            itemBuilder: (context, index) {
                              final task = currentGoal.tasks[index];
                              return TaskCard(
                                task: task,
                                onDelete: () => _deleteTask(task.task),
                                onEdit: () => _editTask(task),
                              );
                            },
                          ),
                  ),

                  // フッター
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (currentGoal.tasks.length < maxTasks)
                          ElevatedButton.icon(
                            onPressed: () => _showTaskFormModal(),
                            icon: const Icon(Icons.add),
                            label: const Text('タスクを追加'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 30),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        if (currentGoal.tasks.length >= maxTasks)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Text(
                              'タスクは最大5個までです',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            /*Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.go('/goal/new'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('目標を修正'),
                              ),
                            ),*/
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _onEditComplete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('完了・確認'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // タブレット・PC向け
              return Center(
                child: SizedBox(
                  width: 800,
                  child: Column(
                    children: [
                      // ヘッダー
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.pop(),//go('/goal'),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                const Expanded(
                                  child: Text(
                                    'タスク設定',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '目標: ${currentGoal.goal}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // タスク一覧
                      Expanded(
                        child: currentGoal.tasks.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.task_outlined,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'タスクがありません',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'タスクを追加してください',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                itemCount: currentGoal.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = currentGoal.tasks[index];
                                  return TaskCard(
                                    task: task,
                                    onDelete: () => _deleteTask(task.task),
                                    onEdit: () => _editTask(task),
                                  );
                                },
                              ),
                      ),

                      // フッター
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            if (currentGoal.tasks.length < maxTasks)
                              ElevatedButton.icon(
                                onPressed: () => _showTaskFormModal(),
                                icon: const Icon(Icons.add),
                                label: const Text('タスクを追加'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            if (currentGoal.tasks.length >= maxTasks)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: const Text(
                                  'タスクは最大5個までです',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => context.go('/goal/new'),
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
                                  child: const Text('目標を修正'),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    if (fromReview) {
                                      context.go('/goal/review');
                                    } else {
                                      context.go('/goal/review');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 32,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('完了・確認'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
*/