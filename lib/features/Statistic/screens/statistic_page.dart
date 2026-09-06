import 'package:flutter/material.dart';
import '../widgets/statistic_header_button.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  bool isIncome = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children: [

            StatisticHeaderButton(
              title: "Income",
              amount: 10000,
              selected: isIncome,
              onTap: () {
                setState(() {
                  isIncome = true;
                });
              },
            ),

            StatisticHeaderButton(
              title: "Expenses",
              amount: 1064,
              selected: !isIncome,
              onTap: () {
                setState(() {
                  isIncome = false;
                });
              },
            ),

          ],
        ),

        const Divider(
          height: 1,
          color: Colors.grey,
        ),

        Expanded(
          child: Center(
            child: Text(
              isIncome
                  ? "Income Chart Here"
                  : "Expense Chart Here",
            ),
          ),
        ),
      ],
    );
  }
}