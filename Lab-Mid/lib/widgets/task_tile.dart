import 'package:flutter/material.dart';
import '../models/task.dart';
import '../app_theme.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.onComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskColor = Color(task.color);
    final progress = task.getProgress();
    final isCompleted = task.isCompleted == 1;

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap ?? onEdit,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: taskColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: taskColor.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Completion checkbox
                    GestureDetector(
                      onTap: onComplete,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted ? taskColor : Colors.transparent,
                          border: Border.all(
                            color: isCompleted ? taskColor : Colors.grey.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? Colors.grey
                              : (isDark ? Colors.white : const Color(0xFF1A1B2E)),
                        ),
                      ),
                    ),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.priorityColor(task.priority).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.priorityColor(task.priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit button
                    GestureDetector(
                      onTap: onEdit,
                      child: Icon(Icons.edit_outlined,
                          size: 18, color: Colors.grey.shade500),
                    ),
                  ],
                ),

                // Description
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Date/Time row
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        task.date,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                      if (task.time.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.access_time,
                            size: 12, color: taskColor),
                        const SizedBox(width: 4),
                        Text(
                          task.time,
                          style: TextStyle(
                              fontSize: 12,
                              color: taskColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                      if (task.repeat != 'None') ...[
                        const SizedBox(width: 10),
                        Icon(Icons.repeat, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          task.repeat,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ),

                // Subtask progress bar
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${task.subtaskStatus.where((s) => s == 1).length}/${task.subtasks.length} subtasks',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: taskColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isDark
                                ? Colors.white12
                                : Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(taskColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}