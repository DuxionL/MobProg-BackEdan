import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import '../../asset/asset_page.dart';
import '../../settings/settings_page.dart';
import '../../transaction/screens/transaction_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TransactionListPage(),
    const Center(child: Text('Tab Statistik')),
    const AssetPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
