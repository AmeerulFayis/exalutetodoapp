class SyncStatus {
  static const int offline = 0;
  static const int syncing = 1;
  static const int synced = 2;
  static const int syncFailed = 3;
}

class LocalTask {
  final String localId;
  final String? serverId;
  final String title;
  final bool completed;
  final int createdAt;
  final int syncStatus;

  LocalTask({
    required this.localId,
    this.serverId,
    required this.title,
    required this.completed,
    required this.createdAt,
    this.syncStatus = SyncStatus.offline,
  });

  factory LocalTask.fromMap(Map<String, dynamic> map) {
    return LocalTask(
      localId: map['localId'],
      serverId: map['serverId'],
      title: map['title'],
      completed: map['completed'] == 1,
      createdAt: map['createdAt'],
      syncStatus: map['syncStatus'] ?? SyncStatus.offline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'serverId': serverId,
      'title': title,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt,
      'syncStatus': syncStatus,
    };
  }

  LocalTask copyWith({
    String? localId,
    String? serverId,
    String? title,
    bool? completed,
    int? createdAt,
    int? syncStatus,
  }) {
    return LocalTask(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
