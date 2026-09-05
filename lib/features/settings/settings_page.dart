import 'package:flutter/material.dart';
import 'components/settings_grid.dart';
import 'components/search_bar_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        elevation: 0,
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text("4.12.8 AD", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SearchBarWidget(),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SettingsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}