import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_manager/models/transaction.dart';

import 'package:money_manager/theme/theme.dart';
import 'package:money_manager/features/home/widgets/month_picker_dialog.dart';
import 'package:money_manager/features/settings/accounts/account_store.dart';
import 'package:money_manager/features/settings/configuration/currency_settings.dart';
import 'package:money_manager/features/transaction/transaction_provider.dart';

/// "Total Stats" page opened from the chart button on the Accounts page.
///
/// Shows, for the last [_monthCount] months ending at the selected month:
///  * a line chart of the total balance (end of each month)
///  * a bar chart of income (blue) vs expense (red) per month
/// Everything is calculated from the saved transactions.
class AssetStatsPage extends StatefulWidget {
  const AssetStatsPage({super.key});

  @override
  State<AssetStatsPage> createState() => _AssetStatsPageState();
}

class _MonthStat {
  final DateTime month;
  final double income;
  final double expense;
  final double balance; // total balance at the end of this month

  const _MonthStat(this.month, this.income, this.expense, this.balance);
}

class _AssetStatsPageState extends State<AssetStatsPage> {
  static const int _monthCount = 6;
  static const double _axisWidth = 44;
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  DateTime _selected = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int delta) {
    setState(() {
      _selected = DateTime(_selected.year, _selected.month + delta);
    });
  }

  Future<void> _pickMonth() async {
    final picked = await MonthPickerDialog.show(context, _selected);
    if (picked != null) {
      setState(() => _selected = DateTime(picked.year, picked.month));
    }
  }

  // ---- data ---------------------------------------------------------------

  /// Same account matching rules as AssetPage, so the numbers agree with it.
  String? _resolveItemId(String? accountName, Set<String> ids) {
    final name = (accountName ?? '').toLowerCase().trim();
    if (name.isEmpty) return null;

    for (final item in AccountStore.visibleItems) {
      if (item.name.toLowerCase().trim() == name) return item.id;
    }

    String? fallback;
    if (name.contains('cash')) {
      fallback = 'a_cash';
    } else if (name.contains('bank') || name.contains('account')) {
      fallback = 'a_accounts';
    } else if (name.contains('card')) {
      fallback = 'a_card';
    }
    return (fallback != null && ids.contains(fallback)) ? fallback : null;
  }

  /// How much a transaction changes the *total* balance.
  double _delta(Transaction t, Set<String> ids) {
    double d = 0;
    void add(String? accountName, double v) {
      if (_resolveItemId(accountName, ids) != null) d += v;
    }

    switch (t.type) {
      case TransactionType.income:
        add(t.account?.name, t.amount);
        break;
      case TransactionType.expense:
        add(t.account?.name, -t.amount);
        break;
      case TransactionType.transfer:
        add(t.fromAccount?.name, -t.amount);
        add(t.toAccount?.name, t.amount);
        break;
    }
    return d;
  }

  List<_MonthStat> _buildStats(List<Transaction> all) {
    final items = AccountStore.visibleItems;
    final ids = items.map((e) => e.id).toSet();
    final initial = items.fold<double>(0, (s, i) => s + i.amount);

    final stats = <_MonthStat>[];
    for (int i = 0; i < _monthCount; i++) {
      final month = DateTime(_selected.year, _selected.month - (_monthCount - 1) + i);
      final end = DateTime(month.year, month.month + 1); // exclusive

      double income = 0, expense = 0, balance = initial;
      for (final t in all) {
        if (t.dateTime.isBefore(end)) balance += _delta(t, ids);
        if (t.dateTime.year == month.year && t.dateTime.month == month.month) {
          if (t.type == TransactionType.income) income += t.amount;
          if (t.type == TransactionType.expense) expense += t.amount;
        }
      }
      stats.add(_MonthStat(month, income, expense, balance));
    }
    return stats;
  }

  // ---- formatting ---------------------------------------------------------

  String _fmt(double v) {
    final decimals = CurrencySettings.notifier.value.decimals;
    final fixed = v.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final grouped = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    final number = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
    return v < 0 && double.parse(fixed) != 0 ? '-$number' : number;
  }

  String _compact(double v) {
    final a = v.abs();
    final sign = v < 0 ? '-' : '';
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    if (a >= 1e9) return '$sign${f(a / 1e9)}B';
    if (a >= 1e6) return '$sign${f(a / 1e6)}M';
    if (a >= 1e3) return '$sign${f(a / 1e3)}k';
    return '$sign${f(a)}';
  }

  /// Rounds the chart range to "nice" numbers (1, 2, 5 x 10^n).
  ({double min, double max, double interval}) _axis(double lo, double hi) {
    lo = math.min(lo, 0);
    hi = math.max(hi, 0);
    if (hi - lo < 1) hi = lo + 1000;
    final rough = (hi - lo) / 3;
    final mag = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final n = rough / mag;
    final step = (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * mag;
    return (
      min: (lo / step).floor() * step,
      max: (hi / step).ceil() * step,
      interval: step,
    );
  }

  // ---- widgets ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final text = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final sub = isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;
    final panel = isDark ? const Color(0xFF151518) : Colors.white;
    final grid = isDark ? Colors.white24 : Colors.black12;
    final accent = isDark ? AppTheme.accentRed : AppTheme.accentRedLight;

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return ListenableBuilder(
          listenable: Listenable.merge([
            AccountStore.groups,
            AccountStore.items,
            CurrencySettings.notifier,
          ]),
          builder: (context, _) {
            final stats = _buildStats(provider.all);
            final balance = stats.last.balance;

            final balAxis = _axis(
              stats.map((s) => s.balance).reduce(math.min),
              stats.map((s) => s.balance).reduce(math.max),
            );
            final flowAxis = _axis(
              0,
              stats.map((s) => math.max(s.income, s.expense)).reduce(math.max),
            );

            return Scaffold(
              backgroundColor: bg,
              appBar: AppBar(
                backgroundColor: bg,
                elevation: 0,
                iconTheme: IconThemeData(color: text),
                titleSpacing: 0,
                title: Text(
                  'Total Stats',
                  style: TextStyle(color: text, fontSize: 18),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: text),
                    onPressed: () => _shift(-1),
                  ),
                  GestureDetector(
                    onTap: _pickMonth,
                    child: Text(
                      '${_months[_selected.month - 1]} ${_selected.year}',
                      style: TextStyle(color: text, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: text),
                    onPressed: () => _shift(1),
                  ),
                ],
              ),
              body: SafeArea(
                child: ListView(
                  children: [
                    Container(
                      color: panel,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Balance',
                              style: TextStyle(color: sub, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(
                            _fmt(balance),
                            style: TextStyle(
                              color: balance < 0 ? Colors.red[400] : text,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      color: panel,
                      padding: const EdgeInsets.only(top: 16, right: 12),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 260,
                            child: _balanceChart(stats, balAxis, grid, sub, accent),
                          ),
                          const SizedBox(height: 12),
                          _labels(stats, text, sub, (s) => [
                                (_fmt(s.balance), sub),
                              ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      color: panel,
                      padding: const EdgeInsets.only(top: 16, right: 12),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: _flowChart(stats, flowAxis, grid, sub),
                          ),
                          const SizedBox(height: 12),
                          _labels(stats, text, sub, (s) => [
                                (_fmt(s.income), Colors.blue[400]!),
                                (_fmt(s.expense), Colors.red[400]!),
                              ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  FlTitlesData _titles(
    ({double min, double max, double interval}) axis,
    Color sub,
  ) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _axisWidth,
          interval: axis.interval,
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              _compact(value),
              textAlign: TextAlign.right,
              style: TextStyle(color: sub, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  FlGridData _gridData(double interval, Color grid) => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
      );

  Widget _balanceChart(
    List<_MonthStat> stats,
    ({double min, double max, double interval}) axis,
    Color grid,
    Color sub,
    Color accent,
  ) {
    return LineChart(
      LineChartData(
        minX: -0.5,
        maxX: _monthCount - 0.5,
        minY: axis.min,
        maxY: axis.max,
        titlesData: _titles(axis, sub),
        gridData: _gridData(axis.interval, grid),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: grid, width: 1),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < stats.length; i++)
                FlSpot(i.toDouble(), stats[i].balance),
            ],
            isCurved: false,
            color: accent,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 5,
                color: accent,
                strokeWidth: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowChart(
    List<_MonthStat> stats,
    ({double min, double max, double interval}) axis,
    Color grid,
    Color sub,
  ) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: 0,
        maxY: axis.max,
        titlesData: _titles(axis, sub),
        gridData: _gridData(axis.interval, grid),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: grid, width: 1),
        ),
        barTouchData: BarTouchData(enabled: false),
        barGroups: [
          for (int i = 0; i < stats.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                BarChartRodData(
                  toY: stats[i].income,
                  color: Colors.blue[700],
                  width: 9,
                  borderRadius: BorderRadius.zero,
                ),
                BarChartRodData(
                  toY: stats[i].expense,
                  color: Colors.red[700],
                  width: 9,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Month name + value rows under a chart, one column per month.
  Widget _labels(
    List<_MonthStat> stats,
    Color text,
    Color sub,
    List<(String, Color)> Function(_MonthStat) values,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: _axisWidth, bottom: 14),
      child: Row(
        children: [
          for (final s in stats)
            Expanded(
              child: Column(
                children: [
                  Text(_months[s.month.month - 1],
                      style: TextStyle(color: text, fontSize: 13)),
                  const SizedBox(height: 6),
                  for (final v in values(s))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(v.$1,
                            style: TextStyle(color: v.$2, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}