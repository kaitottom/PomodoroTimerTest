import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:pomo_timer/providers/database_provider.dart';
import '../models/score.dart';
import '../models/task_score_data.dart'; // ★追加: TaskScoreData
import '../../widgets/confirm_back_wrapper.dart';

import '../../data/database/app_database.dart'; // DB
// テーブル定義
import '../../utils/score_calculator.dart'; // 計算機

/// EvaluationPage — 1ファイルで完結版
class EvaluationPage extends ConsumerStatefulWidget {
  final SessionData sessionData;

  const EvaluationPage({super.key, required this.sessionData});

  @override
  ConsumerState<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends ConsumerState<EvaluationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 評価タブなど画面の状態、スコアを保持するための変数
  late Score _currentScore;
  late int focusMinutes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _initializeScore();
  }

  void _initializeScore() {
    final data = widget.sessionData;
    final goal = data.goal;
    focusMinutes = data.focusMinutes;

    // Task (DBモデル) -> TaskScore (UIモデル) への変換
    final initialTasks =
        goal?.tasks.map((t) {
          return TaskScore(
            id: t.id,
            taskName: t.task,
            importance: t.importance,
            difficulty: t.difficulty,
            achievePercent: t.isCompleted ? -1 : 0, //達成済みのタスクと未完のものの区別
            weightedScore: 0,
          );
        }).toList() ??
        [];

    _currentScore = Score(
      startedAt: data.startedAt,
      endedAt: data.endedAt,
      goalId: goal?.goal.id,
      goalName: goal?.goal.goal,
      concentrationScore: ConcentrationScore(
        totalMinutes: data.focusMinutes,
        concentrationLevel: data.concentrationLevel,
      ),
      taskScores: initialTasks,
      goodPoints: data.goodPoints, // ★追加: 振り返り情報を設定
      improvementPoints: data.improvementPoints, // ★追加: 振り返り情報を設定
      futurePlans: data.futurePlans, // ★追加: 振り返り情報を設定
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /*
  void _showCompletionModal(Score score) {
    // 最終計算・保存処理（既存の notifier を利用）
    ref.read(currentSessionScoreProvider.notifier).recalc();
    final finalized = ref.read(currentSessionScoreProvider.notifier).finalize();
    if (finalized != null) {
      ref.read(scoreHistoryProvider.notifier).addScore(finalized);
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.topCenter,
          child: _AnimatedScoreModal(
            totalScore: finalized?.totalScore ?? 0.0,
            onConfirm: () {
              Navigator.of(context).pop();
              context.go('/Timersettings');
            },
          ),
        );
      },
    );
  }*/

  // ★データベース保存処理
  Future<void> _saveAndShowModal() async {
    final dao = ref.read(scoreDaoProvider);
    final isAggregated = _tabController.index == 0;
    final totalMinutes = _currentScore.concentrationScore.totalMinutes;
    final concentration = _currentScore.concentrationScore.concentrationLevel;

    // 1. タスクデータの計算と作成（TaskScoreDataに変換）
    final taskDataList = <TaskScoreData>[];

    for (var task in _currentScore.taskScores) {
      final isCompleted = task.achievePercent == -1;

      // ★変更: TaskScoreDataを作成
      taskDataList.add(
        TaskScoreData(
          originalTaskId: task.id,
          taskName: task.taskName,
          importance: task.importance,
          difficulty: task.difficulty,
          // ★保存値: 完了済みなら100として記録、それ以外は入力値
          achievePercent: isCompleted ? 100 : task.achievePercent,
          wasCompletedBefore: isCompleted,
        ),
      );

    }


    // タスクスコアの重み付きスコアを計算
    final taskWeightedScores = taskDataList
        .where(
          (t) {
        // 既に完了していたタスクはスコア計算に含めない
        if (t.wasCompletedBefore!) {
          return false;
        }
        // 今回作業したタスク（途中または完了）はすべて含める
        return true;
      },) // 完了済みは除外
        .map((t) => t.calculateWeightedScore(concentration))
        .toList();

    final taskWeightedMaxScores = taskDataList
        .where((t) => t.wasCompletedBefore == false)
        .map(
          (t) => t
          .copyWith(achievePercent: 100)
          .calculateWeightedScore(100),
    )
        .toList();


    final finalTotalScore = ScoreCalculator.calculateTotalScore(
      taskWeightedScores: taskWeightedScores,
      totalMinutes: focusMinutes,
      concentrationLevel: concentration,
    );

    final maxPossibleScore = ScoreCalculator.calculateTotalScore(
        taskWeightedScores: taskWeightedMaxScores,
        totalMinutes: totalMinutes,
        concentrationLevel: 100,
    );

    // 3. 親データの作成
    final scoreCompanion = ScoresTableCompanion.insert(
      startedAt: _currentScore.startedAt,
      endedAt: _currentScore.endedAt,
      totalMinutes: totalMinutes,
      concentrationLevel: concentration,
      goalId: _currentScore.goalId != null
          ? drift.Value(_currentScore.goalId)
          : const drift.Value.absent(),
      goalName: _currentScore.goalName != null
          ? drift.Value(_currentScore.goalName)
          : const drift.Value.absent(),
      evaluationMode: isAggregated ? 0 : 1,
      totalScore: finalTotalScore,
      goodPoints: _currentScore.goodPoints != null
          ? drift.Value(_currentScore.goodPoints)
          : const drift.Value.absent(),
      improvementPoints: _currentScore.improvementPoints != null
          ? drift.Value(_currentScore.improvementPoints)
          : const drift.Value.absent(),
      futurePlans: _currentScore.futurePlans != null
          ? drift.Value(_currentScore.futurePlans)
          : const drift.Value.absent(),
    );
    try {
      // 4. データベースへ保存（TaskScoreDataリストを渡す）
      await dao.createScoreWithTasks(scoreCompanion, taskDataList);

      // 5. 完了モーダル表示
      if (!mounted) return;
      _showResultModal(finalTotalScore, maxPossibleScore);
    } catch (e) {
      debugPrint('保存エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存エラー: $e')));
      }
    }
  }

  // ★追加: 設定外のタスクとしてスコア化（タスクなし計算）
  Future<void> _saveAsOtherTask() async {
    final dao = ref.read(scoreDaoProvider);
    final totalMinutes = _currentScore.concentrationScore.totalMinutes;
    final concentration = _currentScore.concentrationScore.concentrationLevel;

    // タスクなしで計算
    final finalTotalScore = ScoreCalculator.calculateTotalScore(
      taskWeightedScores: [],
      totalMinutes: totalMinutes,
      concentrationLevel: concentration,
    );

    final maxPossibleScore = ScoreCalculator.calculateTotalScore(
      taskWeightedScores: [],
      totalMinutes: totalMinutes,
      concentrationLevel: 100,
    );

    // スコアデータの作成（goalIdを外して記録）
    final scoreCompanion = ScoresTableCompanion.insert(
      startedAt: _currentScore.startedAt,
      endedAt: _currentScore.endedAt,
      totalMinutes: totalMinutes,
      concentrationLevel: concentration,
      goalName: const drift.Value("設定外タスク/タスクなし"),
      evaluationMode: 0,
      totalScore: finalTotalScore,
      goodPoints: _currentScore.goodPoints != null
          ? drift.Value(_currentScore.goodPoints)
          : const drift.Value.absent(),
      improvementPoints: _currentScore.improvementPoints != null
          ? drift.Value(_currentScore.improvementPoints)
          : const drift.Value.absent(),
      futurePlans: _currentScore.futurePlans != null
          ? drift.Value(_currentScore.futurePlans)
          : const drift.Value.absent(),
    );
    // 空のタスクリストとともに保存
    try {
      // 4. データベースへ保存
      await dao.createScoreWithTasks(scoreCompanion, []);

      // 5. 完了モーダル表示
      if (!mounted) return;
      _showResultModal(finalTotalScore, maxPossibleScore);
    } catch (e) {
      debugPrint('保存エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存エラー: $e')));
      }
    }
  }

  void _showResultModal(double finalScore, double maxPossibleScore) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black54, // 背景を暗く
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 背景をぼかす
          child: SafeArea(
            child:Material(
              type: MaterialType.transparency,
              child: Center(
                child: AnimatedScoreModal(
                  totalScore: finalScore,
                  maxPossibleScore: maxPossibleScore,
                  onConfirm: () {
                    Navigator.of(context).pop();
                    context.go('/Timersettings');
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(scale: anim1, child: child),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    final score = _currentScore;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 600; // タブレット・PC判定
    final isLandscape = screenWidth > screenHeight;

    return ConfirmBackWrapper(
      // 確認メッセージ表示（戻る操作時のみ）
      onConfirmPop: () => context.go('/Timersettings'),
      message: '今この画面から戻ると入力内容が失われます。よろしいですか？',
      child: Scaffold(
        body: SafeArea(
          child: isWideScreen || isLandscape
              ? _buildWideLayout(context, score, screenWidth)
              : _buildNarrowLayout(context, score),
        ),
      ),
    );
  }

  /// 縦画面・スマホ用レイアウト
  Widget _buildNarrowLayout(BuildContext context, Score score) {
    return Column(
      children: [
        Header(score: score),
        TabBar(
          controller: _tabController,
          labelColor: Colors.orange.shade800,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange.shade800,
          tabs: const [
            Tab(text: 'まとめて評価'),
            Tab(text: '一つずつ評価'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              AggregateTab(
                score: score,
                onAggregateChanged: (intVal) {
                  setState(() {
                    for (var t in _currentScore.taskScores) {
                      if (t.achievePercent != -1) {
                        t.achievePercent = intVal;
                      }
                    }
                  });
                },
                onSubmit: () async {
                  await _saveAndShowModal();
                },
                onSaveOther: _saveAsOtherTask,
              ),
              PerTaskTab(
                score: score,
                onTaskChanged: (index, intVal) {
                  setState(() {
                    if (_currentScore.taskScores[index].achievePercent != -1) {
                      _currentScore.taskScores[index].achievePercent = intVal;
                    }
                  });
                },
                onSubmit: () async {
                  await _saveAndShowModal();
                },
                onSaveOther: _saveAsOtherTask,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 横画面・PC用レイアウト（2カラム）
  Widget _buildWideLayout(
    BuildContext context,
    Score score,
    double screenWidth,
  ) {
    final maxWidth = 1200.0;
    final contentWidth = screenWidth > maxWidth ? maxWidth : screenWidth;

    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Header(score: score),
            const SizedBox(height: 16),
            // タブを横並びボタンに変更
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton(context, 'まとめて評価', 0, Colors.orange.shade800),
                const SizedBox(width: 16),
                _buildTabButton(context, '一つずつ評価', 1, Colors.orange.shade800),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  AggregateTab(
                    score: score,
                    onAggregateChanged: (intVal) {
                      setState(() {
                        for (var t in _currentScore.taskScores) {
                          if (t.achievePercent != -1) {
                            t.achievePercent = intVal;
                          }
                        }
                      });
                    },
                    onSubmit: () async {
                      await _saveAndShowModal();
                    },
                    onSaveOther: _saveAsOtherTask,
                  ),
                  PerTaskTab(
                    score: score,
                    onTaskChanged: (index, intVal) {
                      setState(() {
                        if (_currentScore.taskScores[index].achievePercent !=
                            -1) {
                          _currentScore.taskScores[index].achievePercent =
                              intVal;
                        }
                      });
                    },
                    onSubmit: () async {
                      await _saveAndShowModal();
                    },
                    onSaveOther: _saveAsOtherTask,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// タブボタン（横画面・PC用）
  Widget _buildTabButton(
    BuildContext context,
    String label,
    int index,
    Color activeColor,
  ) {
    final isActive = _tabController.index == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : Colors.grey.shade300,
        foregroundColor: isActive ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Header-----------
class Header extends StatelessWidget {
  final Score score;
  const Header({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '達成度を評価してください',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          if (score.goalName != null)
            Text(
              '目標: ${score.goalName}',
              style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
            ),
        ],
      ),
    );
  }
}

/// --- AggregateTab (状態保持) ---------------
class AggregateTab extends StatefulWidget {
  final Score score;
  final ValueChanged<int> onAggregateChanged;
  final VoidCallback onSubmit;
  final VoidCallback onSaveOther;

  const AggregateTab({
    super.key,
    required this.score,
    required this.onAggregateChanged,
    required this.onSubmit,
    required this.onSaveOther,
  });

  @override
  State<AggregateTab> createState() => _AggregateTabState();
}

class _AggregateTabState extends State<AggregateTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // rebuild を抑え、スクロール位置保持

  late double _localValue;

  List<TaskScore> get _notCompletedTasks {
    return widget.score.taskScores
        .where((t) => t.achievePercent != -1)
        .toList();
  }

  @override
  void initState() {
    super.initState();

    final notCompleted = _notCompletedTasks;
    _localValue = widget.score.taskScores.isEmpty
        ? 0.0
        : notCompleted.first.achievePercent.toDouble();
  }

  @override
  void didUpdateWidget(covariant AggregateTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部からの更新があれば反映
    final notCompleted = _notCompletedTasks;
    final newVal = widget.score.taskScores.isEmpty
        ? 0.0
        : notCompleted.first.achievePercent.toDouble();

    ///
    if (newVal != _localValue) _localValue = newVal;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final score = widget.score;
    final hasNotCompleted = widget.score.taskScores.any(
      (t) => t.achievePercent != -1,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (score.taskScores.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'タスクが設定されていません',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('集中度のみが評価されます', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else ...[
            ...score.taskScores.map((t) {
              final isCompleted = t.achievePercent == -1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // ★完了マーク
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                        if (isCompleted) const SizedBox(width: 8),

                        Text(
                          "・${t.taskName}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // ★完了済みの色変え
                            color: isCompleted ? Colors.grey : Colors.black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                    //Text("・${t.taskName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Divider(),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(color: Colors.black, thickness: 2),
            const SizedBox(height: 16),
            Text(
              '全タスク共通の達成度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
          const SizedBox(height: 12),

          if (hasNotCompleted)
            AchievementSlider(
              value: _localValue,
              onChanged: (v) {
                setState(() => _localValue = v);
                // parent は int を期待する想定なので toInt() を渡す
                widget.onAggregateChanged(v.toInt());
              },
            )
          else
            const Text(
              "全てのタスクが完了しています",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: widget.onSaveOther,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text('設定したタスク以外でのスコア化'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: widget.onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
            ),
            child: const Text('スコア化'),
          ),
        ],
      ),
    );
  }
}

/// --- PerTaskTab (状態保持) ----------------
class PerTaskTab extends ConsumerStatefulWidget {
  //StatefulWidget {
  final Score score;
  final void Function(int index, int value) onTaskChanged;
  final VoidCallback onSubmit;
  final VoidCallback onSaveOther;

  const PerTaskTab({
    super.key,
    required this.score,
    required this.onTaskChanged,
    required this.onSubmit,
    required this.onSaveOther,
  });

  @override
  ConsumerState<PerTaskTab> createState() => _PerTaskTabState();
}

class _PerTaskTabState extends ConsumerState<PerTaskTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late List<double> _localValues;

  @override
  void initState() {
    super.initState();
    _localValues = widget.score.taskScores
        .map((t) => t.achievePercent.toDouble())
        .toList();
  }

  @override
  void didUpdateWidget(covariant PerTaskTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newList = widget.score.taskScores
        .map((t) => t.achievePercent.toDouble())
        .toList();
    if (newList.length != _localValues.length) {
      _localValues = newList;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final score = widget.score;

    if (score.taskScores.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'タスクが設定されていません',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text('まとめて評価を使用してください', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...score.taskScores.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            final local = (index < _localValues.length)
                ? _localValues[index]
                : task.achievePercent.toDouble();
            final isCompleted = task.achievePercent == -1;
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'タスク ${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.taskName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '重要度: ${task.importance} | 難易度: ${task.difficulty}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    '達成度',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (isCompleted)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "完了済み (評価不要)",
                        style: TextStyle(color: Colors.green),
                      ),
                    )
                  else
                    AchievementSlider(
                      value: local,
                      onChanged: (v) {
                        // update local cache and notify parent
                        if (index < _localValues.length) {
                          _localValues[index] = v;
                        }
                        widget.onTaskChanged(index, v.toInt());
                        setState(() {}); // reflect numeric label
                      },
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: widget.onSaveOther,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text('設定したタスク以外でのスコア化'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: widget.onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
            ),
            child: const Text('スコア化'),
          ),
        ],
      ),
    );
  }
}

/// --- Animated Score Modal (結果確認) ---------------
class AnimatedScoreModal extends StatefulWidget {
  final double totalScore;
  final double maxPossibleScore;
  final VoidCallback onConfirm;

  const AnimatedScoreModal({
    super.key,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.onConfirm,
  });

  @override
  State<AnimatedScoreModal> createState() => AnimatedScoreModalState();
}

class AnimatedScoreModalState extends State<AnimatedScoreModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  late Animation<double> _scaleAnimation;

  // クラッカー用のコントローラー
  late ConfettiController _confettiCenter; // 75%以上の全方位用
  late ConfettiController _confettiLeft;   // 90%以上の左側用
  late ConfettiController _confettiRight;  // 90%以上の右側用

  bool _scoringComplete = false;

  @override
  void initState() {
    super.initState();

    // 各コントローラーの初期化
    _confettiCenter = ConfettiController(duration: const Duration(seconds: 2));
    _confettiLeft = ConfettiController(duration: const Duration(seconds: 2));
    _confettiRight = ConfettiController(duration: const Duration(seconds: 2));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );


    final scoreRatio = (widget.maxPossibleScore > 0)
        ? widget.totalScore / widget.maxPossibleScore
        : 0.0;

    double targetScore;
    if (scoreRatio >= 0.97) {
      // 満点以上の場合は、実際のスコアをそのまま目標値にする
      targetScore = widget.totalScore;
    } else {
      // 満点未満の場合は、目標スコアを90%に調整して「余白」を作る
      targetScore = widget.totalScore * 0.96;
    }


    _scoreAnimation = Tween<double>(begin: 0, end: targetScore).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward().then((_) {
      setState(() => _scoringComplete = true);
      HapticFeedback.mediumImpact();

      // 演出の分岐
      if (scoreRatio >= 0.9) {
        // 9割以上：中央左右から発射
        _confettiCenter.play();
        _confettiLeft.play();
        _confettiRight.play();
      } else if (scoreRatio >= 0.75) {
        // 75%以上：中央から全方位
        _confettiCenter.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiCenter.dispose();
    _confettiLeft.dispose();
    _confettiRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Container(
              // スマホでの表示崩れを防ぐためmaxWidthを設定し中央に収める
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)
                ],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '今回のスコア',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      // 円形プログレス
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: (_scoreAnimation.value / widget.maxPossibleScore).clamp(0.0, 1.0),
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.shade100,
                                color: Colors.orange.shade800,
                                strokeCap: StrokeCap.round,
                              ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _scoreAnimation.value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.orange.shade900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Text('pts', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (_scoringComplete)
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: widget.onConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text('記録を完了する', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )
                      else
                        const Text('採点中...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // 🎉 75%以上の中央全方位クラッカー
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiCenter,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.orange, Colors.yellow, Colors.pink, Colors.blue, Colors.green],
            numberOfParticles: 20,
            gravity: 0.2,
          ),
        ),

        // 🎉 90%以上の左側クラッカー (右斜め上へ発射)
        Align(
          alignment: Alignment.bottomLeft,
          child: ConfettiWidget(
            confettiController: _confettiLeft,
            blastDirection: -pi / 4, // 右斜め上
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.2,
            colors: const [Colors.orange, Colors.yellow, Colors.blue],
          ),
        ),

        // 🎉 90%以上の右側クラッカー (左斜め上へ発射)
        Align(
          alignment: Alignment.bottomRight,
          child: ConfettiWidget(
            confettiController: _confettiRight,
            blastDirection: -3 * pi / 4, // 左斜め上
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.2,
            colors: const [Colors.orange, Colors.yellow, Colors.blue],
          ),
        ),
      ],
    );
  }
}


/// --- AchievementSlider (単純で内部状態を持つ) -----------------
class AchievementSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const AchievementSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AchievementSlider> createState() => _AchievementSliderState();
}

class _AchievementSliderState extends State<AchievementSlider> {
  late double _v;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _v = widget.value;
    _controller = TextEditingController(text: _v.toInt().toString());
  }

  @override
  void didUpdateWidget(covariant AchievementSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _v) {
      _v = widget.value;
      _controller.text = _v.toInt().toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0%'),
            Text(
              '${_v.toInt()}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const Text('100%'),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange.shade800, // 進んだ部分（濃いオレンジ）
            inactiveTrackColor: Colors.orange.shade100, // 進んでない部分（薄いオレンジ）
            thumbColor: Colors.orange.shade800, // つまみ
            overlayColor: Colors.orange.shade200, // 押したときの波紋
          ),
          child: Slider(
            value: _v,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (nv) {
              setState(() => _v = nv);
              _controller.text = _v.toInt().toString();
              widget.onChanged(nv);
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('入力: '),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (txt) {
                  final v = int.tryParse(txt);
                  if (v != null && v >= 0 && v <= 100) {
                    setState(() => _v = v.toDouble());
                    widget.onChanged(_v);
                  }
                },
              ),
            ),
            const Text(' %'),
          ],
        ),
      ],
    );
  }
}
