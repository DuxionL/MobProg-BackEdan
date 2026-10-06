import 'package:money_manager/models/transaction.dart';

import '../settings/accounts/account_store.dart';

class AssetCalculator {
  AssetCalculator._();

  static String? resolveItemId(String? accountName, Set<String> ids) {
    final name = (accountName ?? '').toLowerCase().trim();
    if (name.isEmpty) return null;

    for (final item in AccountStore.visibleItems) {
      if (item.name.toLowerCase().trim() == name) return item.id;
    }

    String? fallback;
    if (name.contains('cash')) {
      fallback = 'a_cash';
    } else if (name.contains('bank') || name.contains('account')) {
      fallback = 'a_accounts';
    } else if (name.contains('card')) {
      fallback = 'a_card';
    }
    return (fallback != null && ids.contains(fallback)) ? fallback : null;
  }

  static Map<String, double> balances(
    List<Transaction> transactions, {
    DateTime? before,
  }) {
    final balances = <String, double>{
      for (final item in AccountStore.visibleItems) item.id: 0.0,
    };
    final ids = balances.keys.toSet();

    void add(String? accountName, double value) {
      final id = resolveItemId(accountName, ids);
      if (id != null) balances[id] = balances[id]! + value;
    }

    for (final t in transactions) {
      if (before != null && !t.dateTime.isBefore(before)) continue;

      switch (t.type) {
        case TransactionType.income:
          add(t.account?.name, t.amount);
          break;
        case TransactionType.expense:
          add(t.account?.name, -t.amount);
          break;
        case TransactionType.transfer:
          add(t.fromAccount?.name, -(t.amount + (t.fee ?? 0)));
          add(t.toAccount?.name, t.amount);
          break;
      }
    }

    return balances;
  }
}