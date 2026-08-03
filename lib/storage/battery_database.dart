import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'battery_log_model.dart';

class BatteryDatabase {
  static final BatteryDatabase instance = BatteryDatabase._init();
  static Database? _database;

  BatteryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('battery_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: _onOpenDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE battery_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        batteryLevel INTEGER NOT NULL,
        batteryState TEXT NOT NULL,
        temperature REAL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_battery_logs_timestamp ON battery_logs(timestamp)',
    );
  }

  Future<void> _onOpenDB(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_battery_logs_timestamp ON battery_logs(timestamp)',
    );
  }

  Future<int> insertLog(BatteryLog log) async {
    final db = await instance.database;
    return await db.insert('battery_logs', log.toMap());
  }

  Future<List<BatteryLog>> getAllLogs() async {
    final db = await instance.database;
    final result = await db.query('battery_logs', orderBy: 'timestamp ASC');
    return result.map((json) => BatteryLog.fromMap(json)).toList();
  }

  Future<int> getLogCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM battery_logs');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
