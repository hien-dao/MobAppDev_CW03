class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final List<Task> subtasks;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.subtasks = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    List<Task>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((task) => task.toMap()).toList(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'],
      createdAt: DateTime.parse(map['createdAt']),
      subtasks: List<Task>.from(
        (map['subtasks'] as List).map((taskMap) => Task.fromMap(taskMap)),
      ),
    );
  }
}