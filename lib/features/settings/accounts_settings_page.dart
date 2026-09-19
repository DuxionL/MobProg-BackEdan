import 'package:flutter/material.dart';

class AccountsSettingsPage extends StatelessWidget {
  const AccountsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), 
        ),
        title: const Text("Accounts", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: ListView(
        children: [
          _buildListItem("Account Group"),
          _buildListItem("Accounts Setting"),
          _buildListItem("Deleted account group"),
          _buildListItem("Deleted accounts"),
          _buildListItem("Transfer-Expense setting"),
          _buildListItem("Card expenses display config", value: "A. At the time"),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, {String? value}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
          }, 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
                if (value != null)
                  Text(value, style: TextStyle(color: Colors.red[300], fontSize: 14)),
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey.shade900, height: 1, thickness: 1),
      ],
    );
  }
}