import 'package:flutter/material.dart';
import '../models/task.dart';
import '../app_theme.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';

class SubtaskListWidget extends StatefulWidget {
  final List<String> subtasks;
  final List<int> subtaskStatus;
  final Task? task; // non-null when editing an existing task (live updates)
  final ValueChanged<List<String>>? onSubtasksChanged;
  final ValueChanged<List<int>>? onStatusChanged;

  const SubtaskListWidget({
    super.key,
    required this.subtasks,
    required this.subtaskStatus,
    this.task,
    this.onSubtasksChanged,
    this.onStatusChanged,
  });

  @override
  State<SubtaskListWidget> createState() => _SubtaskListWidgetState();
}

class _SubtaskListWidgetState extends State<SubtaskListWidget> {
  late List<String> _subtasks;
  late List<int> _status;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subtasks = List.from(widget.subtasks);
    _status = List.from(widget.subtaskStatus);
    // Pad status to match subtask count
    while (_status.length < _subtasks.length) {
      _status.add(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(text);
      _status.add(0);
      _controller.clear();
    });
    widget.onSubtasksChanged?.call(List.from(_subtasks));
    widget.onStatusChanged?.call(List.from(_status));
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      _status.removeAt(index);
    });
    widget.onSubtasksChanged?.call(List.from(_subtasks));
    widget.onStatusChanged?.call(List.from(_status));
  }

  void _toggleStatus(int index) {
    setState(() {
      _status[index] = _status[index] == 1 ? 0 : 1;
    });
    // If linked to live task, update DB
    if (widget.task != null) {
      Provider.of<TaskProvider>(context, listen: false)
          .updateSubtaskStatus(widget.task!, index, _status[index] == 1);
    }
    widget.onStatusChanged?.call(List.from(_status));
  }

  double get _progress {
    if (_subtasks.isEmpty) return 0;
    return _status.where((s) => s == 1).length / _subtasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + progress
        Row(
          children: [
            Text(
              'Subtasks',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
            ),
            const Spacer(),
            if (_subtasks.isNotEmpty)
              Text(
                '${_status.where((s) => s == 1).length}/${_subtasks.length}  ${(_progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
        if (_subtasks.isNotEmpty) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 8,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),

        // Subtask items
        ..._subtasks.asMap().entries.map((entry) {
          final i = entry.key;
          final done = i < _status.length && _status[i] == 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleStatus(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: done ? AppTheme.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: done ? AppTheme.primaryColor : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: done
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? Colors.grey : null,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeSubtask(i),
                  child: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }),

        // Add subtask input
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add a subtask...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _addSubtask(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addSubtask,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
