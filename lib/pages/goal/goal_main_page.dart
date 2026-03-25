/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用
import 'package:pomo_timer/models/goal_with_tasks.dart';
import '../../data/database/app_database.dart'; // TaskData等の型定義
import '../../providers/database_provider.dart';
import '../../providers/goal_settings_provider.dart';
import '../../providers.dart';


// ★追加: 新しい表示用カードウィジェット
class CurrentGoalOverviewCard extends ConsumerWidget {
  final GoalWithTasks goalWithTasks;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const CurrentGoalOverviewCard({
    super.key,
    required this.goalWithTasks,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = goalWithTasks.goal;
    final tasks = goalWithTasks.tasks;
    final dateFormat = DateFormat('yyyy/MM/dd');

    // 期限切れチェック
    final isOverdue = goal.limit.isBefore(DateTime.now()) && goal.completedAt == null;
    final limitColor = isOverdue ? Colors.red : Colors.grey[700];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ヘッダー部分（目標名・期限） ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '現在の目標',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.goal,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 期限バッジ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOverdue ? Colors.red.shade200 : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '期限',
                        style: TextStyle(fontSize: 10, color: limitColor),
                      ),
                      Text(
                        dateFormat.format(goal.limit),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: limitColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 編集・削除ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 24),
                    label: const Text('編集'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 24),
                    label: const Text('削除'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
              ],
            ),
            const Divider(height: 1),

            // --- タスク一覧部分 ---
            const SizedBox(height: 12),
            const Text(
              'タスク一覧',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'タスクが設定されていません',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...tasks.map((task) => _buildTaskRow(context, ref, task, dateFormat)),
          ],
        ),
      ),
    );
  }

  // タスク1行分の表示
  Widget _buildTaskRow(BuildContext context, WidgetRef ref, TaskData task, DateFormat dateFormat) {
    final isTaskOverdue = task.limit.isBefore(DateTime.now()) && !task.isCompleted;

    return InkWell(
      // タップ時に完了状態を切り替える
      onTap: () async {
        final taskDao = ref.read(taskDaoProvider);
        await taskDao.changeCompleteTask(task);

        if(task.isCompleted == false) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${task.task}」　完了')),
        );
        }

        ref.invalidate(currentGoalProvider);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // チェックマーク部分
            Icon(
              task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
              size: 26,
              color: task.isCompleted ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タスク名
                  Text(
                    task.task,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  // タスク期限
                  Text(
                    '期限: ${dateFormat.format(task.limit)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isTaskOverdue ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
// --------------------------------------------------------
// メインページ
// --------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pomo_timer/models/goal_with_tasks.dart';
import 'package:pomo_timer/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../providers.dart';

class QuestBoardCard extends ConsumerWidget {
  final GoalWithTasks goalWithTasks;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const QuestBoardCard({
    super.key,
    required this.goalWithTasks,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = goalWithTasks.goal;
    final tasks = goalWithTasks.tasks;
    final dateFormat = DateFormat('yyyy/MM/dd');
    final isOverdue = goal.limit.isBefore(DateTime.now()) && goal.completedAt == null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      // --- 1. 土台：木製のボード (Wooden Board) ---
      decoration: BoxDecoration(
        color: const Color(0xFF4E342E), // 濃い木の色
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(2, 4)),
        ],
      ),
      child: Stack(
        children: [
          // --- 2. 四辺の木枠 (Wooden Frames) ---
          Positioned(top: 0, left: 0, right: 0, height: 10, child: buildWoodFrame()), // 上枠
          Positioned(bottom: 0, left: 0, right: 0, height: 10, child: buildWoodFrame()), // 下枠
          Positioned(top: 0, bottom: 0, left: 0, width: 10, child: buildWoodFrame()), // 左枠
          Positioned(top: 0, bottom: 0, right: 0, width: 10, child: buildWoodFrame()), // 右枠

          // --- 3. メイン：羊皮紙 (Parchment) ---
          Padding(
            padding: const EdgeInsets.all(16), // 木枠の内側に配置
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF7F0D5), // 中心：明るいベージュ
                    const Color(0xFFE6D5B8), // 外側：少し濃いベージュ
                  ],
                  center: Alignment.center,
                  radius: 1.2,
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(2,2),),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー部分
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ★ QUESTの文字を斜めにして手書き感を出す
                              Transform.rotate(
                                angle: -0.05, // わずかに左に傾ける
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.brown,),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'QUEST',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.brown[900],
                                      letterSpacing: 2.0,
                                      fontFamily: 'Serif',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                goal.goal,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Serif',
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 期限表示
                        _buildDeadlineStamp(isOverdue, dateFormat.format(goal.limit)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.brown.withValues(alpha: 0.3), thickness: 1),

                    // ミッションリスト
                    const SizedBox(height: 4),
                    Text(
                      'MISSIONS',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (tasks.isEmpty)
                      const Text('No missions.', style: TextStyle(color: Colors.brown, fontStyle: FontStyle.italic))
                    else
                      ...tasks.map((task) => _buildQuestTaskRow(context, ref, task, dateFormat)),

                    // 操作ボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 22, color: Colors.brown)),
                        if (onDelete != null)
                          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 22, color: Colors.redAccent)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 4. 装飾：四隅の鋲 (Pins) ---
          _buildPin(top: 22, left: 22),
          _buildPin(top: 22, right: 22),
          _buildPin(bottom: 22, left: 22),
          _buildPin(bottom: 22, right: 22),
        ],
      ),
    );
  }

  // 木枠の質感用ウィジェット

  // 期限スタンプ
  Widget _buildDeadlineStamp(bool isOverdue, String date) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: isOverdue ? Colors.red : Colors.brown, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text('LIMIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : Colors.brown)),
          Text(date, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : Colors.brown)),
        ],
      ),
    );
  }

  // 鋲（びょう）
  Widget _buildPin({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 10, height: 10,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
          gradient: RadialGradient(colors: [Colors.white70, Colors.grey]),
        ),
      ),
    );
  }

  // タスク行（機能維持）
  Widget _buildQuestTaskRow(BuildContext context, WidgetRef ref, TaskData task, DateFormat dateFormat) {
    return InkWell(
      onTap: () async {
        final taskDao = ref.read(taskDaoProvider);
        await taskDao.changeCompleteTask(task);
        ref.invalidate(currentGoalProvider);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // 行間を少し広げて見やすく
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // 複数行になっても崩れない
          children: [
            // --- 修正点：視認性の高いカスタムチェックボックス ---
            Container(
              margin: const EdgeInsets.only(top: 2), // テキストの1行目と高さを合わせる
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                // 枠線を少し太くして「いかにも」な枠にする
                border: Border.all(color: const Color(0xFF3E2723), width: 2),
                borderRadius: BorderRadius.circular(4),
                // 完了時は塗りつぶす
                color: task.isCompleted ? Colors.green : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Color(0xFFF3E5AB)) // 羊皮紙の色でチェック
                  : null,
            ),
            const SizedBox(width: 12),

            // --- 修正点：テキストのスタイル調整 ---
            Expanded(
              child: Text(
                task.task,
                style: TextStyle(
                  fontSize: 16, // 少し大きく
                  height: 1.3, // 行間を確保
                  fontFamily: 'Serif',
                  fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.bold,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  decorationThickness: 2,
                  color: task.isCompleted
                      ? Colors.brown.withValues(alpha: 0.5)
                      : const Color(0xFF3E2723),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildWoodFrame() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF3E2723),
      border: Border.all(color: Colors.black26, width: 0.5),
    ),
  );
}

class GoalMainPage extends ConsumerWidget {
  const GoalMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // データベースから現在の目標を取得するProviderを監視
    final asyncCurrentGoal = ref.watch(currentGoalProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncCurrentGoal.when(
          data: (currentGoal) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // スマホ向けレイアウト
                if (constraints.maxWidth < 600) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            '目標管理',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),

                          // --- 現在の目標表示 (GoalCard を CurrentGoalOverviewCard に置き換え) ---
                          if (currentGoal != null)
                            QuestBoardCard( // ★変更
                              goalWithTasks: currentGoal,
                              onDelete: () => _showDeleteConfirmDialog(context, ref, currentGoal),
                              onEdit: () async {
                                ref.read(tempGoalProvider.notifier).reset();
                                context.go('/goal/edit/${currentGoal.goal.id}?from=main');
                              },
                            )
                          else
                            _buildNoGoalSetWidget(),

                          const SizedBox(height: 10),

                          // --- アクションボタン ---
                          if (currentGoal == null)
                            ElevatedButton.icon(
                              onPressed: () {
                                ref.read(tempGoalProvider.notifier).reset();//中断された際にはこのページ来たときにメッセージでも出す。
                                context.go('/goal/new');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('新規目標設定'),
                              style: _buttonStyle(ParadiseColors.skyDeepBlue),
                            ),

                          if (currentGoal != null)
                            ElevatedButton.icon(
                              onPressed: () => _showCompleteConfirmDialog(context, ref, currentGoal),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('目標達成'),
                              style: _buttonStyle(Colors.green),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                }
                // PC・タブレット向けレイアウト
                else {
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
                                '目標管理',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 50),

                              // --- 現在の目標表示 (PC版も置き換え) ---
                              if (currentGoal != null)
                                QuestBoardCard( // ★変更
                                  goalWithTasks: currentGoal,
                                  onDelete: () => _showDeleteConfirmDialog(context, ref, currentGoal),
                                  onEdit: () async {
                                    ref.read(tempGoalProvider.notifier).reset();
                                    context.go('/goal/edit/${currentGoal.goal.id}?from=main');
                                  },
                                )
                              else
                                _buildNoGoalSetWidget(isDesktop: true),

                              const SizedBox(height: 40),

                              // --- アクションボタン ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (currentGoal == null)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        ref.read(tempGoalProvider.notifier).reset();
                                        context.go('/goal/new');
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('新規目標設定'),
                                      style: _buttonStyle(ParadiseColors.skyDeepBlue, isDesktop: true),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () => _showCompleteConfirmDialog(context, ref, currentGoal),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text('目標達成'),
                                      style: _buttonStyle(Colors.green, isDesktop: true),
                                    ),
                                ],
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
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
        ),
      ),
    );
  }

  // 目標が設定されていない場合に表示する共通ウィジェット
  Widget _buildNoGoalSetWidget({bool isDesktop = false}) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: isDesktop ? 64 : 48,
            color: Colors.grey,
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            '目標が設定されていません',
            style: TextStyle(
              fontSize: 20,
              color: isDesktop ? Colors.grey : const Color.fromARGB(255, 71, 69, 69),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color, {bool isDesktop = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 20 : 16,
        horizontal: isDesktop ? 24 : 0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, GoalWithTasks goalWithTasks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を削除'),
        content: Text('「${goalWithTasks.goal.goal}」を本当に削除しますか？\n削除すると復元できません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final goalDao = ref.read(goalDaoProvider);
              await goalDao.deleteGoalWithTasks(goalWithTasks.goal.id);
              ref.invalidate(currentGoalProvider);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('目標を削除しました')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmDialog(BuildContext context, WidgetRef ref, GoalWithTasks goalWithTasks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を完了'),
        content: Text('「${goalWithTasks.goal.goal}」を完了しますか？\n完了した目標はアーカイブされます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final goalDao = ref.read(goalDaoProvider);
              await goalDao.completeGoalAndTasks(goalWithTasks.goal.id);

              ref.invalidate(currentGoalProvider);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('目標を完了しました！おめでとうございます！')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('完了'),
          ),
        ],
      ),
    );
  }
}
