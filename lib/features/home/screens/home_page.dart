import 'package:flutter/material.dart';
import 'package:money_manager/features/home/widgets/custom_app_bar.dart';
import 'package:money_manager/features/transaction/screens/add_transaction_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../asset/asset_page.dart';
import '../../settings/settings_page.dart';
import '../../daily/screens/tab_bar_wrapper.dart';
import '../widgets/fab_button.dart';
import '../widgets/month_picker_dialog.dart';
import '../../../theme/theme.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime _currentMonth = DateTime.now();

  String get _monthLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Exit the app',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TabBarWrapper(
        month: _currentMonth,
        onJumpToToday: () {
          setState(() => _currentMonth = DateTime.now());
        },
      ),
      const Center(child: Text('Statistics Tab')),
      const AssetPage(),
      const SettingsPage(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },

      child: Scaffold(
        appBar: CustomAppBar(
          monthLabel: _monthLabel,
          onPreviousMonth: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          },
          onNextMonth: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          },
          onMonthTap: () async {
            final picked = await MonthPickerDialog.show(context, _currentMonth);
            if (picked != null) {
              setState(() => _currentMonth = picked);
            }
          },
          onSearchTap: () {},
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(_selectedIndex),
            child: pages[_selectedIndex],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
        floatingActionButton: _selectedIndex == 0
            ? FabButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddTransactionPage()),
                  );
                },
              )
            : null,
      ),
    );
  }
}