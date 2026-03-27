import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../app_theme.dart';
import '../widgets/subtask_list_widget.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    // Get fresh task from provider
    final liveTask = provider.allTasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskColor = Color(liveTask.color);
    final progress = liveTask.getProgress();
    final isCompleted = liveTask.isCompleted == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditTaskScreen(task: liveTask)),
              );
              provider.fetchTasks();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppTheme.errorColor),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await provider.deleteTask(liveTask.id!);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [taskColor, taskColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: taskColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        liveTask.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        liveTask.priority,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (liveTask.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    liveTask.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _infoBadge(Icons.calendar_today_rounded, liveTask.date),
                    if (liveTask.time.isNotEmpty)
                      _infoBadge(Icons.access_time_rounded, liveTask.time),
                    if (liveTask.repeat != 'None')
                      _infoBadge(Icons.repeat_rounded, liveTask.repeat),
                    if (liveTask.extraDates.isNotEmpty)
                      _infoBadge(Icons.date_range_rounded,
                          '+${liveTask.extraDates.length} more dates'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isCompleted ? AppTheme.successColor : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? 'Completed' : 'In Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isCompleted ? AppTheme.successColor : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        isCompleted
                            ? 'Great job finishing this task!'
                            : 'Tap to mark as complete',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isCompleted,
                  activeColor: AppTheme.successColor,
                  onChanged: (_) => provider.toggleComplete(liveTask),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress card (only if subtasks exist)
          if (liveTask.subtasks.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: taskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: taskColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(taskColor),
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${liveTask.subtaskStatus.where((s) => s == 1).length} of ${liveTask.subtasks.length} subtasks complete',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Subtask checklist
                  SubtaskListWidget(
                    subtasks: liveTask.subtasks,
                    subtaskStatus: liveTask.subtaskStatus,
                    task: liveTask,
                    onSubtasksChanged: null,
                    onStatusChanged: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Extra dates card
          if (liveTask.extraDates.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Scheduled Dates',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: liveTask.allDates().map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: taskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: taskColor.withOpacity(0.3)),
                      ),
                      child: Text(d,
                          style: TextStyle(
                              color: taskColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // No subtasks placeholder
          if (liveTask.subtasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.checklist_rounded, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('No subtasks yet',
                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Edit this task to add subtasks and track progress',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
