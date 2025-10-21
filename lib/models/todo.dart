class Todo {
  final int id;
  final String todo;
  final String description;
  final bool completed;
  final int userId;

  Todo({
    required this.id,
    required this.todo,
    required this.description,
    required this.completed,
    required this.userId,
  });

  Todo copyWith({int? id, String? todo, bool? completed, int? userId}) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? 0,
      todo: json['title'] ?? '',
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
      userId: json['userId'] ?? 0,
    );
  }
}
