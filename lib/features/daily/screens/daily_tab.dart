import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../models/transaction.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../../../theme/theme.dart';

class DailyTab extends StatefulWidget {
  final DateTime month;

  const DailyTab({super.key, required this.month});

  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  String? _selectedCategory; // null = show all

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final allGrouped = provider.groupedByDay(widget.month);
        final grouped = _applyFilter(allGrouped);
        final categories = {
          ...provider.incomeCategories.map((c) => c.name),
          ...provider.expenseCategories.map((c) => c.name),
        }.toList();

        return Column(
          children: [
            SummaryHeader(month: widget.month),
            _buildCategoryChips(categories),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: grouped.isEmpty
                    ? EmptyStateWidget(
                        key: ValueKey('empty-${_selectedCategory ?? 'all'}'),
                        message: _selectedCategory == null
                            ? 'No data available'
                            : 'No "$_selectedCategory" transactions this month',
                      )
                    : ListView(
                        key: ValueKey('${widget.month}-${_selectedCategory ?? 'all'}'),
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

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          _buildChip('All', _selectedCategory == null, () {
            setState(() => _selectedCategory = null);
          }),
          ...categories.map(
            (c) => _buildChip(c, _selectedCategory == c, () {
              setState(() => _selectedCategory = c);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.accentRed,
        backgroundColor: AppTheme.surface,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Map<DateTime, List<Transaction>> _applyFilter(
    Map<DateTime, List<Transaction>> grouped,
  ) {
    if (_selectedCategory == null) return grouped;

    final filtered = <DateTime, List<Transaction>>{};
    for (final entry in grouped.entries) {
      final matches = entry.value
          .where((t) => t.category?.name == _selectedCategory)
          .toList();
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