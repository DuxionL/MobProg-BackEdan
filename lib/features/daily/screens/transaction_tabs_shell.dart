import 'package:flutter/material.dart';
import 'package:money_manager/features/daily/screens/daily_tab.dart';
import 'package:money_manager/features/daily/screens/calendar_tab.dart';

class TransactionTabsShell extends StatelessWidget {
  final DateTime month;

  const TransactionTabsShell({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Calendar'),
              Tab(text: 'Monthly'),
              Tab(text: 'Total'),
              Tab(text: 'Note'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                DailyTab(month: month),
                CalendarTab(month: month),
                const Center(child: Text('Monthly Tab')),
                const Center(child: Text('Total Tab')),
                const Center(child: Text('Note Tab')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}