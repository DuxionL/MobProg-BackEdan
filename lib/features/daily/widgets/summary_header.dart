import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../theme/theme.dart';


class SummaryHeader extends StatelessWidget {
  final DateTime month;

  const SummaryHeader({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final income = provider.totalIncome(month);
        final expense = provider.totalExpense(month);
        final total = provider.netTotal(month);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.surface, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Pendapatan',
                value: income,
                color: Colors.blue,
              ),
              _SummaryItem(
                label: 'Pengeluaran',
                value: expense,
                color: AppTheme.accentRed,
              ),
              _SummaryItem(
                label: 'Total',
                value: total,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}