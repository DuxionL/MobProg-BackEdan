import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_state_widget.dart';

/// Tab "Harian" — nampilin ringkasan bulan aktif + list transaksi
/// dikelompokkan per tanggal. Bulan aktif dikontrol dari luar (HomePage),
/// supaya sinkron dengan panah navigasi bulan di CustomAppBar.
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
              child: grouped.isEmpty
                  ? const EmptyStateWidget()
                  : ListView(
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
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
          ],
        );
      },
    );
  }

  String _formatDayHeader(DateTime day) {
    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dayName = dayNames[day.weekday - 1];
    return '$dayName, ${day.day}/${day.month}/${day.year}';
  }
}