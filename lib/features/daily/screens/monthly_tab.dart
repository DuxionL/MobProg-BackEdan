import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/currency_formatter.dart';
import '../../../models/transaction.dart';
import '../../../theme/theme.dart';
import '../../transaction/transaction_provider.dart';
import '../widgets/summary_header.dart';

class MonthlyTab extends StatefulWidget {
  final DateTime month;

  const MonthlyTab({super.key, required this.month});

  @override
  State<MonthlyTab> createState() => _MonthlyTabState();
}

class _MonthlyTabState extends State<MonthlyTab> {
  int? _expandedMonth;

  @override
  void initState() {
    super.initState();
    _expandedMonth = widget.month.month;
  }

  @override
  void didUpdateWidget(covariant MonthlyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) {
      _expandedMonth = widget.month.month;
    }
  }

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _md(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// Sunday-start weeks that cover the month (first/last week may spill
  /// into neighbouring months, but only in-month transactions are counted).
  List<_Week> _weeksOf(DateTime month, List<Transaction> txs) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    var start = DateTime(
      first.year,
      first.month,
      first.day - (first.weekday % 7),
    );

    final weeks = <_Week>[];
    while (!start.isAfter(last)) {
      final end = DateTime(start.year, start.month, start.day + 6);
      double income = 0, expense = 0;
      for (final t in txs) {
        final d = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
        if (d.isBefore(start) || d.isAfter(end)) continue;
        if (t.type == TransactionType.income) income += t.amount;
        if (t.type == TransactionType.expense) expense += t.amount;
      }
      weeks.add(_Week(start, end, income, expense));
      start = DateTime(start.year, start.month, start.day + 7);
    }
    return weeks.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final year = widget.month.year;
        final byMonth = List.generate(12, (_) => <Transaction>[]);
        for (final t in provider.all) {
          if (t.dateTime.year == year) byMonth[t.dateTime.month - 1].add(t);
        }

        double sum(List<Transaction> l, TransactionType type) =>
            l.where((t) => t.type == type).fold(0.0, (s, t) => s + t.amount);

        final yearIncome = byMonth
            .map((l) => sum(l, TransactionType.income))
            .fold(0.0, (a, b) => a + b);
        final yearExpense = byMonth
            .map((l) => sum(l, TransactionType.expense))
            .fold(0.0, (a, b) => a + b);

        return Column(
          children: [
            SummaryBar(
              income: yearIncome,
              expense: yearExpense,
              total: yearIncome - yearExpense,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: 12,
                itemBuilder: (context, i) {
                  final m = 12 - i; // Dec -> Jan
                  final txs = byMonth[m - 1];
                  final income = sum(txs, TransactionType.income);
                  final expense = sum(txs, TransactionType.expense);
                  final first = DateTime(year, m, 1);
                  final last = DateTime(year, m + 1, 0);
                  final expanded = _expandedMonth == m;

                  return Column(
                    children: [
                      _AmountRow(
                        title: _monthNames[m - 1],
                        subtitle: '${_md(first)} ~ ${_md(last)}',
                        income: income,
                        expense: expense,
                        bold: true,
                        onTap: () => setState(
                          () => _expandedMonth = expanded ? null : m,
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: expanded
                            ? Column(
                                children: _weeksOf(first, txs).map((w) {
                                  final now = DateTime.now();
                                  final today = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  final isCurrent =
                                      !today.isBefore(w.start) &&
                                      !today.isAfter(w.end);
                                  return _AmountRow(
                                    title: '${_md(w.start)} ~ ${_md(w.end)}',
                                    income: w.income,
                                    expense: w.expense,
                                    indent: true,
                                    highlight: isCurrent,
                                  );
                                }).toList(),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Week {
  final DateTime start;
  final DateTime end;
  final double income;
  final double expense;

  const _Week(this.start, this.end, this.income, this.expense);
}

class _AmountRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double income;
  final double expense;
  final bool bold;
  final bool indent;
  final bool highlight;
  final VoidCallback? onTap;

  const _AmountRow({
    required this.title,
    this.subtitle,
    required this.income,
    required this.expense,
    this.bold = false,
    this.indent = false,
    this.highlight = false,
    this.onTap,
  });

  Widget _amount(String text, Color color, {double size = 13}) => Align(
    alignment: Alignment.centerRight,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: size),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodySmall!.color!;
    final net = income - expense;

    return Material(
      color: highlight
          ? AppTheme.accentRed.withValues(alpha: 0.18)
          : (indent ? theme.cardTheme.color : Colors.transparent),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(indent ? 32 : 16, 12, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: bold ? 16 : 14,
                        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: _amount(formatRupiah(income), Colors.blue),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _amount(formatRupiah(expense), AppTheme.accentRed),
                    const SizedBox(height: 2),
                    _amount(
                      highlight
                          ? 'Total ${formatRupiah(net)}'
                          : formatRupiah(net),
                      textSecondary,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
