import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // pubspec.yamlに intl パッケージが必要
import 'package:pomo_timer/providers/score_provider.dart';
import 'package:pomo_timer/data/database/app_database.dart';
import 'package:pomo_timer/models/task_score_data.dart'; // ★追加: TaskScoreData

import '../data/database/daos/score_dao.dart';
import '../providers/database_provider.dart'; // ScoreWithDetailsのため

// モーダルを表示する関数
void showStatsDetailModal(BuildContext context, String title, DateTime start, DateTime end) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 画面の高さの9割まで広げるため
    backgroundColor: Colors.transparent,
    builder: (context) => _DetailSheet(title: title, start: start, end: end),
  );
}

class _DetailSheet extends ConsumerWidget {
  final String title;
  final DateTime start;
  final DateTime end;

  const _DetailSheet({required this.title, required this.start, required this.end});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 引数で渡された期間を使ってデータを取得
    final scoresAsync = ref.watch(scoresInDateRangeProvider((start: start, end: end)));

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(height: 1),

              // リスト表示
              Expanded(
                child: scoresAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('エラー: $e')),
                  data: (scoreList) {
                    if (scoreList.isEmpty) {
                      return const Center(child: Text('この期間の記録はありません'));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: scoreList.length,
                      itemBuilder: (context, index) {
                        final item = scoreList[index];
                        final score = item.score; // 親データ
                        //final tasks = item.tasks; // 子データ（必要なら表示）

                        return Dismissible(
                          key: Key('score_list_${score.id}'), // ユニークなキー
                          direction: DismissDirection.endToStart, // 右から左スワイプ
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.redAccent,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          // スワイプ完了時の処理
                          confirmDismiss: (direction) async {
                            return await _showDeleteConfirmDialog(context);
                          },
                          onDismissed: (direction) {
                            // ref を使って削除実行
                            ref.read(scoreDaoProvider).deleteScore(score.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('記録を削除しました')),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                score.totalScore.toStringAsFixed(0),
                                style: TextStyle(color: Colors.orange.shade800, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(score.goalName ?? '目標なし'),
                            subtitle: Text(
                              '${DateFormat('M/d HH:mm').format(score.startedAt)} ・ ${score.totalMinutes}分 ・ 集中:${score.concentrationLevel}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () {
                              _showSessionDetailDialog(context, item);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


void _showSessionDetailDialog(BuildContext context, ScoreWithDetails scoreDetails) {
  final score = scoreDetails.score;
  final tasks = scoreDetails.tasks;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          return AlertDialog(
            // 余白を調整してカード風にする
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Container(
              width: double.maxFinite, // 横幅いっぱい
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6, // 高さを画面の60%に制限
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // コンテンツの高さに合わせる
                children: [
                  // --- ヘッダー：全体情報 ---
                  _buildDialogHeader(context, score),

                  const Divider(height: 1),

                  // --- ボディ：タスクリストと振り返り ---
                  Flexible( // スクロール可能にする
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // タスクリスト
                          if (tasks.isNotEmpty) ...[
                            if (score.goalName != null) ...[
                              Text('目標: ${score.goalName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 12),
                            ],
                            ...tasks.map((task) => _buildTaskItem(task)),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ] else ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('このセッションにはタスクがありません', style: TextStyle(color: Colors.grey)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ],
                          // 振り返り情報
                          _buildReflectionSection(score),

                          const SizedBox(height: 24),
                          const Divider(),

                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: OutlinedButton.icon( // TextButtonより誤操作しにくいOutlinedを選択
                              onPressed: () async {
                                final confirmed = await _showDeleteConfirmDialog(context);
                                if (confirmed == true) {
                                  await ref.read(scoreDaoProvider).deleteScore(score.id);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('記録を完全に削除しました'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                              label: const Text(
                                'この記録を完全に削除する',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// --- 以下、ダイアログのUIを作るためのヘルパーWidget ---

// ダイアログのヘッダー部分
Widget _buildDialogHeader(BuildContext context, ScoresTableData score) {
  return Container(
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('セッション詳細', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _InfoColumn(label: '合計時間', value: '${score.totalMinutes}分'),
            _InfoColumn(label: '集中度', value: score.concentrationLevel.toString()),
            _InfoColumn(label: 'スコア', value: score.totalScore.toStringAsFixed(0)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${DateFormat('yyyy/MM/dd HH:mm').format(score.startedAt)} - ${DateFormat('HH:mm').format(score.endedAt)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  );
}

// タスク1件ごとの表示
Widget _buildTaskItem(TaskScoreData task) { // ★変更: TaskScoresTableDataからTaskScoreDataに
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Row(
      children: [
        // 達成度に応じたアイコン
        Icon(
          task.achievePercent >= 80 ? Icons.check_circle : Icons.circle_outlined,
          color: task.achievePercent >= 80 ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        // タスク名と達成度
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.taskName, style: const TextStyle(fontSize: 16)),
              Text('達成度: ${task.achievePercent}%', style: const TextStyle(fontSize: 15, color: Colors.black54)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ヘッダー内の情報表示用
class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

// 振り返り情報を表示するセクション
Widget _buildReflectionSection(ScoresTableData score) {
  final hasReflection = score.goodPoints != null ||
      score.improvementPoints != null ||
      score.futurePlans != null;

  if (!hasReflection) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(Icons.rate_review, color: Colors.purple, size: 20),
          SizedBox(width: 8),
          Text(
            '振り返り',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (score.goodPoints != null && score.goodPoints!.isNotEmpty) ...[
        _buildReflectionItem(
          icon: Icons.thumb_up,
          iconColor: Colors.green,
          title: '良かった点',
          content: score.goodPoints!,
        ),
        const SizedBox(height: 12),
      ],
      if (score.improvementPoints != null && score.improvementPoints!.isNotEmpty) ...[
        _buildReflectionItem(
          icon: Icons.trending_up,
          iconColor: Colors.orange,
          title: '改善点',
          content: score.improvementPoints!,
        ),
        const SizedBox(height: 12),
      ],
      if (score.futurePlans != null && score.futurePlans!.isNotEmpty) ...[
        _buildReflectionItem(
          icon: Icons.lightbulb_outline,
          iconColor: Colors.blue,
          title: '今後の方針',
          content: score.futurePlans!,
        ),
      ],
    ],
  );
}

// 振り返り項目1件の表示
Widget _buildReflectionItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String content,
}) {
  return Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: iconColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: iconColor.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    ),
  );
}


Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('記録の削除'),
      content: const Text('このデータを削除してもよろしいですか？\nこの操作は取り消せません。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('削除'),
        ),
      ],
    ),
  );
}