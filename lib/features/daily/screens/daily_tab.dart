import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../widgets/summary_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/empty_state_widget.dart';

/// Tab "Harian" — nampilin ringkasan bulan aktif + list transaksi
/// dikelompokkan per tanggal.
class DailyTab extends StatefulWidget {
  const DailyTab({super.key});

  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  // TODO: sinkronkan dengan state bulan aktif dari AppBar (Anggota 1) kalau sudah ada.
  // Sementara pakai state lokal dulu supaya tab ini bisa berdiri sendiri untuk testing.
  DateTime _activeMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final grouped = provider.groupedByDay(_activeMonth);

        return Column(
          children: [
            SummaryHeader(month: _activeMonth),
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