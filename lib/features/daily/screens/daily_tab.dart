import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../../../theme/theme.dart';

class DailyTab extends StatelessWidget {
  final DateTime month;

  const DailyTab({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final grouped = provider.groupedByDay(month);

        return Column(
          children: [
            SummaryHeader(month: month),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: grouped.isEmpty
                    ? const EmptyStateWidget(key: ValueKey('empty'))
                    : ListView(
                        key: ValueKey(month),
                        children: grouped.entries.map((entry) {
                          final day = entry.key;
                          final transactions = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Text(
                                  _formatDayHeader(day),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              ...transactions.map(
                                (t) => TransactionListItem(transaction: t),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDayHeader(DateTime day) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[day.weekday - 1];
    return '$dayName, ${day.day}/${day.month}/${day.year}';
  }
}