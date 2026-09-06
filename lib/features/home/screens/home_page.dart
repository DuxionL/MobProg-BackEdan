import 'package:flutter/material.dart';
import 'package:money_manager/features/home/widgets/custom_app_bar.dart';
import 'package:money_manager/features/transaction/screens/add_transaction_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../asset/asset_page.dart';
import '../../settings/settings_page.dart';
import '../../transaction/screens/transaction_list_page.dart';
import '../widgets/fab_button.dart';
import '../../statistic/screens/statistic_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime _currentMonth = DateTime.now();
 
  final List<Widget> _pages = [
    const TransactionListPage(),
    const StatisticPage(),
    const AssetPage(),
    const SettingsPage(),
  ];
 
  String get _monthLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onSearchTap: () {
          // nanti blom bikin logic search
        },
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      floatingActionButton: _selectedIndex == 0
      ? FabButton(
        onPressed:(){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
      )
      : null,  
    );
  }
}