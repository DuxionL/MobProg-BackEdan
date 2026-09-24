import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../transaction/transaction_provider.dart';

import 'package:money_manager/models/transaction.dart';

import '../../theme/theme.dart';
import '../settings/configuration/currency_settings.dart';
import '../settings/accounts/account_store.dart';

import 'components/asset_summary_header.dart';
import 'components/asset_trend_chart.dart';
import 'components/asset_list_item.dart';

class AssetPage extends StatefulWidget {
  const AssetPage({super.key});

  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  @override
  void initState() {
    super.initState();
    AccountStore.load();
  }

  String? _resolveItemId(String? accountName, Map<String, double> balances) {
    final name = (accountName ?? "").toLowerCase().trim();
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
    return balances.containsKey(fallback) ? fallback : null;
  }

  Map<String, double> _calculateBalances(List<Transaction> transactions) {
    final balances = <String, double>{
      for (final item in AccountStore.visibleItems) item.id: item.amount,
    };

    void add(String? accountName, double value) {
      final id = _resolveItemId(accountName, balances);
      if (id != null) balances[id] = balances[id]! + value;
    }

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        add(t.account?.name, t.amount);
      } else if (t.type == TransactionType.expense) {
        add(t.account?.name, -t.amount);
      } else if (t.type == TransactionType.transfer) {
        add(t.fromAccount?.name, -t.amount);
        add(t.toAccount?.name, t.amount);
      }
    }

    return balances;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final normalColor = isDark ? Colors.white : Colors.black;

    return Consumer<TransactionProvider>(
      builder: (context, transProvider, child) {
        return ListenableBuilder(
          listenable: Listenable.merge([
            AccountStore.groups,
            AccountStore.items,
            CurrencySettings.notifier,
          ]),
          builder: (context, child) {
            final balances = _calculateBalances(transProvider.all);
            final items = AccountStore.visibleItems;

            double totalAssets = 0.0;
            double totalLiabilities = 0.0;
            for (final value in balances.values) {
              if (value >= 0) {
                totalAssets += value;
              } else {
                totalLiabilities += value.abs();
              }
            }
            final totalAll = totalAssets - totalLiabilities;

            Color colorFor(double value) {
              if (value.abs() < 0.005) return normalColor;
              return value < 0 ? Colors.red[400]! : Colors.blue[400]!;
            }

            final groupWidgets = <Widget>[];
            for (final group in AccountStore.visibleGroups) {
              final groupItems = items
                  .where((i) => i.groupId == group.id)
                  .toList();
              if (groupItems.isEmpty) continue;

              final isCard = group.type == AccountGroupType.credit;
              final groupTotal = groupItems.fold<double>(
                0,
                (sum, i) => sum + (balances[i.id] ?? 0),
              );

              final rows = groupItems.map((item) {
                final balance = balances[item.id] ?? 0;
                final text = CurrencySettings.format(balance.abs());
                if (isCard) {
                  return AssetRow(
                    label: item.name,
                    payableAmount: CurrencySettings.format(0),
                    outstAmount: text,
                    outstColor: colorFor(balance),
                  );
                }
                return AssetRow(
                  label: item.name,
                  amount: text,
                  amountColor: colorFor(balance),
                );
              }).toList();

              groupWidgets.add(
                AssetListItem(
                  title: group.name,
                  titleAmount: isCard
                      ? null
                      : CurrencySettings.format(groupTotal.abs()),
                  titleAmountColor: colorFor(groupTotal),
                  isCard: isCard,
                  rows: rows,
                ),
              );
            }

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: bgColor,
                elevation: 0,
                title: Text(
                  "Accounts",
                  style: TextStyle(color: textColor, fontSize: 18),
                ),
                actions: [
                  Icon(Icons.bar_chart, color: textColor),
                  const SizedBox(width: 16),
                  Icon(Icons.more_vert, color: textColor),
                  const SizedBox(width: 16),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    AssetSummaryHeader(
                      assets: totalAssets,
                      liabilities: totalLiabilities,
                      total: totalAll,
                    ),
                    const AssetTrendChart(),
                    Expanded(child: ListView(children: groupWidgets)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
