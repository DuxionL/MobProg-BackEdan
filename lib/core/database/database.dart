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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        accountType TEXT,
 
        fromAccountId TEXT,
        fromAccountName TEXT,
        fromAccountBalance REAL,
        fromAccountType TEXT,
 
        toAccountId TEXT,
        toAccountName TEXT,
        toAccountBalance REAL,
        toAccountType TEXT,
 
        fee REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN accountType TEXT');
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN fromAccountType TEXT',
      );
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN toAccountType TEXT',
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
