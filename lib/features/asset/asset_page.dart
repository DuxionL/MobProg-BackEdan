import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../transaction/transaction_provider.dart';

import '../../theme/theme.dart';
import '../settings/configuration/currency_settings.dart';
import '../settings/accounts/account_store.dart';

import 'asset_calculator.dart';
import 'components/asset_summary_header.dart';
import 'components/asset_trend_chart.dart';
import 'components/asset_list_item.dart';
import 'components/asset_stats_page.dart';

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
            final balances = AssetCalculator.balances(transProvider.all);
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
                  IconButton(
                    icon: Icon(Icons.bar_chart, color: textColor),
                    tooltip: 'Total stats',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssetStatsPage(),
                        ),
                      );
                    },
                  ),
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