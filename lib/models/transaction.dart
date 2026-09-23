import 'package:flutter/material.dart';

enum TransactionType { income, expense, transfer }

enum AccountType { cash, bank, card }

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
  final List<String> subcategories;

  Category({
    required this.name,
    required this.emoji,
    List<String>? subcategories,
  }) : subcategories = subcategories ?? const [];
  Category copyWith({
    String? name,
    String? emoji,
    List<String>? subcategories,
  }) {
    return Category(
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  static final List<Category> defaultIncomeCategories = [
    Category(name: 'Allowance', emoji: '🤑'),
    Category(name: 'Salary', emoji: '💰'),
    Category(name: 'Petty cash', emoji: '💵'),
    Category(name: 'Bonus', emoji: '🏅'),
    Category(name: 'Other', emoji: ''),
  ];

  static final List<Category> defaultExpenseCategories = [
    Category(
      name: 'Food',
      emoji: '🍜',
      subcategories: ['Lunch', 'Dinner', 'Eating out', 'Beverages'],
    ),
    Category(
      name: 'Social Life',
      emoji: '🧑‍🤝‍🧑',
      subcategories: ['Friend', 'Fellowship', 'Alumni', 'Dues'],
    ),
    Category(name: 'Pets', emoji: '🐶'),
    Category(
      name: 'Transport',
      emoji: '🚖',
      subcategories: ['Bus', 'Subway', 'Taxi', 'Car'],
    ),
    Category(
      name: 'Culture',
      emoji: '🖼️',
      subcategories: ['Books', 'Movie', 'Music', 'Apps'],
    ),
    Category(
      name: 'Household',
      emoji: '🪑',
      subcategories: [
        'Appliances',
        'Furniture',
        'Kitchen',
        'Toiletries',
        'Chandlery',
      ],
    ),
    Category(
      name: 'Apparel',
      emoji: '🧥',
      subcategories: ['Clothing', 'Fashion', 'Shoes', 'Laundry'],
    ),
    Category(
      name: 'Beauty',
      emoji: '💄',
      subcategories: ['Cosmetics', 'Makeup', 'Accessories', 'Beauty'],
    ),
    Category(
      name: 'Health',
      emoji: '🧘',
      subcategories: ['Health', 'Yoga', 'Hospital', 'Medicine'],
    ),
    Category(
      name: 'Education',
      emoji: '📙',
      subcategories: ['Schooling', 'Textbooks', 'School supplies', 'Academy'],
    ),
    Category(name: 'Gift', emoji: '🎁'),
    Category(name: 'Other', emoji: ''),
  ];
}

class Account {
  final String id;
  final String name;
  final double balance;
  final AccountType type;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  static final List<Account> defaultAccounts = [
    Account(id: '1', name: 'Cash', balance: 0, type: AccountType.cash),
    Account(id: '2', name: 'Bank Account', balance: 0, type: AccountType.bank),
    Account(id: '3', name: 'Credit Card', balance: 0, type: AccountType.card),
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

  //warnain transaksi, masukan biru, keluaran merah, transfer ungu, tergantung selera lh
  Color get color {
    if (type == TransactionType.income) return Colors.blue;
    if (type == TransactionType.expense) return Colors.red;
    return Colors.purple;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'amount': amount,
      'note': note,
      'type': type.name,

      'categoryName': category?.name,
      'categoryEmoji': category?.emoji,

      'accountId': account?.id,
      'accountName': account?.name,
      'accountBalance': account?.balance,
      'accountType': account?.type.name,

      'fromAccountId': fromAccount?.id,
      'fromAccountName': fromAccount?.name,
      'fromAccountBalance': fromAccount?.balance,
      'fromAccountType': fromAccount?.type.name,

      'toAccountId': toAccount?.id,
      'toAccountName': toAccount?.name,
      'toAccountBalance': toAccount?.balance,
      'toAccountType': toAccount?.type.name,

      'fee': fee,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String?,
      dateTime: DateTime.parse(map['dateTime'] as String),
      amount: (map['amount'] as num).toDouble(), // CHANGED
      note: map['note'] as String?,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      category: map['categoryName'] != null
          ? Category(
              name: map['categoryName'] as String,
              emoji: map['categoryEmoji'] as String? ?? '',
            )
          : null,
      account: map['accountId'] != null
          ? Account(
              id: map['accountId'] as String,
              name: map['accountName'] as String,
              balance: (map['accountBalance'] as num? ?? 0).toDouble(),
              type: _accountTypeFromMap(map, 'account'),
            )
          : null,
      fromAccount: map['fromAccountId'] != null
          ? Account(
              id: map['fromAccountId'] as String,
              name: map['fromAccountName'] as String,
              balance: (map['fromAccountBalance'] as num? ?? 0).toDouble(),
              type: _accountTypeFromMap(map, 'fromAccount'),
            )
          : null,
      toAccount: map['toAccountId'] != null
          ? Account(
              id: map['toAccountId'] as String,
              name: map['toAccountName'] as String,
              balance: (map['toAccountBalance'] as num? ?? 0).toDouble(),
              type: _accountTypeFromMap(map, 'toAccount'),
            )
          : null,
      fee: map['fee'] != null ? (map['fee'] as num).toDouble() : null,
    );
  }

  static AccountType _accountTypeFromMap(
    Map<String, dynamic> map,
    String prefix,
  ) {
    final storedType = map['${prefix}Type'] as String?;
    for (final type in AccountType.values) {
      if (type.name == storedType) return type;
    }

    final name = (map['${prefix}Name'] as String? ?? '').toLowerCase();
    if (name.contains('cash')) return AccountType.cash;
    if (name.contains('card')) return AccountType.card;
    return AccountType.bank;
  }
}
