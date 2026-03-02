import 'package:flutter/material.dart';
import '../data/database/app_database.dart';

class TaskCard extends StatelessWidget {
  final TaskData task;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.task,
    this.onDelete,
    this.onEdit,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (task.isAiGenerated)
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.amber,
                        ),
                      if (task.isAiGenerated) const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.task,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? Colors.grey : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip('重要度: ${task.importance}', Colors.blue),
                      _buildInfoChip('難易度: ${task.difficulty}', Colors.pink),
                      _buildInfoChip(
                        '期限: ${task.limit.month}/${task.limit.day}まで',
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showActions) ...[
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: '編集',
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  tooltip: '削除',
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
