import 'package:flutter/foundation.dart' hide Category;
import 'package:money_manager/models/transaction.dart';

//hell in the form of code
class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<Account> accounts = List.of(Account.defaultAccounts);
  final List<Category> incomeCategories = List.of(
    Category.defaultIncomeCategories,
  );
  final List<Category> expenseCategories = List.of(
    Category.defaultExpenseCategories,
  );

  List<Transaction> get all => List.unmodifiable(_transactions);

  void addTransaction(Transaction t) {
    _transactions.add(t);
    _transactions.sort((a, b) {
      final dateComparison = b.dateTime.compareTo(a.dateTime);
      return dateComparison != 0
          ? dateComparison
          : (b.id ?? '').compareTo(a.id ?? '');
    });
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<Transaction> forMonth(DateTime month) {
    return _transactions
        .where(
          (t) =>
              t.dateTime.year == month.year && t.dateTime.month == month.month,
        )
        .toList();
  }

  Map<DateTime, List<Transaction>> groupedByDay(DateTime month) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (final t in forMonth(month)) {
      final day = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      grouped.putIfAbsent(day, () => []).add(t);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  double totalIncome(DateTime month) =>
      forMonth(month)
          .where((t) => t.type == TransactionType.income)
          .fold(0, (sum, t) => sum + t.amount);

  double totalExpense(DateTime month) =>
      forMonth(month)
          .where((t) => t.type == TransactionType.expense)
          .fold(0, (sum, t) => sum + t.amount);

  double netTotal(DateTime month) => totalIncome(month) - totalExpense(month);

  double dayIncome(DateTime day) => _transactions
      .where(
        (t) => _isSameDay(t.dateTime, day) && t.type == TransactionType.income,
      )
      .fold(0, (sum, t) => sum + t.amount);

  double dayExpense(DateTime day) => _transactions
      .where(
        (t) => _isSameDay(t.dateTime, day) && t.type == TransactionType.expense,
      )
      .fold(0, (sum, t) => sum + t.amount);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
