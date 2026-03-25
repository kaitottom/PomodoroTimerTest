import 'package:flutter/material.dart';
import '../data/database/app_database.dart';

class TaskFormModal extends StatefulWidget {
  final TaskData? initialTask;
  final ValueChanged<TaskData> onSave;  // ← TaskData に統一
  //final Function(Task) onSave;
  final int maxTasks;
  final int currentTaskCount;

  const TaskFormModal({
    super.key,
    this.initialTask,
    required this.onSave,
    this.maxTasks = 5,
    this.currentTaskCount = 0,
  });

  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  final TextEditingController _taskController = TextEditingController();
  String _task = '';
  int _importance = 3;
  int _difficulty = 3;
  DateTime _limit = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    if (widget.initialTask != null) {
      _task = widget.initialTask!.task;
      _importance = widget.initialTask!.importance;
      _difficulty = widget.initialTask!.difficulty;
      _limit = widget.initialTask!.limit;
      _taskController.text = _task;
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_task.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タスクを入力してください')));
      return;
    }

    if (widget.currentTaskCount >= widget.maxTasks &&
        widget.initialTask == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('タスクは最大${widget.maxTasks}個までです')));
      return;
    }

    final task = TaskData(
      id: widget.initialTask?.id ?? -DateTime.now().millisecondsSinceEpoch,
      goalId: widget.initialTask?.goalId ?? 0,   // goalId は保存時に上書きされる
      task: _task.trim(),
      importance: _importance,
      difficulty: _difficulty,
      limit: _limit,
      isCompleted: widget.initialTask?.isCompleted ?? false,
      isAiGenerated: widget.initialTask?.isAiGenerated ?? false,///
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // ★ 1. ダイアログの角を丸くし、全体のバランスを調整
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        // ★ 2. 最大高さを制限し、画面突き抜けを防止
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        // ★ 3. 全体をスクロール可能にしてキーボード回避
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialTask != null ? 'タスクを編集' : 'タスクを追加',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('タスク：', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // ★ 4. TextField の視認性改善
              TextField(
                controller: _taskController,
                // 長文でも見やすく、改行を許可
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '例：英検2級の単語帳を20ページ進める',
                  alignLabelWithHint: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _task = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // --- スライダーと日付選択（既存通り） ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('重要度：'), Text('$_importance')],
              ),
              Slider(
                value: _importance.toDouble(),
                min: 1, max: 5, divisions: 4,
                label: '$_importance',
                onChanged: (value) => setState(() => _importance = value.round()),
                activeColor: Colors.lightBlue,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('難易度：'), Text('$_difficulty')],
              ),
              Slider(
                value: _difficulty.toDouble(),
                min: 1, max: 5, divisions: 4,
                label: '$_difficulty',
                onChanged: (value) => setState(() => _difficulty = value.round()),
                activeColor: Colors.pink,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('期限：'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _limit,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _limit = picked);
                    },
                    child: Text('${_limit.year}/${_limit.month}/${_limit.day}'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ★ 5. ボタンエリアの余白確保
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.initialTask != null ? '更新' : '追加',
                      ),
                    ),
                  ),
                ],
              ),
              // ★ 6. キーボード表示時にスクロールを底上げするための余白
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
  /*
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialTask != null ? 'タスクを編集' : 'タスクを追加',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('タスク：'),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'タスクを入力',
              ),
              onChanged: (value) {
                setState(() {
                  _task = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('重要度：'), Text('$_importance')],
            ),
            Slider(
              value: _importance.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_importance',
              onChanged: (value) {
                setState(() {
                  _importance = value.round();
                });
              },
              thumbColor: Colors.blue,
              activeColor: Colors.lightBlue,
              inactiveColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('難易度：'), Text('$_difficulty')],
            ),
            Slider(
              value: _difficulty.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_difficulty',
              onChanged: (value) {
                setState(() {
                  _difficulty = value.round();
                });
              },
              thumbColor: Colors.pinkAccent,
              activeColor: Colors.pink,
              inactiveColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('期限：'),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _limit,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _limit = picked;
                      });
                    }
                  },
                  child: Text('${_limit.year}/${_limit.month}/${_limit.day}'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.initialTask != null ? '更新' : '追加',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

   */
}
