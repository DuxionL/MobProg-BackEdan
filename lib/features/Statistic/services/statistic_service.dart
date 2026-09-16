import 'package:flutter/material.dart';

import '../../../models/transaction.dart';
import '../models/statistic_item.dart';

class StatisticService {
  const StatisticService();

  List<StatisticItem> generateStatistics({
    required List<Transaction> transactions,
    required TransactionType transactionType,
  }) {
    final filtered = transactions
        .where((t) => t.type == transactionType)
        .toList();

    if (filtered.isEmpty) {
      return [];
    }

    final Map<String, double> totals = {};
    final Map<String, String> emojis = {};

    for (final transaction in filtered) {
      final category = transaction.category?.name ?? "Unknown";

      totals[category] = (totals[category] ?? 0) + transaction.amount;

      emojis[category] = transaction.category?.emoji ?? "❓";
    }

    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);

    final List<StatisticItem> result = [];

    totals.forEach((category, total) {
      result.add(
        StatisticItem(
          category: category,
          emoji: emojis[category]!,
          total: total,
          percentage: grandTotal == 0 ? 0 : (total / grandTotal) * 100,
          color: _getCategoryColor(category),
        ),
      );
    });

    result.sort((a, b) => b.total.compareTo(a.total));

    return result;
  }

  double calculateTotal(List<StatisticItem> items) {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "salary":
        return Colors.blue;

      case "bonus":
        return Colors.green;

      case "refund":
        return Colors.orange;

      case "interest":
        return Colors.purple;

      case "food":
        return Colors.red;

      case "transportation":
        return Colors.blueAccent;

      case "shopping":
        return Colors.pink;

      case "entertainment":
        return Colors.deepPurple;

      case "utilities":
        return Colors.amber;

      case "healthcare":
        return Colors.teal;

      case "education":
        return Colors.indigo;

      default:
        return Colors.grey;
    }
  }
}
