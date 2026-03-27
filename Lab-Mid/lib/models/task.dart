class Task {
  int? id;
  String title;
  String description;
  String date;       // Primary date (yyyy-MM-dd)
  String time;       // Due time (HH:mm), empty if not set
  int isCompleted;
  String repeat;     // "None", "Daily", "Weekly", or comma-separated weekdays "Mon,Tue,Wed..."
  String priority;   // "Low", "Medium", "High"
  int color;         // Color value (ARGB int)

  List<String> subtasks;
  List<int> subtaskStatus;

  // Additional dates for multi-date / whole week selection (yyyy-MM-dd,yyyy-MM-dd,...)
  List<String> extraDates;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time = '',
    this.isCompleted = 0,
    this.repeat = 'None',
    this.priority = 'Medium',
    this.color = 0xFF6366F1,
    this.subtasks = const [],
    this.subtaskStatus = const [],
    this.extraDates = const [],
  });

  /// 0.0 – 1.0 progress of subtasks
  double getProgress() {
    if (subtasks.isEmpty) return 0;
    int completed = subtaskStatus.where((s) => s == 1).length;
    return completed / subtasks.length;
  }

  /// All dates this task applies to (primary + extra)
  List<String> allDates() {
    final all = <String>{date};
    all.addAll(extraDates);
    return all.toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'isCompleted': isCompleted,
      'repeat': repeat,
      'priority': priority,
      'color': color,
      'subtasks': subtasks.join('|'),
      'subtaskStatus': subtaskStatus.join(','),
      'extraDates': extraDates.join(','),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      isCompleted: map['isCompleted'] ?? 0,
      repeat: map['repeat'] ?? 'None',
      priority: map['priority'] ?? 'Medium',
      color: map['color'] ?? 0xFF6366F1,
      subtasks: (map['subtasks'] != null && map['subtasks'] != '')
          ? (map['subtasks'] as String).split('|').where((s) => s.isNotEmpty).toList()
          : [],
      subtaskStatus: (map['subtaskStatus'] != null &&
              map['subtaskStatus'] is String &&
              map['subtaskStatus'] != '')
          ? (map['subtaskStatus'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => int.tryParse(s) ?? 0)
              .toList()
          : [],
      extraDates: (map['extraDates'] != null &&
              map['extraDates'] is String &&
              map['extraDates'] != '')
          ? (map['extraDates'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList()
          : [],
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? time,
    int? isCompleted,
    String? repeat,
    String? priority,
    int? color,
    List<String>? subtasks,
    List<int>? subtaskStatus,
    List<String>? extraDates,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      repeat: repeat ?? this.repeat,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      subtasks: subtasks ?? List.from(this.subtasks),
      subtaskStatus: subtaskStatus ?? List.from(this.subtaskStatus),
      extraDates: extraDates ?? List.from(this.extraDates),
    );
  }
}