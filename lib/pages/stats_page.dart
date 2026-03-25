import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pomo_timer/models/goal_with_tasks.dart';
import 'package:pomo_timer/theme/app_colors.dart';

import '../providers.dart';
import '../providers/database_provider.dart';
import 'package:pomo_timer/data/database/daos/score_dao.dart'; // ScoreStatistics型のため
import 'package:pomo_timer/providers/score_provider.dart'; // プロバイダー
import 'goal/goal_main_page.dart';
import 'stats_detail_modal.dart'; // ★後で作るモーダルファイル
import '../widgets/score_chart.dart';
import '../widgets/concentration_bottomsheet.dart';

// 選択範囲の統計情報を取得するプロバイダー
final rangeStatsProvider =
    StreamProvider.family<ScoreStatistics, ({DateTime start, DateTime end})>((
      ref,
      arg,
    ) {
      final dao = ref.watch(scoreDaoProvider);
      // DAOにある watchStatsByRange を使用
      return dao.watchStatsByRange(arg.start, arg.end);
    });

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  final bool _showAllCompleted = false;
  DateTimeRange? _selectedRange;

  bool _isGoalsAscending = false;
  int _visibleGoalsCount = 3;

  bool _isReflectionsAscending = false;
  int _reflectionPage = 1;
  final int _itemsPerPage = 15;


  @override
  void initState() {
    super.initState();
    // ★ 初期値をここで設定（これで画面更新時にリセットされなくなる）
    _selectedRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    //（完了済み目標）
    final completedGoalsAsync = ref.watch(completedGoalsWithTasksProvider);
    //（今日達成）
    //final todayCompletedAsync = ref.watch(todayCompletedGoalsProvider);
    //（今週達成）
    //final weeklyCompletedAsync = ref.watch(weeklyCompletedGoalsProvider);
    final draftScoresAsync = ref.watch(draftScoresProvider);

    // スコアは同期 Provider → when 不要
    final todayStatsAsync = ref.watch(todayStatsProvider);
    final weekStatsAsync = ref.watch(thisWeekStatsProvider);
    final chartDataAsync = ref.watch(
      scoresInDateRangeProvider((
        start: _selectedRange!.start,
        end: _selectedRange!.end,
      )),
    );
    final rangeStatsAsync = ref.watch(
      rangeStatsProvider((
        start: _selectedRange!.start,
        end: _selectedRange!.end,
      )),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // スマホ向け UI
            if (constraints.maxWidth < 600) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        '統計・記録',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // 今日のカード
                      if (todayStatsAsync.asData?.value != null) ...[
                        _StatsCard(
                          title: '今日',
                          statsAsync: todayStatsAsync,
                          onTap: () {
                            // 期間を計算（providerと同じロジックで）
                            final now = DateTime.now();
                            final start = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );
                            final end = start.add(const Duration(days: 1));

                            showStatsDetailModal(context, '今日の詳細', start, end);
                          },
                        ),
                      ] else ...[
                        const Icon(Icons.coffee, size: 48, color: Colors.grey),
                      ],

                      const SizedBox(height: 8),

                      // 今週のカード
                      if (weekStatsAsync.asData?.value != null) ...[
                        _StatsCard(
                          title: '今週',
                          statsAsync: weekStatsAsync,
                          onTap: () {
                            final now = DateTime.now();
                            final start = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            ).subtract(Duration(days: now.weekday - 1));
                            final end = start.add(const Duration(days: 7));

                            showStatsDetailModal(context, '今週の詳細', start, end);
                          },
                        ),
                      ] else ...[
                        const Icon(Icons.coffee, size: 48, color: Colors.grey),
                      ],

                      const SizedBox(height: 10),

                      /// 後で評価の部分
                      draftScoresAsync.when(
                        data: (drafts) {
                          if (drafts.isEmpty) return const SizedBox.shrink();

                          // 達成目標表示部分のようなUI
                          return Card(
                            margin: const EdgeInsets.all(16),
                            color: Colors.orange.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.assignment_late,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '未評価の記録 (${drafts.length}件)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                // リスト表示
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: drafts.length,
                                  itemBuilder: (context, index) {
                                    final draft = drafts[index];
                                    return ListTile(
                                      title: Text(
                                        '${draft.score.startedAt.month}/${draft.score.startedAt.day}   ${draft.score.startedAt.hour}:${draft.score.startedAt.minute} の記録',
                                      ),
                                      subtitle: Text(
                                        '${draft.score.totalMinutes}分間',
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        _showDraftEvaluationFlow(
                                          context,
                                          ref,
                                          draft,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 10),

                      // 将来の拡張エリア
                      const Divider(),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          '期間を指定して推移を確認',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // 期間選択ボタン
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 1),
                                  ),
                                  initialDateRange: _selectedRange,
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedRange = picked; // 画面を更新
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: _selectedRange == null
                                  ? const Text('期間を選択')
                                  : Text(
                                      '${DateFormat('yyyy/MM/dd').format(_selectedRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_selectedRange!.end)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // グラフ表示エリア（プレースホルダー）
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: chartDataAsync.when(
                          loading: () => const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, _) => SizedBox(
                            height: 200,
                            child: Center(child: Text('エラー: $err')),
                          ),
                          data: (scores) {
                            if (scores.isEmpty) {
                              return const SizedBox(
                                height: 200,
                                child: Center(child: Text("この期間のデータはありません")),
                              );
                            }
                            return ScoreChart(scores: scores);
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                      if (rangeStatsAsync.asData?.value != null) ...[
                        _StatsCard(
                          title: '選択期間の合計',
                          statsAsync: rangeStatsAsync,
                          onTap: () {
                            showStatsDetailModal(
                              context,
                              '選択期間の詳細',
                              _selectedRange!.start,
                              _selectedRange!.end,
                            );
                          },
                        ),
                      ] else ...[
                        const Icon(
                          Icons.coffee,
                          size: 48,
                          color: Colors.black12,
                        ),
                        Text(
                          'この期間にデータはありません',
                          style: TextStyle(color: Colors.black38),
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),

                      completedGoalsAsync.when(
                        loading: () =>
                        const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text("エラー: $err")),
                        data: (completedGoals) {
                          final sortedGoals = List<GoalWithTasks>.from(completedGoals)
                            ..sort((a, b) {
                              final dateA = a.goal.completedAt ?? DateTime(0);
                              final dateB = b.goal.completedAt ?? DateTime(0);
                              return _isGoalsAscending
                                  ? dateA.compareTo(dateB) // 古い順
                                  : dateB.compareTo(dateA); // 新しい順
                            });
                          final visibleGoals = sortedGoals.take(_visibleGoalsCount).toList();
                          final completedCount = completedGoals.length;
                          ///

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            // --- 1. 土台：木製のボード (Wooden Board) ---

                            child: Stack(
                              children: [
                                // --- 2. 四辺の木枠 (Wooden Frames) ---
                                Positioned(top: 0, left: 0, right: 0, height: 10, child: buildWoodFrame()), // 上枠
                                Positioned(bottom: 0, left: 0, right: 0, height: 10, child: buildWoodFrame()), // 下枠
                                Positioned(top: 0, bottom: 0, left: 0, width: 10, child: buildWoodFrame()), // 左枠
                                Positioned(top: 0, bottom: 0, right: 0, width: 10, child: buildWoodFrame()), // 右枠

                                // --- 3. メイン：羊皮紙 (Parchment) ---
                                Padding(
                                  padding: const EdgeInsets.all(10), // 木枠の内側に配置
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
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
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '目標履歴',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              // 並び替えボタン
                                              TextButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    _isGoalsAscending = !_isGoalsAscending;
                                                  });
                                                },
                                                icon: Icon(
                                                  _isGoalsAscending
                                                      ? Icons.arrow_upward // 古い順
                                                      : Icons.arrow_downward, // 新しい順
                                                  size: 16,
                                                  color: Colors.orange,
                                                ),
                                                label: Text(
                                                  _isGoalsAscending ? '昇順' : '降順',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(50, 30),
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Text(
                                                '達成数: $completedCount件',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // 件数表示
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Text(
                                              '全$completedCount件中 ${visibleGoals.length}件を表示',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          if (visibleGoals.isEmpty)
                                            const Text(
                                              'まだ完了した目標はありません',
                                              style: TextStyle(color: Colors.grey),
                                            )
                                          else ...[
                                            ...visibleGoals.map(
                                                  (g) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      const Color(0xFFFFFFFF),
                                                      Colors.grey.shade50,
                                                    ],
                                                    center: Alignment.centerLeft,
                                                    radius: 1.2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(2),
                                                  boxShadow: [
                                                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(2,2),),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                    bottom: 12.0,
                                                  ),
                                                  child: _buildCompletedGoalTile(g),
                                                ),
                                              ),
                                            ),

                                            // 「もっと見る」ボタン
                                            if (completedCount > visibleGoals.length)
                                              Center(
                                                child: TextButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      _visibleGoalsCount += 5; // 5件ずつ増やす
                                                    });
                                                  },
                                                  icon: const Icon(Icons.add),
                                                  label: Text(
                                                    'さらに表示 (残り${completedCount - _visibleGoalsCount}件)',
                                                  ),
                                                ),
                                              ),

                                            // 「閉じる」ボタン（オプション：表示数が多い場合のみ出す）
                                            if (visibleGoals.length > 10)
                                              Center(
                                                child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _visibleGoalsCount = 3; // 初期値に戻す
                                                    });
                                                  },
                                                  child: const Text('表示を減らす', style: TextStyle(color: Colors.grey)),
                                                ),
                                              ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      /// 振り返り一覧の部分
                      _buildReflectionsSection(context, ref),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }

            ///----------------------------------------------
            return Center(
              child: SizedBox(
                width: 900,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          '統計・記録',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child:
                                  // 今日のカード
                                  _StatsCard(
                                    title: '今日',
                                    statsAsync: todayStatsAsync,
                                    onTap: () {
                                      // 期間を計算（providerと同じロジックで）
                                      final now = DateTime.now();
                                      final start = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                      );
                                      final end = start.add(
                                        const Duration(days: 1),
                                      );

                                      showStatsDetailModal(
                                        context,
                                        '今日の詳細',
                                        start,
                                        end,
                                      );
                                    },
                                  ),
                            ),

                            const SizedBox(width: 20),

                            Expanded(
                              child: // 今週のカード
                              _StatsCard(
                                title: '今週',
                                statsAsync: weekStatsAsync,
                                onTap: () {
                                  final now = DateTime.now();
                                  final start = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  ).subtract(Duration(days: now.weekday - 1));
                                  final end = start.add(
                                    const Duration(days: 7),
                                  );

                                  showStatsDetailModal(
                                    context,
                                    '今週の詳細',
                                    start,
                                    end,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 20),

                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '目標履歴',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // 将来の拡張エリア
                                    const SizedBox(height: 16),
                                    const Divider(),

                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        '期間を指定して推移を確認',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // 期間選択ボタン
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              final picked =
                                                  await showDateRangePicker(
                                                    context: context,
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime.now()
                                                        .add(
                                                          const Duration(
                                                            days: 1,
                                                          ),
                                                        ),
                                                    initialDateRange:
                                                        DateTimeRange(
                                                          start: DateTime.now()
                                                              .subtract(
                                                                const Duration(
                                                                  days: 7,
                                                                ),
                                                              ),
                                                          end: DateTime.now(),
                                                        ),
                                                  );
                                              if (picked != null) {
                                                debugPrint(
                                                  'Selected range: ${picked.start} - ${picked.end}',
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                            label: const Text('期間を選択'),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // グラフ表示エリア（プレースホルダー）
                                    Container(
                                      height: 250,
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade100,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // 期間選択ボタン
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () async {
                                                      final picked =
                                                          await showDateRangePicker(
                                                            context: context,
                                                            firstDate: DateTime(
                                                              2020,
                                                            ),
                                                            lastDate:
                                                                DateTime.now().add(
                                                                  const Duration(
                                                                    days: 1,
                                                                  ),
                                                                ),
                                                            initialDateRange:
                                                                _selectedRange,
                                                          );
                                                      if (picked != null) {
                                                        setState(() {
                                                          _selectedRange =
                                                              picked; // 画面を更新
                                                        });
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.calendar_today,
                                                    ),
                                                    label:
                                                        _selectedRange == null
                                                        ? const Text('期間を選択')
                                                        : Text(
                                                            '${DateFormat('yyyy/MM/dd').format(_selectedRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_selectedRange!.end)}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 40),

                                            // グラフ表示エリア（プレースホルダー）
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                              child: chartDataAsync.when(
                                                loading: () => const SizedBox(
                                                  height: 200,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                                error: (err, _) => SizedBox(
                                                  height: 200,
                                                  child: Center(
                                                    child: Text('エラー: $err'),
                                                  ),
                                                ),
                                                data: (scores) {
                                                  if (scores.isEmpty) {
                                                    return const SizedBox(
                                                      height: 200,
                                                      child: Center(
                                                        child: Text(
                                                          "この期間のデータはありません",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return ScoreChart(
                                                    scores: scores,
                                                  );
                                                },
                                              ),
                                            ),

                                            const SizedBox(height: 20),
                                            if (rangeStatsAsync.asData?.value !=
                                                null) ...[
                                              _StatsCard(
                                                title: '選択期間の合計',
                                                statsAsync: rangeStatsAsync,
                                                onTap: () {
                                                  showStatsDetailModal(
                                                    context,
                                                    '選択期間の詳細',
                                                    _selectedRange!.start,
                                                    _selectedRange!.end,
                                                  );
                                                },
                                              ),
                                            ] else ...const [
                                              Icon(
                                                Icons.coffee,
                                                size: 48,
                                                color: Colors.black12,
                                              ),
                                              Text(
                                                'この期間にデータはありません',
                                                style: TextStyle(
                                                  color: Colors.black38,
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 40),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
          },
        ),
      ),
    );
  }


  Widget _buildCompletedGoalTile(GoalWithTasks goal) {
    final bool completedInTime =
        goal.goal.completedAt != null &&
        goal.goal.completedAt!.isBefore(goal.goal.limit);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      title: Row(
        children: [
          Expanded(
            child: Text(
              goal.goal.goal,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            completedInTime ? Icons.check_circle : Icons.warning_amber_rounded,
            color: completedInTime ? Colors.green : Colors.orangeAccent,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            completedInTime ? '期限内' : '期限超過',
            style: TextStyle(
              color: completedInTime ? Colors.green : Colors.orangeAccent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          '重要度:${goal.goal.importance} / 影響度:${goal.goal.impact} / 期限:${DateFormat('yyyy/MM/dd').format(goal.goal.limit)}'
          '${goal.goal.completedAt != null ? ' \n完了日:${DateFormat('yyyy/MM/dd').format(goal.goal.completedAt!)}' : ''}',
          style: const TextStyle(color: Colors.grey),
        ),
      ),

      children: [
        if (goal.tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'この目標にはタスクがありません',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: goal.tasks
                  .map(
                    (t) => ListTile(
                      dense: true,
                      leading: Icon(
                        t.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: t.isCompleted ? Colors.green : Colors.grey,
                      ),
                      title: Text(t.task),
                      subtitle: Text(
                        '重要度:${t.importance} /　難易度:${t.difficulty} /  期限:${DateFormat('yyyy/MM/dd').format(t.limit)}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }


  Widget _buildReflectionsSection(BuildContext context, WidgetRef ref) {
    final reflectionsAsync = ref.watch(reflectionsProvider);

    return reflectionsAsync.when(
      data: (reflections) {
        if (reflections.isEmpty) {
          return
          const Text(
            'まだ記録した振り返りはありません',
            style: TextStyle(color: Colors.grey),
          );
        }

        // 1. ソート処理
        final sortedReflections = List.from(reflections)
          ..sort((a, b) {
            final dateA = a.score.startedAt;
            final dateB = b.score.startedAt;
            return _isReflectionsAscending
                ? dateA.compareTo(dateB)
                : dateB.compareTo(dateA);
          });
        // 2. ページネーション計算
        final totalCount = sortedReflections.length;
        final totalPages = (totalCount / _itemsPerPage).ceil();
        // ページ外に飛ばないよう補正
        final currentPage = _reflectionPage.clamp(1, totalPages > 0 ? totalPages : 1);

        final visibleReflections = sortedReflections
            .skip((currentPage - 1) * _itemsPerPage)
            .take(_itemsPerPage)
            .toList();

        return Card(
          margin: const EdgeInsets.all(16),
          color: Colors.purple.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 1段目
                    Row(
                      children: [
                        const Icon(Icons.rate_review, color: Colors.purple),
                        const SizedBox(width: 8),

                        Text(
                          '振り返り記録 (${reflections.length}件)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),

                        const SizedBox(width: 12),

                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _isReflectionsAscending = !_isReflectionsAscending),
                          icon: Icon(
                            _isReflectionsAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                          label: Text(_isReflectionsAscending ? '昇順' : '降順'),
                        ),
                      ],
                    ),

                    // 2段目（ページャー）
                    if (totalPages > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.chevron_left),
                            onPressed: currentPage > 1
                                ? () => setState(() => _reflectionPage--)
                                : null,
                          ),

                          Text('$currentPage / $totalPages'),

                          IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.chevron_right),
                            onPressed: currentPage < totalPages
                                ? () => setState(() => _reflectionPage++)
                                : null,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleReflections.length,
                itemBuilder: (context, index) {
                  final reflection = visibleReflections[index];
                  final score = reflection.score;
                  final hasAllReflections =
                      (score.goodPoints != null &&
                          score.goodPoints!.isNotEmpty) &&
                          (score.improvementPoints != null &&
                              score.improvementPoints!.isNotEmpty) &&
                          (score.futurePlans != null &&
                              score.futurePlans!.isNotEmpty);

                  return Slidable(
                    key: ValueKey(reflection.score.id),
                    // スワイプした時に出てくるボタン（右側に配置）
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(), // 追従する動き
                      extentRatio: 0.25, // ★スワイプが止まる位置（横幅の25%で止まる）
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            // 確認ダイアログを表示
                            final confirmed = await _showDeleteConfirmation(context);
                            if (confirmed == true) {
                              // 振り返りテキストのみ削除
                              ref.read(scoreDaoProvider).clearReflectionOnly(reflection.score.id);
                            }
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_sweep,
                          label: '消去',
                          // スワイプしすぎても勝手に実行されない設定
                          autoClose: true,
                        ),
                      ],
                    ),

                    // メインのコンテンツ（既存のカード）
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: const Icon(Icons.rate_review, color: Colors.purple, size: 20),
                      ),
                      title: Text(reflection.score.goalName ?? '目標なし',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 2,    // 横方向の要素間の隙間
                        runSpacing: 4, // 折り返した時の縦方向の隙間
                        children: [
                          Text(
                            DateFormat('yyyy/MM/dd HH:mm').format(score.startedAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          const SizedBox(height: 4),
                          if (score.goodPoints != null &&
                              score.goodPoints!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '良かった点',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          if (score.goodPoints != null &&
                              score.goodPoints!.isNotEmpty &&
                              (score.improvementPoints != null &&
                                  score.improvementPoints!.isNotEmpty ||
                                  score.futurePlans != null &&
                                      score.futurePlans!.isNotEmpty))
                            const SizedBox(width: 4),
                          if (score.improvementPoints != null &&
                              score.improvementPoints!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '改善点',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          if (score.improvementPoints != null &&
                              score.improvementPoints!.isNotEmpty &&
                              score.futurePlans != null &&
                              score.futurePlans!.isNotEmpty)
                            const SizedBox(width: 4),
                          if (score.futurePlans != null &&
                              score.futurePlans!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '今後の方針',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () {
                        _showReflectionDetailDialog(context, reflection);
                      },
                    ),
                  );
                },
              ),

              // ページ切り替えコントローラー
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 1 ? () => setState(() => _reflectionPage--) : null,
                      ),
                      Text('$currentPage / $totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages ? () => setState(() => _reflectionPage++) : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

// 振り返り詳細ダイアログ
  void _showReflectionDetailDialog(
      BuildContext context,
      ScoreWithDetails scoreDetails,
      ) {
    final score = scoreDetails.score;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '振り返り詳細',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        score.goalName ?? '目標なし',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('yyyy/MM/dd HH:mm').format(score.startedAt)} ・ ${score.totalMinutes}分 ・ スコア: ${score.totalScore.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 振り返り内容
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (score.goodPoints != null && score.goodPoints!.isNotEmpty) ...[
                          _buildReflectionDetailItem(
                            icon: Icons.star,
                            iconColor: Colors.green,
                            title: '良かった点',
                            content: score.goodPoints!,
                          ),
                        ] else ...[
                          _buildReflectionDetailItem(
                            icon: Icons.star,
                            iconColor: Colors.green,
                            title: '良かった点',
                            content: '記録されていないため、振り返り情報は表示できません。',
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (score.improvementPoints != null && score.improvementPoints!.isNotEmpty) ...[
                          _buildReflectionDetailItem(
                            icon: Icons.trending_up,
                            iconColor: Colors.orange,
                            title: '改善点',
                            content: score.improvementPoints!,
                          ),
                        ] else ... [
                          _buildReflectionDetailItem(
                            icon: Icons.trending_up,
                            iconColor: Colors.orange,
                            title: '改善点',
                            content: '記録されていないため、振り返り情報は表示できません。',
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (score.futurePlans != null && score.futurePlans!.isNotEmpty) ...[
                          _buildReflectionDetailItem(
                            icon: Icons.lightbulb_outline,
                            iconColor: Colors.blue,
                            title: '今後の方針',
                            content: score.futurePlans!,
                          )
                        ] else ... [
                          _buildReflectionDetailItem(
                            icon: Icons.lightbulb_outline,
                            iconColor: Colors.blue,
                            title: '今後の方針',
                            content: '記録されていないため、振り返り情報は表示できません。',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await _showConfirmDialog(
                      context,
                      title: '振り返りの消去',
                      content: 'この記録の振り返り内容のみを消去しますか？\n（統計データは保持されます）',
                    );

                    if (confirm == true) {
                      await ref.read(scoreDaoProvider).clearReflectionOnly(score.id);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.auto_fix_off, size: 18), // 「整える・消す」イメージ
                  label: const Text('振り返りのみを消去'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ParadiseColors.subaccentGold.withValues(alpha: 0.2), // 淡いゴールド
                    foregroundColor: ParadiseColors.deepText,
                    elevation: 0,
                    side: const BorderSide(color: ParadiseColors.subaccentGold), // 枠線でボタン感を出す
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

// 振り返り詳細項目
  Widget _buildReflectionDetailItem({
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
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

// 全振り返り一覧ダイアログ
  void _showAllReflectionsDialog(
      BuildContext context,
      List<ScoreWithDetails> reflections,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('振り返り記録一覧 (${reflections.length}件)'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reflections.length,
              itemBuilder: (context, index) {
                final reflection = reflections[index];
                final score = reflection.score;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: const Icon(
                      Icons.rate_review,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  title: Text(score.goalName ?? '目標なし'),
                  subtitle: Text(
                    '${DateFormat('yyyy/MM/dd HH:mm').format(score.startedAt)} ・ ${score.totalMinutes}分',
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showReflectionDetailDialog(context, reflection);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

}

// 未評価フロー開始メソッド
void _showDraftEvaluationFlow(
  BuildContext context,
  WidgetRef ref,
  ScoreWithDetails draft,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (_) => ConcentrationBottomSheet(
      onConfirm: (reflectionData) {//
        // BottomSheetを閉じる
        Navigator.pop(context);

        context.push(
          '/stats/draftevaluation',
          extra: {
            'draft': draft, // ScoreWithDetailsオブジェクト
            'reflectionData': reflectionData, // 入力された集中度 (int)
          },
        );
      },
      onLater: () {
        Navigator.pop(context);
      }, // 既にLaterなので閉じるだけ
      onSkip: () {
        showDialog(
          context: context,
          // builderの引数を dialogContext にリネームして、外側の context と区別する
          builder: (dialogContext) => AlertDialog(
            title: const Text('記録を削除しますか？'),
            content: const Text('この操作は取り消せません。「後で評価」リストからこのデータが削除されます。'),
            actions: [
              TextButton(
                // ダイアログだけを閉じる
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  try {
                    // 1. 確認ダイアログを閉じる
                    Navigator.of(dialogContext).pop();
                    // 2. 親のボトムシートを閉じる (外側の context を使用)
                    Navigator.of(context).pop();

                    // 3. 削除実行
                    // ProviderからDAOを取得して削除メソッドを呼ぶ
                    final dao = ref.read(scoreDaoProvider);
                    await dao.deleteScore(draft.score.id);

                    // 4. 完了メッセージを表示
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('記録を削除しました')),
                      );
                    }
                  } catch (e) {
                    debugPrint('削除エラー: $e');
                    // エラー時はスナックバーなどで通知しても良い
                  }
                },
                child: const Text('削除する'),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _StatsCard extends StatelessWidget {
  final String title;
  final AsyncValue<ScoreStatistics> statsAsync;
  final VoidCallback onTap;

  const _StatsCard({
    required this.title,
    required this.statsAsync,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.analytics, color: Colors.orange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723), // 濃い茶色で視認性向上
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 20),
              statsAsync.when(
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
                ),
                error: (e, _) => Text('エラー: $e', style: const TextStyle(color: Colors.red)),
                data: (stats) {
                  if (stats.totalSessions == 0) {
                    return _buildEmptyState();
                  }

                  final int avgMins = stats.averageMinutes.floor();
                  final int avgSecs = ((stats.averageMinutes - avgMins) * 60).round();

                  return GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85, // 少し縦長にして余裕を持たせる
                    children: [
                      _StatItem(label: '合計スコア', value: stats.totalScore.toStringAsFixed(0), icon: Icons.auto_graph),
                      _StatItem(label: '平均スコア', value: stats.averageScore.toStringAsFixed(0), icon: Icons.star),
                      _StatItem(label: '合計時間', value: '${stats.totalMinutes}m', icon: Icons.timer),
                      _StatItem(label: '平均時間', value: '${avgMins}m${avgSecs}s', icon: Icons.timelapse),
                      _StatItem(label: '集中度', value: '${stats.averageConcentration.toStringAsFixed(0)}%', icon: Icons.bolt),
                      _StatItem(label: '完了数', value: '${stats.totalSessions}回', icon: Icons.check_circle),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          const Text('まだ記録がありません', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // 非常に薄いグレーのタイル
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.orange.shade700),
          const SizedBox(height: 6),
          // 数字がはみ出さないようFittedBoxで囲む
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.orange.shade900,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showDeleteConfirmation(BuildContext context) {
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

Future<bool?> _showConfirmDialog(BuildContext context, {required String title, required String content}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(color: ParadiseColors.deepText, fontWeight: FontWeight.bold)),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          child: const Text('実行する'),
        ),
      ],
    ),
  );
}