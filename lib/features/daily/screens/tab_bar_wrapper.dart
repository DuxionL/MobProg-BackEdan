import 'package:flutter/material.dart';
import 'package:money_manager/features/daily/screens/daily_tab.dart';
import 'package:money_manager/features/daily/screens/calendar_tab.dart';
import 'package:money_manager/theme/theme.dart';

class TabBarWrapper extends StatelessWidget {
  final DateTime month;
  final VoidCallback? onJumpToToday;
  final Set<String> selectedCategories;
  final Set<String> selectedAccounts;

  const TabBarWrapper({
    super.key,
    required this.month,
    this.onJumpToToday,
    this.selectedCategories = const {},
    this.selectedAccounts = const {},
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            isScrollable: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            labelColor: AppTheme.accentRed,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.accentRed,
            tabs: const [
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
                DailyTab(
                  month: month,
                  selectedCategories: selectedCategories,
                  selectedAccounts: selectedAccounts,
                ),
                CalendarTab(
                  month: month,
                  onJumpToToday: onJumpToToday,
                  selectedCategories: selectedCategories,
                  selectedAccounts: selectedAccounts,
                ),
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