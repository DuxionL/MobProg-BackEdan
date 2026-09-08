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
              flex: 3,
              child: _buildCalendarGrid(days, grouped),
            ),
            const Divider(height: 1),
            Expanded(
              flex: 2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildSelectedDayList(grouped),
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
        childAspectRatio: 0.85,
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
                    fontSize: 13,
                    color: day.weekday == DateTime.sunday
                        ? AppTheme.accentRed
                        : Colors.white,
                  ),
                ),
                if (hasData) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: net >= 0 ? Colors.blue : AppTheme.accentRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    net.abs() >= 1000
                        ? '${(net.abs() / 1000).toStringAsFixed(0)}k'
                        : net.abs().toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 9,
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

  Widget _buildSelectedDayList(Map<DateTime, List<Transaction>> grouped) {
    if (_selectedDay == null) {
      return const EmptyStateWidget(
        key: ValueKey('no-selection'),
        message: 'Select a date to view transactions',
        icon: Icons.touch_app_outlined,
      );
    }

    final transactions = grouped[_selectedDay] ?? [];
    if (transactions.isEmpty) {
      return EmptyStateWidget(key: ValueKey(_selectedDay));
    }

    return ListView.builder(
      key: ValueKey(_selectedDay),
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