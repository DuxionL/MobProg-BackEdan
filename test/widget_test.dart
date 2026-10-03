// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:money_manager/features/transaction/screens/transaction_list_page.dart';
import 'package:money_manager/features/transaction/transaction_provider.dart';
import 'package:money_manager/models/transaction.dart' as app_models;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('transaction row exposes edit and duplicate actions', (
    tester,
  ) async {
    final provider = TransactionProvider(autoLoad: false);
    await provider.addTransaction(
      app_models.Transaction(
        id: 'txn-1',
        dateTime: DateTime(2024, 1, 15, 9, 30),
        amount: 125000,
        type: app_models.TransactionType.expense,
        category: app_models.Category(name: 'Food', emoji: '🍜'),
        account: app_models.Account(
          id: 'a1',
          name: 'Cash',
          balance: 0,
          type: app_models.AccountType.cash,
        ),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<TransactionProvider>.value(
        value: provider,
        child: const MaterialApp(home: TransactionListPage()),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
  });
}
