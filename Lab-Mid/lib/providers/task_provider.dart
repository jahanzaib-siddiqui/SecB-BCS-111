import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DBHelper db = DBHelper();

  bool _isDarkMode = false;
  String _searchQuery = '';
  String _filterPriority = 'All';

  bool get isDarkMode => _isDarkMode;
  String get searchQuery => _searchQuery;
  String get filterPriority => _filterPriority;
  List<Task> get allTasks => _tasks;

  TaskProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('_loadPreferences error: $e');
    }
  }

  // ── Fetch ────────────────────────────────────────────────────────────────────
  Future<void> fetchTasks() async {
    try {
      _tasks = await db.getTasks();
      _handleRepeatTasks();
    } catch (e) {
      debugPrint('fetchTasks error: $e');
    }
    notifyListeners();
  }

  // ── Add ──────────────────────────────────────────────────────────────────────
  Future<void> addTask(Task task) async {
    try {
      final id = await db.insert(task);
      // Fire-and-forget notification (never blocks task creation)
      NotificationService.notifyTaskAdded(task.title).catchError((e) {
        debugPrint('notification error in addTask: $e');
      });
      // Schedule due reminder if time is set
      if (task.time.isNotEmpty) {
        final taskWithId = task.copyWith(id: id);
        _scheduleTaskDueNotification(taskWithId);
      }
    } catch (e) {
      debugPrint('addTask DB error: $e');
    }
    // Always refresh the list
    await fetchTasks();
  }

  // ── Delete ───────────────────────────────────────────────────────────────────
  Future<void> deleteTask(int id) async {
    try {
      await db.delete(id);
      NotificationService.cancelNotification(id).catchError((_) {});
    } catch (e) {
      debugPrint('deleteTask error: $e');
    }
    await fetchTasks();
  }

  // ── Update ───────────────────────────────────────────────────────────────────
  Future<void> updateTask(Task task) async {
    try {
      await db.update(task);
    } catch (e) {
      debugPrint('updateTask error: $e');
    }
    await fetchTasks();
  }

  // ── Toggle Complete ──────────────────────────────────────────────────────────
  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: task.isCompleted == 1 ? 0 : 1);
    try {
      await db.update(updated);
      if (updated.isCompleted == 1) {
        NotificationService.notifyTaskCompleted(task.title).catchError((e) {
          debugPrint('notification error in toggleComplete: $e');
        });
      }
    } catch (e) {
      debugPrint('toggleComplete error: $e');
    }
    // Always refresh regardless of errors
    await fetchTasks();
  }

  // ── Update Subtask Status ────────────────────────────────────────────────────
  Future<void> updateSubtaskStatus(Task task, int index, bool done) async {
    final newStatus = List<int>.from(task.subtaskStatus);
    if (index >= newStatus.length) {
      while (newStatus.length <= index) newStatus.add(0);
    }
    newStatus[index] = done ? 1 : 0;
    final updated = task.copyWith(subtaskStatus: newStatus);
    try {
      await db.update(updated);
    } catch (e) {
      debugPrint('updateSubtaskStatus error: $e');
    }
    await fetchTasks();
  }

  // ── Search / Filter ──────────────────────────────────────────────────────────
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterPriority(String p) {
    _filterPriority = p;
    notifyListeners();
  }

  // ── Theme ────────────────────────────────────────────────────────────────────
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint('toggleTheme prefs error: $e');
    }
  }

  // ── Filtered Lists ───────────────────────────────────────────────────────────
  List<Task> get _filtered {
    var list = List<Task>.from(_tasks);
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_filterPriority != 'All') {
      list = list.where((t) => t.priority == _filterPriority).toList();
    }
    return list;
  }

  List<Task> getTodayTasks() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _filtered.where((t) {
      final inDate = t.date == today || t.extraDates.contains(today);
      return inDate && t.isCompleted == 0;
    }).toList();
  }

  List<Task> getUpcomingTasks() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _filtered.where((t) {
      return t.date.compareTo(today) > 0 && t.isCompleted == 0;
    }).toList();
  }

  List<Task> getCompletedTasks() {
    return _filtered.where((t) => t.isCompleted == 1).toList();
  }

  List<Task> getRepeatedTasks() {
    return _filtered.where((t) => t.repeat != 'None').toList();
  }

  // ── Statistics ───────────────────────────────────────────────────────────────
  Map<String, dynamic> getStatistics() {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.isCompleted == 1).length;
    final pending = _tasks.where((t) => t.isCompleted == 0).length;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayCount = _tasks
        .where((t) => t.date == today || t.extraDates.contains(today))
        .length;
    final highPriority =
        _tasks.where((t) => t.priority == 'High' && t.isCompleted == 0).length;
    final rate = total == 0 ? 0.0 : completed / total;
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'today': todayCount,
      'highPriority': highPriority,
      'completionRate': rate,
    };
  }

  // ── Repeat Handler ───────────────────────────────────────────────────────────
  void _handleRepeatTasks() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayWeekday = _weekdayName(DateTime.now().weekday);

    for (final task in _tasks) {
      if (task.repeat == 'Daily' && task.date != today) {
        task.date = today;
        task.isCompleted = 0;
        () async {
          try { await db.update(task); } catch (e) { debugPrint('repeat update: $e'); }
        }();
      } else if (task.repeat == 'Weekly' && task.date != today) {
        if (_weekdayMatches(task, todayWeekday)) {
          task.date = today;
          task.isCompleted = 0;
          () async {
            try { await db.update(task); } catch (e) { debugPrint('repeat update: $e'); }
          }();
        }
      }
    }
  }

  bool _weekdayMatches(Task task, String todayWeekday) {
    if (task.repeat.contains(',')) {
      return task.repeat.split(',').contains(todayWeekday);
    }
    return false;
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  void _scheduleTaskDueNotification(Task task) {
    if (task.time.isEmpty) return;
    try {
      final parts = task.time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dateParts = task.date.split('-');
      final dueDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour,
        minute,
      );
      final now = DateTime.now();
      if (dueDateTime.isAfter(now)) {
        NotificationService.scheduleTaskNotification(
            task.id ?? 0, task.title, dueDateTime);
      }
    } catch (e) {
      debugPrint('_scheduleTaskDueNotification error: $e');
    }
  }
}