import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../theme/theme.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../../../models/transaction.dart';

class CalendarTab extends StatefulWidget {
  final DateTime month;
  final VoidCallback? onJumpToToday;

  const CalendarTab({super.key, required this.month, this.onJumpToToday});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime? _selectedDay;

  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  void _jumpToToday() {
    setState(() => _selectedDay = DateTime.now());
    widget.onJumpToToday?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final Map<DateTime, List<Transaction>> grouped =
            provider.groupedByDay(widget.month);
        final days = _buildMonthGrid(widget.month);

        return Column(
          children: [
            SummaryHeader(month: widget.month),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _jumpToToday,
                icon: Icon(Icons.today, size: 16, color: AppTheme.accentRed),
                label: Text('Today', style: TextStyle(color: AppTheme.accentRed)),
              ),
            ),
            _buildWeekdayHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildCalendarGrid(days, grouped),
                  _buildDraggableTransactionSheet(grouped),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekdayHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _dayLabels
            .map(
              (label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: label == 'Sun' ? AppTheme.accentRed : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(
    List<DateTime?> days,
    Map<DateTime, List<Transaction>> grouped,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        if (day == null) return const SizedBox.shrink();

        final normalizedDay = DateTime(day.year, day.month, day.day);
        final transactions = grouped[normalizedDay] ?? [];
        final hasData = transactions.isNotEmpty;
        final isSelected = _selectedDay != null &&
            _isSameDay(_selectedDay!, normalizedDay);
        final isToday = _isSameDay(DateTime.now(), normalizedDay);

        double net = 0;
        for (final t in transactions) {
          net += (t.type == TransactionType.expense) ? -t.amount : t.amount;
        }

        // Unique categories present that day, capped at 3 dots so it
        // doesn't overflow a small calendar cell.
        final categoryLabels = transactions
            .map((t) => t.category?.name ?? 'Transfer')
            .toSet()
            .take(3)
            .toList();

        return InkWell(
          onTap: () => setState(() => _selectedDay = normalizedDay),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentRed.withOpacity(0.12) : null,
              border: isToday
                  ? Border.all(color: AppTheme.accentRed, width: 1)
                  : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 12,
                    color: day.weekday == DateTime.sunday
                        ? AppTheme.accentRed
                        : Colors.white,
                  ),
                ),
                if (hasData) ...[
                  const SizedBox(height: 1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: categoryLabels
                        .map(
                          (label) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0.5),
                            child: Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: _categoryColor(label),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Text(
                    net.abs() >= 1000
                        ? '${(net.abs() / 1000).toStringAsFixed(0)}k'
                        : net.abs().toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 8,
                      color: net >= 0 ? Colors.blue : AppTheme.accentRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static const _categoryColors = {
    // Income
    'Salary': Color(0xFFFFC107),
    'Bonus': Color(0xFFEF5350),
    'Refund': Color(0xFF66BB6A),
    'Interest': Colors.white,
    'Other Income': Color(0xFF616161),
    // Expense
    'Food': Color(0xFFFFA726),
    'Transportation': Color(0xFFE53935),
    'Utilities': Color(0xFFFFEE58),
    'Entertainment': Color(0xFF7E57C2),
    'Shopping': Color(0xFFEC407A),
    'Healthcare': Color(0xFF26A69A),
    'Education': Color(0xFF42A5F5),
    'Other Expense': Color(0xFF8D6E63),
  
    'Transfer': Colors.purple,
  };

  static const _fallbackPalette = [
    Color(0xFFFFA726),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFFFCA28),
    Color(0xFF26C6DA),
    Color(0xFFEC407A),
    Color(0xFF8D6E63),
  ];

  Color _categoryColor(String categoryName) {
    if (_categoryColors.containsKey(categoryName)) {
      return _categoryColors[categoryName]!;
    }
    final index = categoryName.hashCode.abs() % _fallbackPalette.length;
    return _fallbackPalette[index];
  }

  Widget _buildDraggableTransactionSheet(Map<DateTime, List<Transaction>> grouped) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border(top: BorderSide(color: AppTheme.surface, width: 1)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildSelectedDayList(grouped, scrollController),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayList(
    Map<DateTime, List<Transaction>> grouped,
    ScrollController scrollController,
  ) {
    if (_selectedDay == null) {
      return ListView(
        key: const ValueKey('no-selection'),
        controller: scrollController,
        children: const [
          EmptyStateWidget(
            message: 'Select a date to view transactions',
            icon: Icons.touch_app_outlined,
          ),
        ],
      );
    }

    final transactions = grouped[_selectedDay] ?? [];
    if (transactions.isEmpty) {
      return ListView(
        key: ValueKey(_selectedDay),
        controller: scrollController,
        children: const [EmptyStateWidget()],
      );
    }

    return ListView.builder(
      key: ValueKey(_selectedDay),
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: transactions.length,
      itemBuilder: (context, index) =>
          TransactionListItem(transaction: transactions[index]),
    );
  }

  List<DateTime?> _buildMonthGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday % 7; // Sunday=7 -> becomes 0

    return [
      ...List.filled(leadingEmpty, null),
      ...List.generate(
        daysInMonth,
        (i) => DateTime(month.year, month.month, i + 1),
      ),
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}