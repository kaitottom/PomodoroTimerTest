import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/goal_settings_provider.dart';
import '../../widgets/goal_form.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_form_modal.dart';
import '../../widgets/confirm_back_wrapper.dart';

class GoalEditPage extends ConsumerStatefulWidget {
  final int? goalId;
  final String? from;
  const GoalEditPage({super.key,this.goalId, this.from});

  @override
  ConsumerState<GoalEditPage> createState() => _GoalEditPageState();
}

class _GoalEditPageState extends ConsumerState<GoalEditPage> {

  final _goalFormKey = GlobalKey<GoalFormState>();
  final confirmKey =  GlobalKey<ConfirmBackWrapperState>();
  bool _isGoalExpanded = true;
  bool _isTasksExpanded = true;
  bool isSaving = false;
  //final from = GoRouterState.of(context).uri.queryParameters['from'];
  bool _isInitialized = false; // ★ データ初期化を一度だけ行うためのフラグ


  @override
  void initState() {
    super.initState();
    // ページ表示時に、DBから初期データを取得してtempGoalProviderにセットする
    // context を安全に使うためにフレーム後に初期化処理を実行する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ルートのクエリパラメータが優先ならこちらを使う:
      // final fromParam = GoRouterState.of(context).uri.queryParameters['from'];
      // ただし、widget.from が既に渡されているならそれを優先
      final fromParam = widget.from ?? GoRouterState.of(context).uri.queryParameters['from'];

      if (fromParam == 'main') {
        loadFromDatabase();
      } else {
        // from == 'review' 等は tempGoal をそのまま使うため DB読み込み不要
      }
    });
    // from=review の場合は tempGoal の値をそのまま使う
    //WidgetsBinding.instance.addPostFrameCallback((_) {
    // _initializeTempGoal();
    //});
  }

  void loadFromDatabase() async {
    final goalId = widget.goalId; // router から取得
    final goalDao = ref.read(goalDaoProvider);
    final taskDao = ref.read(taskDaoProvider);

    final goal = await goalDao.findGoalById(goalId!);
    final tasks = await taskDao.findTasksByGoalIdOnce(goalId);

    ref.read(tempGoalProvider.notifier).setInitialState(goal!, tasks);
    }

 /* void _initializeTempGoal() {
    // initState内なのでref.readを使う
    final notifier = ref.read(tempGoalProvider.notifier);
    if (widget.goalId == null) {
      // 新規作成の場合
      final newGoal = GoalSettingData(
        id: -1, // 仮のID
        goal: '',
        importance: 3,
        impact: 3,
        limit: DateTime.now().add(const Duration(days: 30)),
        isCompleted: false,
      );
      notifier.setInitialState(newGoal, []);
    } else {
      // 編集の場合
      // `goalsProvider`と`tasksForGoalProvider`からデータを取得する
      // (実際にはloadingやerrorを考慮する必要があるが、ここでは簡略化)
      final goalData = ref.read(goalsProvider).asData?.value.firstWhere((g) => g.id == widget.goalId);
      final tasksData = ref.read(tasksForGoalProvider(widget.goalId!)).asData?.value;

      if (goalData != null) {
        notifier.setInitialState(goalData, tasksData ?? []);
      }
    }
  }*/


  void _handleGoalSave(GoalSettingsTableCompanion companion) async {//GoalSettingData updatedGoal
    /*
    final db = ref.read(goalDaoProvider);
    //ref.read(tempGoalProvider.notifier).updateGoal(updatedGoal);

    // 1. Drift の Companion に変換
    final companion = GoalSettingsTableCompanion(
      id: Value(updatedGoal.id),
      goal: Value(updatedGoal.goal),
      importance: Value(updatedGoal.importance),
      impact: Value(updatedGoal.impact),
      limit: Value(updatedGoal.limit),
      isCompleted: Value(updatedGoal.isCompleted),
    );

    // 2. DB の更新実行
    await db.updateGoal(updatedGoal.id, companion);

    // 3. tempGoalProvider の状態も更新
    ref.read(tempGoalProvider.notifier).updateGoal(companion);*/

    // フォームの変更内容で、メモリ上の一時データを更新する
    ref.read(tempGoalProvider.notifier).updateGoalFields(companion);

  }


  void _showTaskFormModal({TaskData? editingTask}) {
    final tempGoal = ref.read(tempGoalProvider);
    if (tempGoal == null) return;

    showDialog(
      context: context,
      builder: (context) => TaskFormModal(
        initialTask: editingTask,
        currentTaskCount: tempGoal.tasks.length,
        maxTasks: 5,
        // ← TaskFormModal は Task を返す
        onSave: (TaskData uiTask) {
          final notifier = ref.read(tempGoalProvider.notifier);

          if (editingTask != null) {
            // --- 更新（TaskData → 更新された TaskData を再構築） ---
            final updatedTask = editingTask.copyWith(
              task: uiTask.task,
              importance: uiTask.importance,
              difficulty: uiTask.difficulty,
              limit: uiTask.limit,
              isCompleted: uiTask.isCompleted,
            );

            notifier.updateTask(updatedTask);
          } else {
          // --- 新規作成（TaskData を新規生成） ---
          final newTask = TaskData(
            id: -DateTime.now().millisecondsSinceEpoch, // 仮ID（DB保存時に生成される）
            goalId: tempGoal.goal.id,
            task: uiTask.task,
            importance: uiTask.importance,
            difficulty: uiTask.difficulty,
            limit: uiTask.limit,
            isCompleted: uiTask.isCompleted,
            isAiGenerated: false,
          );

          notifier.addTask(newTask);
        }
        },

      ),
    );
  }

// メモリ上のtempGoalからタスクを削除する
  void _deleteTask(int taskId) {
    // DBは操作せず、Notifierに変更を依頼するだけ
    ref.read(tempGoalProvider.notifier).deleteTask(taskId);
  }


  // 編集モーダルを開く
  void _editTask(TaskData taskToEdit) {
    // 編集したいTaskDataをモーダルに渡す
    _showTaskFormModal(editingTask: taskToEdit);
  }


  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // ビルド完了後に一度だけ実行する
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        //【編集モード】(mainページから来た場合)
        if (widget.goalId != null) {
          final goalDao = ref.read(goalDaoProvider);
          final taskDao = ref.read(taskDaoProvider);
          final goal = await goalDao.findGoalById(widget.goalId!);
          final tasks = await taskDao.findTasksByGoalIdOnce(widget.goalId!);
          if (goal != null) {
            ref.read(tempGoalProvider.notifier).setInitialState(goal, tasks);
          }
        }
        //【新規作成の手直し】(reviewページから来た場合)
        // この場合、tempGoalProviderは既にnewページで設定されているので、何もしない。

        // 初期化完了をマーク
        if (mounted) {
          setState(() { _isInitialized = true; });
        }

      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // 初期化が完了するまでローディング表示
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tempGoal = ref.watch(tempGoalProvider);
    if (tempGoal == null) {
      return const Scaffold(
        body: Center(child: Text('エラー: 編集中の目標が見つかりません。')),
      );
    }


    Future<void> completeChanges() async {
      final navigator = Navigator.of(context);
      final router = GoRouter.of(context);
      final messenger = ScaffoldMessenger.of(context);

      if (isSaving) return; // 二重押しを防止
      setState(() { isSaving = true; });


      try {
        _goalFormKey.currentState?.saveForm();
        // 現在の編集状態を取得
        final tempState = ref.read(tempGoalProvider);
      if (tempState == null) {
        throw Exception('編集中のデータが見つかりません');
      }


        // ★ ここで「レビューから来たか」を判定
        final fromReview = GoRouterState.of(context).uri.queryParameters['from'] == 'review';

        // ✅ レビュー編集の場合 → DB保存はしない
        if (fromReview) {
          // tempGoal を保持したままページだけ戻る
          if (!mounted) return;
          navigator.pop();
          messenger.showSnackBar(
            const SnackBar(content: Text('変更を一時保存しました')),
          );
          return; // ← DB 保存しない
        }


        // ✨ 通常保存処理（DBへ反映）
        // --- DBへの保存処理 (DAOを呼び出す) ---
        final goalDao = ref.read(goalDaoProvider);
        //final taskDao = ref.read(taskDaoProvider);


          //【更新の場合】
            final goalId = widget.goalId!;
            // 1. Goalを更新
            final goalCompanion = tempState.goal.toCompanion(false);
        //final goalCompanion = GoalSettingsTableCompanion(
        //  goal: Value(tempState.goal.goal),
        //  importance: Value(tempState.goal.importance),
        //  impact: Value(tempState.goal.impact),
        //  limit: Value(tempState.goal.limit),
        //  isCompleted: Value(tempState.goal.isCompleted),
        //);

            //final taskCompanions = tempState.tasks.map((t) => t.toCompanion(true)).toList();
        final taskCompanions = tempState.tasks.map((t) {
          return TasksTableCompanion.insert(
              goalId: goalId,
              task: t.task,
              importance: Value(t.importance),
              difficulty: Value(t.difficulty),
              limit: t.limit,
              isCompleted: Value(t.isCompleted),
              isAiGenerated: Value(t.isAiGenerated),
          );
        }).toList();

            //（AIフラグ継承も全部 DAO 側で処理）
            await goalDao.updateGoalWithTasks(goalId, goalCompanion, taskCompanions);

            // 成功したら編集状態をリセット
          ref.read(tempGoalProvider.notifier).reset();

          if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(content: Text('変更が適用されました')),
        );
        router.go('/goal');

      } catch (e) {
          if (mounted) messenger.showSnackBar(SnackBar(content: Text('エラー: $e')));
        } finally {
          if (mounted) setState(() { isSaving = false; });
        }
      }


    final isMobile = MediaQuery.of(context).size.width < 600;

    return ConfirmBackWrapper(
        key: confirmKey,
        onConfirmPop: ()  {
          if (widget.from == 'review') {
            context.pop();
          }
          ref.read(tempGoalProvider.notifier).reset();
          context.go('/goal');
        },
        message: '編集内容が失われるかもしれません。戻ってよろしいですか？',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('目標の編集'),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ... (LayoutBuilderとUI部分はあなたのコードを尊重し、大きな変更は加えません)
                // ★ 修正点 3: GoalFormにキーを設定し、onPressedに新しいロジックを適用します
                // (スマホ向けレイアウトの該当箇所)
                // GoalForm(key: _goalFormKey, ... )
                // ElevatedButton(onPressed: completeChanges, ... )
                // (PC向けレイアウトの該当箇所)
                // GoalForm(key: _goalFormKey, ... )
                // ElevatedButton(onPressed: completeChanges, ... )

                // 以下はあなたのコード構造を元にした完全なbuildメソッドです
                if (isMobile) {
                  // スマホ向け
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ExpansionTile(
                          initiallyExpanded: _isGoalExpanded,
                          onExpansionChanged: (expanded) => setState(() => _isGoalExpanded = expanded),
                          title: const Text('目標設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                              child: GoalForm( // ★ キーを設定
                                key: _goalFormKey,
                                initialGoal: tempGoal.goal,
                                onSave: _handleGoalSave,
                                submitButtonText: '目標を更新',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // ... (タスクセクションは変更なし)
                        ExpansionTile(
                          initiallyExpanded: _isTasksExpanded,
                          onExpansionChanged: (expanded) => setState(() => _isTasksExpanded = expanded),
                          title: Row(
                            children: [
                              const Text('タスク管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
                                child: Text('${tempGoal.tasks.length}/5', style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  if (tempGoal.tasks.isEmpty)
                                    const Padding(padding: EdgeInsets.all(20), child: Text('タスクがありません', style: TextStyle(color: Colors.grey)))
                                  else
                                    ...tempGoal.tasks.map((task) => TaskCard(task: task, onDelete: () => _deleteTask(task.id), onEdit: () => _editTask(task))),
                                  const SizedBox(height: 16),
                                  if (tempGoal.tasks.length < 5)
                                    ElevatedButton.icon(
                                      onPressed: () => _showTaskFormModal(),
                                      icon: const Icon(Icons.add),
                                      label: const Text('タスクを追加'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton( // ★ 新しいロジックを適用
                          onPressed: () async {
                            await completeChanges();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('変更完了', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                } else {
                  // タブレット・PC向け
                  return Center(
                    child: SizedBox(
                      width: 800,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ... (PC向けヘッダー部分は変更なし)
                            const SizedBox(height: 30),
                            const Text('目標変更', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            // ... (説明コンテナも変更なし)
                            const SizedBox(height: 50),
                            ExpansionTile(
                              initiallyExpanded: _isGoalExpanded,
                              onExpansionChanged: (expanded) => setState(() => _isGoalExpanded = expanded),
                              title: const Text('目標設定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                                  child: GoalForm( // ★ キーを設定
                                    key: _goalFormKey,
                                    initialGoal: tempGoal.goal,
                                    onSave: _handleGoalSave,
                                    submitButtonText: '目標を更新',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            // ... (タスクセクションは変更なし)
                            ExpansionTile(
                              initiallyExpanded: _isTasksExpanded,
                              onExpansionChanged: (expanded) => setState(() => _isTasksExpanded = expanded),
                              title: Row(
                                children: [
                                  const Text('タスク管理', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(16)),
                                    child: Text('${tempGoal.tasks.length}/5', style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      if (tempGoal.tasks.isEmpty)
                                        const Padding(padding: EdgeInsets.all(40), child: Text('タスクがありません', style: TextStyle(fontSize: 18, color: Colors.grey)))
                                      else
                                        ...tempGoal.tasks.map((task) => TaskCard(task: task, onDelete: () => _deleteTask(task.id), onEdit: () => _editTask(task))),
                                      const SizedBox(height: 24),
                                      if (tempGoal.tasks.length < 5)
                                        ElevatedButton.icon(
                                          onPressed: () => _showTaskFormModal(),
                                          icon: const Icon(Icons.add),
                                          label: const Text('タスクを追加'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              width: 300,
                              child: ElevatedButton( // ★ 新しいロジックを適用
                                onPressed: () async {
                                  await completeChanges();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('変更完了', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
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
