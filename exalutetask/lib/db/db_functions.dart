import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'model_class.dart';

class TaskLocalDb {

  // =========================
  // INSERT TASK (offline safe)
  // =========================
  Future<void> insertTask(LocalTask task) async {
    final db = await DatabaseHelper.database;

    await db.insert(
      "tasks",
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =========================
  // GET ALL TASKS
  // =========================
  Future<List<LocalTask>> getTasks() async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query("tasks", orderBy: "createdAt DESC");

    return maps.map((e) => LocalTask.fromMap(e)).toList();
  }

  // =========================
  // CLEAR TABLE (full refresh sync)
  // =========================
  Future<void> clearTasks() async {
    final db = await DatabaseHelper.database;
    await db.delete("tasks");
  }

  // =========================
  // UPDATE COMPLETED STATUS (OFFLINE EDIT)
  // =========================
  Future<void> updateTaskCompleted(String localId, bool completed) async {
    final db = await DatabaseHelper.database;

    await db.update(
      "tasks",
      {
        "completed": completed ? 1 : 0,
        "syncStatus": SyncStatus.offline, // mark dirty
      },
      where: "localId = ?",
      whereArgs: [localId],
    );
  }

  // =========================
  // UPDATE SYNC STATUS
  // =========================
  Future<void> updateSyncStatus(String localId, int status, {String? serverId}) async {
    final db = await DatabaseHelper.database;
    final Map<String, dynamic> values = {"syncStatus": status};
    if (serverId != null) {
      values["serverId"] = serverId;
    }
    await db.update(
      "tasks",
      values,
      where: "localId = ?",
      whereArgs: [localId],
    );
  }

  // =========================
  // MARK SYNC SUCCESS
  // =========================
  Future<void> markAsSynced({
    required String localId,
    required String serverId,
  }) async {
    final db = await DatabaseHelper.database;

    await db.update(
      "tasks",
      {
        "syncStatus": SyncStatus.synced,
        "serverId": serverId,
      },
      where: "localId = ?",
      whereArgs: [localId],
    );
  }

  // =========================
  // GET ONLY UNSYNCED TASKS (including failed ones)
  // =========================
  Future<List<LocalTask>> getPendingTasks() async {
    final db = await DatabaseHelper.database;

    final maps = await db.query(
      "tasks",
      where: "syncStatus = ? OR syncStatus = ?",
      whereArgs: [SyncStatus.offline, SyncStatus.syncFailed],
    );

    return maps.map((e) => LocalTask.fromMap(e)).toList();
  }

  // =========================
  // GET SINGLE TASK (important for update sync)
  // =========================
  Future<LocalTask?> getTaskById(String localId) async {
    final db = await DatabaseHelper.database;

    final maps = await db.query(
      "tasks",
      where: "localId = ?",
      whereArgs: [localId],
    );

    if (maps.isNotEmpty) {
      return LocalTask.fromMap(maps.first);
    }
    return null;
  }

  // UPSERT SERVER DATA (NO DUPLICATES FIX)
  Future<void> upsertFromServer(LocalTask task) async {
    final db = await DatabaseHelper.database;

    final existing = await db.query(
      "tasks",
      where: "serverId = ?",
      whereArgs: [task.serverId],
    );

    if (existing.isEmpty) {
      await db.insert("tasks", task.toMap());
    } else {
      // If it exists locally, only update if it was already synced or is the same data

      await db.update(
        "tasks",
        task.toMap(),
        where: "serverId = ?",
        whereArgs: [task.serverId],
      );
    }
  }
}
