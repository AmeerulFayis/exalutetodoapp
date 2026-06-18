class AddTaskResponse {
  final int createdAt;
  final String title;
  final bool completed;
  final String id;
  final int? code;

  AddTaskResponse({
    required this.createdAt,
    required this.title,
    required this.completed,
    required this.id,
    this.code,
  });

  factory AddTaskResponse.fromJson(Map<String, dynamic> json) {
    return AddTaskResponse(
      createdAt: json["createdAt"],
      title: json["title"],
      completed: json["completed"] is bool
          ? json["completed"]
          : json["completed"].toString().toLowerCase() == "true",
      id: json["id"].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "createdAt": createdAt,
      "title": title,
      "completed": completed,
      "id": id,
    };
  }
}