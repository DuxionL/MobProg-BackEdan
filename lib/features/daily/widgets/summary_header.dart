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

        final previousMonth = DateTime(month.year, month.month - 1);
        final previousTotal = provider.netTotal(previousMonth);
        final double? percentChange = previousTotal != 0
            ? ((total - previousTotal) / previousTotal.abs()) * 100
            : null;

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
                label: 'Income',
                value: income,
                color: Colors.blue,
              ),
              _SummaryItem(
                label: 'Expenses',
                value: expense,
                color: AppTheme.accentRed,
              ),
              _SummaryItem(
                label: 'Total',
                value: total,
                color: AppTheme.textPrimary,
                percentChange: percentChange,
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
  final double? percentChange;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.percentChange,
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
        if (percentChange != null) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                percentChange! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 10,
                color: percentChange! >= 0 ? Colors.green : AppTheme.accentRed,
              ),
              Text(
                '${percentChange!.abs().toStringAsFixed(0)}% vs last month',
                style: TextStyle(
                  fontSize: 9,
                  color: percentChange! >= 0 ? Colors.green : AppTheme.accentRed,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}