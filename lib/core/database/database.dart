import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
 
class DatabaseSql {
  static final DatabaseSql _instance = DatabaseSql._internal();
  factory DatabaseSql() => _instance;
  DatabaseSql._internal();
 
  static Database? _database;
 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
 
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'money_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
 
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        dateTime TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        type TEXT NOT NULL,
 
        categoryName TEXT,
        categoryEmoji TEXT,
 
        accountId TEXT,
        accountName TEXT,
        accountBalance REAL,
 
        fromAccountId TEXT,
        fromAccountName TEXT,
        fromAccountBalance REAL,
 
        toAccountId TEXT,
        toAccountName TEXT,
        toAccountBalance REAL,
 
        fee REAL
      )
    ''');
  }
 
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}