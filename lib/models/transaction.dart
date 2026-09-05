import 'package:flutter/material.dart';

enum TransactionType { income, expense, transfer }

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}

class Category {
  //copas dari si moneymanager oren pake emoji lmao
  final String name;
  final String emoji;

  Category({required this.name, required this.emoji});

  static final List<Category> defaultIncomeCategories = [
    Category(name: 'Salary', emoji: '💰'),
    Category(name: 'Bonus', emoji: '🎁'),
    Category(name: 'Refund', emoji: '💵'),
    Category(name: 'Interest', emoji: '📈'),
    Category(name: 'Other Income', emoji: '➕'),
  ];

  static final List<Category> defaultExpenseCategories = [
    Category(name: 'Food', emoji: '🍔'),
    Category(name: 'Transportation', emoji: '🚗'),
    Category(name: 'Utilities', emoji: '💡'),
    Category(name: 'Entertainment', emoji: '🎬'),
    Category(name: 'Shopping', emoji: '🛍️'),
    Category(name: 'Healthcare', emoji: '⚕️'),
    Category(name: 'Education', emoji: '📚'),
    Category(name: 'Other Expense', emoji: '➖'),
  ];
}

class Account {
  final String id;
  final String name;
  final double balance;

  Account({required this.id, required this.name, required this.balance});

  static final List<Account> defaultAccounts = [
    Account(id: '1', name: 'Cash', balance: 0),
    Account(id: '2', name: 'Bank Account', balance: 0),
    Account(id: '3', name: 'Credit Card', balance: 0),
  ];
}

class Transaction {
  final String? id;
  final DateTime dateTime;
  final double amount;
  final String? note;
  final TransactionType type;

  final Category? category;
  final Account? account;

  final Account? fromAccount;
  final Account? toAccount;
  final double? fee;

  Transaction({
    this.id,
    required this.dateTime,
    required this.amount,
    this.note,
    required this.type,
    this.category,
    this.account,
    this.fromAccount,
    this.toAccount,
    this.fee,
  });

  Color get color {
    if (type == TransactionType.income) return Colors.blue;
    if (type == TransactionType.expense) return Colors.red;
    return Colors.purple;
  }
}
