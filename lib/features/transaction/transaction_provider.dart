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

  double totalIncomeByAccount(DateTime month, AccountType accountType) =>
      _incomeFor(forMonth(month), accountType);

  double totalExpenseByAccount(DateTime month, AccountType accountType) =>
      _expenseFor(forMonth(month), accountType);

  double netTotalByAccount(DateTime month, AccountType accountType) =>
      _netFor(forMonth(month), accountType);

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

  double dayIncomeByAccount(DateTime day, AccountType accountType) =>
      _incomeFor(_transactionsOnDay(day), accountType);

  double dayExpenseByAccount(DateTime day, AccountType accountType) =>
      _expenseFor(_transactionsOnDay(day), accountType);

  double dayNetTotalByAccount(DateTime day, AccountType accountType) =>
      _netFor(_transactionsOnDay(day), accountType);

  List<Transaction> _transactionsOnDay(DateTime day) =>
      _transactions.where((t) => _isSameDay(t.dateTime, day)).toList();

  double _incomeFor(List<Transaction> transactions, AccountType accountType) =>
      transactions
          .where(
            (t) =>
                t.type == TransactionType.income &&
                t.account?.type == accountType,
          )
          .fold(0, (sum, t) => sum + t.amount);

  double _expenseFor(List<Transaction> transactions, AccountType accountType) =>
      transactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.account?.type == accountType,
          )
          .fold(0, (sum, t) => sum + t.amount);

  double _netFor(List<Transaction> transactions, AccountType accountType) {
    var total =
        _incomeFor(transactions, accountType) -
        _expenseFor(transactions, accountType);

    for (final transaction in transactions) {
      if (transaction.type != TransactionType.transfer) continue;

      if (transaction.fromAccount?.type == accountType) {
        total -= transaction.amount + (transaction.fee ?? 0);
      }
      if (transaction.toAccount?.type == accountType) {
        total += transaction.amount;
      }
    }

    return total;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
