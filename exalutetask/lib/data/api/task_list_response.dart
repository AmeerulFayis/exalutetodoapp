class TaskListResponse {
  final List<Task> tasks;
  final int? code;

  TaskListResponse({
    required this.tasks,
    this.code,
  });

  factory TaskListResponse.fromJson(dynamic json) {
    return TaskListResponse(
      tasks: (json as List)
          .map((e) => Task.fromJson(e))
          .toList(),
    );
  }
}

class Task {
  final int createdAt;
  final String title;
  final dynamic completed;
  final String id;
  final int syncStatus;

  Task({
    required this.createdAt,
    required this.title,
    required this.completed,
    required this.id,
    required this.syncStatus,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      createdAt: json["createdAt"],
      title: json["title"],
      completed: json["completed"],
      id: json["id"].toString(),
      syncStatus: 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "createdAt": createdAt,
      "title": title,
      "completed": completed.toString(),
      "id": id,
      "syncStatus": syncStatus,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      createdAt: map["createdAt"],
      title: map["title"],
      completed: map["completed"],
      id: map["id"].toString(),
      syncStatus: map["syncStatus"] ?? 1,
    );
  }
}