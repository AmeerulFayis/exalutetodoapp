import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "tasks.db");

    return await openDatabase(
      path,
      version: 2,

      onCreate: (db, version) async {
        log("DATABASE CREATED");

        await db.execute('''
          CREATE TABLE tasks(
            localId TEXT PRIMARY KEY,
            serverId TEXT,
            title TEXT,
            completed INTEGER DEFAULT 0,
            createdAt INTEGER,
            syncStatus INTEGER DEFAULT 0
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        log("DB UPGRADED");

        await db.execute("DROP TABLE IF EXISTS tasks");

        await db.execute('''
          CREATE TABLE tasks(
            localId TEXT PRIMARY KEY,
            serverId TEXT,
            title TEXT,
            completed INTEGER DEFAULT 0,
            createdAt INTEGER,
            syncStatus INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<void> resetDb() async {
    final path = join(await getDatabasesPath(), "tasks.db");
    await deleteDatabase(path);
  }
}