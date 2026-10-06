import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/currency_formatter.dart';
import '../../../models/transaction.dart';
import '../../transaction/transaction_provider.dart';

import '../services/statistic_service.dart';
import '../widgets/statistic_chart.dart';
import '../widgets/statistic_header.dart';
import '../widgets/statistic_header_button.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  bool isIncome = true;

  String selectedPeriod = "Monthly";

  final StatisticService statisticService = const StatisticService();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final currentMonth = DateTime.now();

    final monthTransactions =
        transactionProvider.forMonth(currentMonth);

    final incomeTotal =
        transactionProvider.totalIncome(currentMonth);

    final expenseTotal =
        transactionProvider.totalExpense(currentMonth);

    final statistics = statisticService.generateStatistics(
      transactions: monthTransactions,
      transactionType:
          isIncome
              ? TransactionType.income
              : TransactionType.expense,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StatisticHeader(
                selectedPeriod: selectedPeriod,
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedPeriod = value;
                  });

                  // Filtering logic later
                },
              ),
            ],
          ),
        ),

        Row(
          children: [
            Expanded(
              child: StatisticHeaderButton(
                title: "Income",
                amount: incomeTotal,
                selected: isIncome,
                onTap: () {
                  setState(() {
                    isIncome = true;
                  });
                },
              ),
            ),

            Expanded(
              child: StatisticHeaderButton(
                title: "Expense",
                amount: expenseTotal,
                selected: !isIncome,
                onTap: () {
                  setState(() {
                    isIncome = false;
                  });
                },
              ),
            ),
          ],
        ),

        const Divider(height: 1),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                StatisticChart(
                  statistics: statistics,
                ),

                const SizedBox(height: 30),

                Text(
                  isIncome
                      ? "Income Categories"
                      : "Expense Categories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 15),

                if (statistics.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      "No transaction this month",
                      style: TextStyle(color: textColor),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: statistics.length,
                    itemBuilder: (context, index) {
                      final item = statistics[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.color,
                            child: Text(
                              item.emoji,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),

                          title: Text(
                            item.category,
                            style: TextStyle(color: textColor),
                          ),

                          subtitle: Text(
                            "${item.percentage.toStringAsFixed(1)} %",
                            style: TextStyle(color: textColor),
                          ),

                          trailing: Text(
                            formatRupiah(item.total),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}