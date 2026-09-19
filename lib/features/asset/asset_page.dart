import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../transaction/transaction_provider.dart';

import 'package:money_manager/models/transaction.dart';

import '../../theme/theme.dart';

import 'components/asset_summary_header.dart';
import 'components/asset_trend_chart.dart';
import 'components/asset_list_item.dart';

class AssetPage extends StatelessWidget {
  const AssetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return Consumer<TransactionProvider>(
      builder: (context, transProvider, child) {
        double cashBalance = 0.0;
        double accountsBalance = 0.0;
        double cardBalance = 0.0;

        for (var t in transProvider.all) {
          if (t.type == TransactionType.income) {
            String namaAkun = t.account?.name.toLowerCase() ?? "";
            if (namaAkun.contains('cash'))
              cashBalance += t.amount;
            else if (namaAkun.contains('bank') || namaAkun.contains('account'))
              accountsBalance += t.amount;
            else if (namaAkun.contains('card'))
              cardBalance += t.amount;
          } else if (t.type == TransactionType.expense) {
            String namaAkun = t.account?.name.toLowerCase() ?? "";
            if (namaAkun.contains('cash'))
              cashBalance -= t.amount;
            else if (namaAkun.contains('bank') || namaAkun.contains('account'))
              accountsBalance -= t.amount;
            else if (namaAkun.contains('card'))
              cardBalance -= t.amount;
          } else if (t.type == TransactionType.transfer) {
            String fromAkun = t.fromAccount?.name.toLowerCase() ?? "";
            String toAkun = t.toAccount?.name.toLowerCase() ?? "";

            if (fromAkun.contains('cash'))
              cashBalance -= t.amount;
            else if (fromAkun.contains('bank') || fromAkun.contains('account'))
              accountsBalance -= t.amount;
            else if (fromAkun.contains('card'))
              cardBalance -= t.amount;

            if (toAkun.contains('cash'))
              cashBalance += t.amount;
            else if (toAkun.contains('bank') || toAkun.contains('account'))
              accountsBalance += t.amount;
            else if (toAkun.contains('card'))
              cardBalance += t.amount;
          }
        }

        double totalAssets = 0.0;
        double totalLiabilities = 0.0;

        if (cashBalance >= 0)
          totalAssets += cashBalance;
        else
          totalLiabilities += cashBalance.abs();

        if (accountsBalance >= 0)
          totalAssets += accountsBalance;
        else
          totalLiabilities += accountsBalance.abs();

        if (cardBalance >= 0)
          totalAssets += cardBalance;
        else
          totalLiabilities += cardBalance.abs();

        double totalAll = totalAssets - totalLiabilities;

        Color cashColor = cashBalance < 0
            ? Colors.red[400]!
            : Colors.blue[400]!;
        Color accountsColor = accountsBalance < 0
            ? Colors.red[400]!
            : Colors.blue[400]!;
        Color cardColor = cardBalance < 0
            ? Colors.red[400]!
            : Colors.blue[400]!;

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

                Expanded(
                  child: ListView(
                    children: [
                      AssetListItem(
                        title: "Cash",
                        titleAmount:
                            "\$ ${cashBalance.abs().toStringAsFixed(2)}",
                        titleAmountColor: cashColor,
                        itemLabel: "Cash",
                        itemAmount:
                            "\$ ${cashBalance.abs().toStringAsFixed(2)}",
                        itemAmountColor: cashColor,
                      ),
                      AssetListItem(
                        title: "Accounts",
                        titleAmount:
                            "\$ ${accountsBalance.abs().toStringAsFixed(2)}",
                        titleAmountColor: accountsColor,
                        itemLabel: "Accounts",
                        itemAmount:
                            "\$ ${accountsBalance.abs().toStringAsFixed(2)}",
                        itemAmountColor: accountsColor,
                      ),
                      AssetListItem(
                        isCard: true,
                        title: "Card",
                        itemLabel: "Card",
                        cardPayableAmount: "\$ 0.00",
                        cardOutstAmount:
                            "\$ ${cardBalance.abs().toStringAsFixed(2)}",
                        cardOutstColor: cardColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
