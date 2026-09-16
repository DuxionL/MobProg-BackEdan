import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/transaction.dart';
import '../../transaction/transaction_provider.dart';

import '../services/statistic_service.dart';
import '../widgets/statistic_chart.dart';
import '../widgets/statistic_header_button.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  bool isIncome = true;

  final StatisticService statisticService = const StatisticService();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();

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

        const Divider(
          height: 1,
        ),

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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 15),

                if (statistics.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      "No transaction this month",
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
                              style:
                                  const TextStyle(fontSize: 18),
                            ),
                          ),

                          title: Text(item.category),

                          subtitle: Text(
                            "${item.percentage.toStringAsFixed(1)} %",
                          ),

                          trailing: Text(
                            item.total.toStringAsFixed(0),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
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