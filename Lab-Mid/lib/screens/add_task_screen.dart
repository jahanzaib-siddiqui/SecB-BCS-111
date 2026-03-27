import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../app_theme.dart';
import '../widgets/week_day_selector.dart';
import '../widgets/subtask_list_widget.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String _repeat = 'None';
  String _priority = 'Medium';
  int _color = 0xFF6366F1;
  List<String> _repeatDays = [];

  List<String> _subtasks = [];
  List<int> _subtaskStatus = [];

  // Multi-date: extra selected dates
  final Set<DateTime> _extraDates = {};

  bool _showWeekSelector = false;
  bool _multiDateMode = false;
  bool _isSaving = false;

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
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primaryColor,
              ),
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
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primaryColor,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickExtraDates() async {
    final result = await showDialog<Set<DateTime>>(
      context: context,
      builder: (_) => _MultiDatePickerDialog(
        initialDates: _extraDates,
        baseDate: _selectedDate,
      ),
    );
    if (result != null) setState(() => _extraDates
      ..clear()
      ..addAll(result));
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final timeStr = _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : '';

      // Build repeat string from selected days
      String repeatVal = _repeat;
      if (_showWeekSelector && _repeatDays.isNotEmpty) {
        repeatVal = _repeatDays.join(',');
      }

      // Build extra dates list
      final extraDatesList = _extraDates
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .toList();
      // Remove primary date from extras if present
      extraDatesList.remove(DateFormat('yyyy-MM-dd').format(_selectedDate));

      final task = Task(
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

      await Provider.of<TaskProvider>(context, listen: false).addTask(task);
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
        title: const Text('Add Task'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTask,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
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
            // ── Color Picker ──────────────────────────────────────────────
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
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────────────────
            _sectionLabel('Title *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
                prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryColor),
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            // ── Description ───────────────────────────────────────────────
            _sectionLabel('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add more details (optional)',
                prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.primaryColor),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // ── Priority ─────────────────────────────────────────────────
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
                      border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Date & Time ───────────────────────────────────────────────
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
                    value: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'No time',
                    color: AppTheme.accentColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Multi-date mode toggle
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
                    onPressed: _pickExtraDates,
                    icon: const Icon(Icons.date_range_rounded, size: 16),
                    label: Text(
                      _extraDates.isEmpty
                          ? 'Select Dates'
                          : '+${_extraDates.length} dates',
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Repeat ────────────────────────────────────────────────────
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

            // Week day selector
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

            // ── Subtasks ─────────────────────────────────────────────────
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

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveTask,
              child: _isSaving
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Task'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    );
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

// ── Multi-date picker dialog ──────────────────────────────────────────────────

class _MultiDatePickerDialog extends StatefulWidget {
  final Set<DateTime> initialDates;
  final DateTime baseDate;

  const _MultiDatePickerDialog(
      {required this.initialDates, required this.baseDate});

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
      if (_selected
          .any((d) => d.year == norm.year && d.month == norm.month && d.day == norm.day)) {
        _selected.removeWhere(
            (d) => d.year == norm.year && d.month == norm.month && d.day == norm.day);
      } else {
        _selected.add(norm);
      }
    });
  }

  void _selectWeek() {
    final monday = _focusedMonth
        .subtract(Duration(days: _focusedMonth.weekday - 1));
    setState(() {
      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        _selected.add(DateTime(day.year, day.month, day.day));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
        _focusedMonth.year, _focusedMonth.month);
    final firstDayOffset =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday - 1;

    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            }),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(_focusedMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            }),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                return SizedBox(
                  width: 36,
                  child: Text(d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500)),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            // Calendar grid
            Wrap(
              children: [
                ...List.generate(firstDayOffset,
                    (_) => const SizedBox(width: 36, height: 36)),
                ...List.generate(daysInMonth, (i) {
                  final date = DateTime(
                      _focusedMonth.year, _focusedMonth.month, i + 1);
                  final norm = DateTime(date.year, date.month, date.day);
                  final isSelected = _selected.any((d) =>
                      d.year == norm.year &&
                      d.month == norm.month &&
                      d.day == norm.day);
                  return GestureDetector(
                    onTap: () => _toggleDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
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
              Text(
                '${_selected.length} date(s) selected',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}