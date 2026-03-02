import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_timer/widgets/concentration_bottomsheet.dart';

// DBクラス
import '../data/database/daos/score_dao.dart'; // ScoreWithDetails
import '../providers/database_provider.dart'; // scoreDaoProvider
import '../utils/score_calculator.dart'; // 計算機
import '../models/task_score_data.dart'; // ★追加: TaskScoreData
import '../../widgets/confirm_back_wrapper.dart';

import '../pages/evaluation_page.dart';
import '../models/score.dart'; // Score, TaskScoreモデル

class DraftEvaluationPage extends ConsumerStatefulWidget {
  final ScoreWithDetails draft; // DBから取り出したドラフトデータ
  final ReflectionData reflectionData;
  //final int concentration; // 新しく入力された集中度

  const DraftEvaluationPage({
    super.key,
    required this.draft,
    required this.reflectionData,
    //required this.concentration,
  });

  @override
  ConsumerState<DraftEvaluationPage> createState() =>
      _DraftEvaluationPageState();
}

class _DraftEvaluationPageState extends ConsumerState<DraftEvaluationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 画面表示用のスコアモデル
  late Score _currentScore;
  late int restoredFocusMinutes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeScoreFromDraft();
  }

  /// DBのScoreWithDetailsからUI用のScoreモデルへ変換
  void _initializeScoreFromDraft() {
    final dbScore = widget.draft.score;
    final dbTasks = widget.draft.tasks;

    // ★修正: totalMinutesから直接集中時間を取得（ドラフト保存時にfocusMinutesが保存されている）
    restoredFocusMinutes = dbScore.totalMinutes;

    // DBのタスクデータをUI用モデルに変換（TaskScoreDataからTaskScoreへ）
    final taskScores = dbTasks.map((t) {
      return TaskScore(
        id: t.originalTaskId ?? 0, // 元のタスクID
        taskName: t.taskName,
        importance: t.importance,
        difficulty: t.difficulty,
        achievePercent: t.achievePercent, // 保存されている値を復元
        weightedScore: 0,
      );
    }).toList();

    _currentScore = Score(
      startedAt: dbScore.startedAt,
      endedAt: dbScore.endedAt,
      goalId: dbScore.goalId,
      goalName: dbScore.goalName,
      concentrationScore: ConcentrationScore(
        totalMinutes: restoredFocusMinutes, // 統計用の時間をそのまま使用  ----focus
        // 集中度は引数で渡された新しい値を使用（ドラフト保存時が0の場合があるため）
        concentrationLevel: widget.reflectionData.concentration,
      ),
      taskScores: taskScores,
      goodPoints: widget.reflectionData.goodPoints,
      improvementPoints: widget.reflectionData.improvementPoints,
      futurePlans: widget.reflectionData.futurePlans,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ★保存処理：既存レコードの更新
  Future<void> _updateAndFinalize() async {
    final dao = ref.read(scoreDaoProvider);
    final isAggregated = _tabController.index == 0;
    final concentrationLevel =
        _currentScore.concentrationScore.concentrationLevel;

    try {
      // 1. TaskScoreDataリストを作成
      final taskDataList = _currentScore.taskScores.map((task) {
        final isCompleted = task.achievePercent == -1;
        return TaskScoreData(
          originalTaskId: task.id,
          taskName: task.taskName,
          importance: task.importance,
          difficulty: task.difficulty,
          achievePercent: isCompleted ? 100 : task.achievePercent,
          wasCompletedBefore: isCompleted,
        );
      }).toList();


      // タスクスコアの重み付きスコアを計算
      final taskWeightedScores = taskDataList
          .where(
            (t) => t.wasCompletedBefore!=true,
      ) // 完了済みは除外
          .map((t) => t.calculateWeightedScore(concentrationLevel))
          .toList();

      final taskWeightedMaxScores = taskDataList
          .where((t) => t.wasCompletedBefore == false)
          .map(
            (t) => t
            .copyWith(achievePercent: 100)
            .calculateWeightedScore(100),
      )
          .toList();

      // 3. 全体の合計スコア計算
      final finalTotalScore = ScoreCalculator.calculateTotalScore(
        taskWeightedScores: taskWeightedScores,
        totalMinutes: restoredFocusMinutes,
        concentrationLevel: concentrationLevel,
      );

      final maxPossibleScore = ScoreCalculator.calculateTotalScore(
          taskWeightedScores: taskWeightedMaxScores,
          totalMinutes: restoredFocusMinutes,
          concentrationLevel: 100,
      );

      // 4. 親スコアの更新（ドラフト解除、タスクデータも更新）
      await dao.finalizeDraftScore(
        scoreId: widget.draft.score.id,
        concentration: concentrationLevel,
        totalScore: finalTotalScore,
        evaluationMode: isAggregated ? 0 : 1,
        focusMinutes: restoredFocusMinutes, // ★追加: 集中時間を明示的に渡す
        updatedTasks: taskDataList, // ★追加: タスクデータも更新
        goodPoints: _currentScore.goodPoints,
        improvementPoints: _currentScore.improvementPoints,
        futurePlans: _currentScore.futurePlans,
      );

      // 4. 完了モーダル表示
      if (!mounted) return;
      _showResultModal(finalTotalScore, maxPossibleScore);
    } catch (e) {
      debugPrint('更新エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新エラー: $e')));
      }
    }
  }

  Future<void> _finalizeWithOthers() async {
    final dao = ref.read(scoreDaoProvider);
    final concentrationLevel =
        _currentScore.concentrationScore.concentrationLevel;

    // 1. 全体の合計スコア計算
    final finalTotalScore = ScoreCalculator.calculateTotalScore(
      taskWeightedScores: [],
      totalMinutes: restoredFocusMinutes,
      concentrationLevel: concentrationLevel,
    );

    final maxPossibleScore = ScoreCalculator.calculateTotalScore(
      taskWeightedScores: [],
      totalMinutes: restoredFocusMinutes,
      concentrationLevel: 100,
    );

    try {
      await dao.finalizeDraftAsOther(
        scoreId: widget.draft.score.id,
        concentration: concentrationLevel,
        totalScore: finalTotalScore,
        focusMinutes: restoredFocusMinutes, // ★追加: 集中時間を明示的に渡す
        newGoalName: "設定外タスク/タスクなし",
        goodPoints: _currentScore.goodPoints,
        improvementPoints: _currentScore.improvementPoints,
        futurePlans: _currentScore.futurePlans,
      );

      // 4. 完了モーダル表示
      if (!mounted) return;
      _showResultModal(finalTotalScore, maxPossibleScore);
    } catch (e) {
      debugPrint('更新エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新エラー: $e')));
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
                    context.go('/stats');
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
      onConfirmPop: () => context.go('/stats'),
      message: '評価を中断して戻りますか？入力内容は破棄されます。',
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
                onSubmit: _updateAndFinalize,
                onSaveOther: _finalizeWithOthers,
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
                onSubmit: _updateAndFinalize,
                onSaveOther: _finalizeWithOthers,
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
                    onSubmit: _updateAndFinalize,
                    onSaveOther: _finalizeWithOthers,
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
                    onSubmit: _updateAndFinalize,
                    onSaveOther: _finalizeWithOthers,
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
