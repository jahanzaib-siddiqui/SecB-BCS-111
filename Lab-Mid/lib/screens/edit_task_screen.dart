import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../app_theme.dart';
import '../widgets/week_day_selector.dart';
import '../widgets/subtask_list_widget.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late String _repeat;
  late String _priority;
  late int _color;
  List<String> _repeatDays = [];
  bool _showWeekSelector = false;

  late List<String> _subtasks;
  late List<int> _subtaskStatus;

  Set<DateTime> _extraDates = {};
  bool _multiDateMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t.title);
    _descCtrl = TextEditingController(text: t.description);
    _selectedDate = DateTime.tryParse(t.date) ?? DateTime.now();
    _repeat = t.repeat;
    _priority = t.priority;
    _color = t.color;
    _subtasks = List.from(t.subtasks);
    _subtaskStatus = List.from(t.subtaskStatus);

    // Parse time
    if (t.time.isNotEmpty) {
      final parts = t.time.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    // Parse extra dates
    _extraDates = t.extraDates
        .map((d) => DateTime.tryParse(d))
        .where((d) => d != null)
        .map((d) => d!)
        .toSet();
    _multiDateMode = _extraDates.isNotEmpty;

    // Parse repeat days
    if (t.repeat.contains(',') || (t.repeat.length == 3 && t.repeat != 'None')) {
      _repeatDays = t.repeat.split(',');
      _showWeekSelector = true;
      _repeat = 'Custom Days';
    } else {
      _showWeekSelector = t.repeat == 'Weekly';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final timeStr = _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : '';

      String repeatVal = _repeat;
      if (_showWeekSelector && _repeatDays.isNotEmpty) {
        repeatVal = _repeatDays.join(',');
      }

      final extraDatesList = _extraDates
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .where((d) => d != DateFormat('yyyy-MM-dd').format(_selectedDate))
          .toList();

      final updated = widget.task.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        time: timeStr,
        repeat: repeatVal,
        priority: _priority,
        color: _color,
        subtasks: List.from(_subtasks),
        subtaskStatus: List.from(_subtaskStatus),
        extraDates: extraDatesList,
      );

      await Provider.of<TaskProvider>(context, listen: false).updateTask(updated);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('_saveTask error: $e');
      if (mounted) setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTask,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Update',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                        fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Color Picker
            _sectionLabel('Task Color'),
            const SizedBox(height: 8),
            Row(
              children: AppTheme.taskColors.map((c) {
                final selected = _color == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: selected ? 34 : 28,
                    height: selected ? 34 : 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: selected ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : null,
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _sectionLabel('Title *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null,
              decoration: const InputDecoration(
                hintText: 'Task title',
                prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryColor),
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            _sectionLabel('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Details (optional)',
                prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.primaryColor),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // Priority
            _sectionLabel('Priority'),
            const SizedBox(height: 8),
            Row(
              children: ['Low', 'Medium', 'High'].map((p) {
                final isSelected = _priority == p;
                final color = AppTheme.priorityColor(p);
                return GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
                    ),
                    child: Text(p,
                        style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Date & Time
            _sectionLabel('Date & Time'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: _infoBox(
                      icon: Icons.calendar_today_rounded,
                      value: DateFormat('EEE, MMM d y').format(_selectedDate),
                      color: AppTheme.primaryColor,
                      isDark: isDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _pickTime,
                  child: _infoBox(
                    icon: Icons.access_time_rounded,
                    value: _selectedTime != null ? _selectedTime!.format(context) : 'No time',
                    color: AppTheme.accentColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Switch.adaptive(
                  value: _multiDateMode,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) => setState(() => _multiDateMode = v),
                ),
                const SizedBox(width: 8),
                const Text('Multiple Dates', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_multiDateMode)
                  TextButton.icon(
                    onPressed: () async {
                      final result = await showDialog<Set<DateTime>>(
                        context: context,
                        builder: (_) => _MultiDatePickerDialog(
                            initialDates: _extraDates, baseDate: _selectedDate),
                      );
                      if (result != null) setState(() => _extraDates = result);
                    },
                    icon: const Icon(Icons.date_range_rounded, size: 16),
                    label: Text(_extraDates.isEmpty ? 'Select Dates' : '+${_extraDates.length} dates'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Repeat
            _sectionLabel('Repeat'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _repeat,
                  isExpanded: true,
                  items: ['None', 'Daily', 'Weekly', 'Custom Days']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _repeat = val!;
                      _showWeekSelector = val == 'Weekly' || val == 'Custom Days';
                    });
                  },
                ),
              ),
            ),
            if (_showWeekSelector) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: WeekDaySelector(
                  selectedDays: _repeatDays,
                  onChanged: (days) => setState(() => _repeatDays = days),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Subtasks
            _sectionLabel('Subtasks'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: SubtaskListWidget(
                subtasks: _subtasks,
                subtaskStatus: _subtaskStatus,
                onSubtasksChanged: (s) => setState(() => _subtasks = s),
                onStatusChanged: (s) => setState(() => _subtaskStatus = s),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSaving ? null : _saveTask,
              child: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Update Task'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5));
  }

  Widget _infoBox(
      {required IconData icon,
      required String value,
      required Color color,
      required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── Reuse multi-date dialog ────────────────────────────────────────────────────

class _MultiDatePickerDialog extends StatefulWidget {
  final Set<DateTime> initialDates;
  final DateTime baseDate;
  const _MultiDatePickerDialog({required this.initialDates, required this.baseDate});

  @override
  State<_MultiDatePickerDialog> createState() => _MultiDatePickerDialogState();
}

class _MultiDatePickerDialogState extends State<_MultiDatePickerDialog> {
  late Set<DateTime> _selected;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialDates);
    _focusedMonth = widget.baseDate;
  }

  void _toggleDate(DateTime date) {
    setState(() {
      final norm = DateTime(date.year, date.month, date.day);
      if (_selected.any((d) => d.year == norm.year && d.month == norm.month && d.day == norm.day)) {
        _selected.removeWhere((d) => d.year == norm.year && d.month == norm.month && d.day == norm.day);
      } else {
        _selected.add(norm);
      }
    });
  }

  void _selectWeek() {
    final monday = _focusedMonth.subtract(Duration(days: _focusedMonth.weekday - 1));
    setState(() {
      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        _selected.add(DateTime(day.year, day.month, day.day));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOffset = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday - 1;

    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
          ),
          Expanded(
            child: Text(DateFormat('MMMM yyyy').format(_focusedMonth),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => SizedBox(
                    width: 36,
                    child: Text(d, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
                  )).toList(),
            ),
            const SizedBox(height: 4),
            Wrap(
              children: [
                ...List.generate(firstDayOffset, (_) => const SizedBox(width: 36, height: 36)),
                ...List.generate(daysInMonth, (i) {
                  final date = DateTime(_focusedMonth.year, _focusedMonth.month, i + 1);
                  final norm = DateTime(date.year, date.month, date.day);
                  final isSelected = _selected.any((d) => d.year == norm.year && d.month == norm.month && d.day == norm.day);
                  return GestureDetector(
                    onTap: () => _toggleDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36, height: 36,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : null)),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _selectWeek,
              icon: const Icon(Icons.calendar_view_week_rounded, size: 16),
              label: const Text('Select Whole Week'),
            ),
            if (_selected.isNotEmpty)
              Text('${_selected.length} date(s) selected',
                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, _selected), child: const Text('Apply')),
      ],
    );
  }
}