import '../database/database.dart';
import '../../models/transaction.dart';

class TransactionRepository {
  final DatabaseSql _dbHelper = DatabaseSql();

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.insert(
      'transactions',
      transaction.toMap(),
    );
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'dateTime DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
}