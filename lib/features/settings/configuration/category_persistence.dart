import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_manager/features/transaction/transaction_provider.dart';
import 'package:money_manager/models/transaction.dart';

class CategoryPersistence {
  static const String _incomeKey = 'income_categories';
  static const String _expenseKey = 'expense_categories';

  static Future<void> attach(TransactionProvider provider) async {
    final prefs = await SharedPreferences.getInstance();

    final income = _decode(prefs.getString(_incomeKey));
    final expense = _decode(prefs.getString(_expenseKey));

    if (income != null) {
      while (provider.incomeCategories.isNotEmpty) {
        provider.removeIncomeCategoryAt(0);
      }
      for (final c in income) {
        provider.addIncomeCategory(c);
      }
    }
    if (expense != null) {
      while (provider.expenseCategories.isNotEmpty) {
        provider.removeExpenseCategoryAt(0);
      }
      for (final c in expense) {
        provider.addExpenseCategory(c);
      }
    }

    provider.addListener(() {
      prefs.setString(_incomeKey, _encode(provider.incomeCategories));
      prefs.setString(_expenseKey, _encode(provider.expenseCategories));
    });
  }

  static String _encode(List<Category> list) {
    return jsonEncode(
      list
          .map(
            (c) => {
              'name': c.name,
              'emoji': c.emoji,
              'subcategories': c.subcategories,
            },
          )
          .toList(),
    );
  }

  static List<Category>? _decode(String? raw) {
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) {
      final map = e as Map<String, dynamic>;
      return Category(
        name: map['name'] as String,
        emoji: map['emoji'] as String,
        subcategories: List<String>.from(map['subcategories'] as List),
      );
    }).toList();
  }
}
