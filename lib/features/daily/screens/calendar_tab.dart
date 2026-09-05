import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../../../models/transaction.dart';

/// Tab "Kalender" — grid tanggal sebulan, tiap kotak nampilin indikator
/// titik + nominal kecil kalau ada transaksi di hari itu. Tap tanggal untuk
/// lihat list transaksi hari tersebut.
class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  // TODO: sinkronkan dengan state bulan aktif dari AppBar (Anggota 1) kalau sudah ada.
  DateTime _activeMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  static const _dayLabels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final Map<DateTime, List<Transaction>> grouped =
            provider.groupedByDay(_activeMonth);
        final days = _buildMonthGrid(_activeMonth);

        return Column(
          children: [
            SummaryHeader(month: _activeMonth),
            _buildWeekdayHeader(),
            Expanded(
              flex: 3,
              child: _buildCalendarGrid(days, grouped),
            ),
            const Divider(height: 1),
            Expanded(
              flex: 2,
              child: _buildSelectedDayList(grouped),
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
                      color: label == 'Min' ? Colors.redAccent : Colors.grey,
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
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.08) : null,
              border: isToday
                  ? Border.all(color: Colors.redAccent, width: 1)
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
                        ? Colors.redAccent
                        : Colors.white,
                  ),
                ),
                if (hasData) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: net >= 0 ? Colors.blue : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    net.abs() >= 1000
                        ? '${(net.abs() / 1000).toStringAsFixed(0)}k'
                        : net.abs().toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 9,
                      color: net >= 0 ? Colors.blue : Colors.redAccent,
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
        message: 'Pilih tanggal untuk lihat transaksi',
        icon: Icons.touch_app_outlined,
      );
    }

    final transactions = grouped[_selectedDay] ?? [];
    if (transactions.isEmpty) {
      return const EmptyStateWidget();
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) =>
          TransactionListItem(transaction: transactions[index]),
    );
  }

  /// Bikin list tanggal untuk grid bulan ini, termasuk null-padding
  /// di awal supaya kotak pertama jatuh di hari yang benar (Minggu = index 0).
  List<DateTime?> _buildMonthGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday % 7; // Minggu=7 -> jadi 0

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