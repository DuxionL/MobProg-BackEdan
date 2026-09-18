import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../models/transaction.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../../../theme/theme.dart';

class DailyTab extends StatelessWidget {
  final DateTime month;
  final Set<String> selectedCategories;
  final Set<String> selectedAccounts;

  const DailyTab({
    super.key,
    required this.month,
    this.selectedCategories = const {},
    this.selectedAccounts = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final grouped = _applyFilter(provider.groupedByDay(month));

        return Column(
          children: [
            SummaryHeader(month: month),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: grouped.isEmpty
                    ? const EmptyStateWidget(key: ValueKey('empty'))
                    : ListView(
                        key: ValueKey(
                          '$month-${selectedCategories.length}-${selectedAccounts.length}',
                        ),
                        padding: const EdgeInsets.only(bottom: 80),
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

  bool _matches(Transaction t) {
    final categoryOk = selectedCategories.isEmpty ||
        selectedCategories.contains(t.category?.name);
    final accountOk = selectedAccounts.isEmpty ||
        selectedAccounts.contains(t.account?.name) ||
        selectedAccounts.contains(t.fromAccount?.name) ||
        selectedAccounts.contains(t.toAccount?.name);
    return categoryOk && accountOk;
  }

  Map<DateTime, List<Transaction>> _applyFilter(
    Map<DateTime, List<Transaction>> grouped,
  ) {
    if (selectedCategories.isEmpty && selectedAccounts.isEmpty) return grouped;

    final filtered = <DateTime, List<Transaction>>{};
    for (final entry in grouped.entries) {
      final matches = entry.value.where(_matches).toList();
      if (matches.isNotEmpty) filtered[entry.key] = matches;
    }
    return filtered;
  }

  String _formatDayHeader(DateTime day) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[day.weekday - 1];
    return '$dayName, ${day.day}/${day.month}/${day.year}';
  }
}