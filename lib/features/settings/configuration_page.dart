import 'package:flutter/material.dart';

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key});

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
        title: const Text("Configuration", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Category/Repeat"),
          _buildListItem("Income Category Setting"),
          _buildListItem("Expenses Category Setting"),
          _buildListItem("Subcategory", value: "OFF"),
          _buildListItem("Budget Setting"),
          _buildListItem("Repeat Setting"),

          _buildSectionHeader("Configuration"),
          _buildListItem("Main Currency Setting", value: "USD (\$)"),
          _buildListItem("Sub Currency Setting"),
          _buildListItem("Start Screen (Daily/Calendar)", value: "Daily"),
          _buildListItem("Monthly Start Date", value: "Every 1"),
          _buildListItem("Weekly Start Day", value: "Sunday"),
          _buildListItem("Carry-over Setting", value: "OFF"),
          _buildListItem("Swipe", value: "To Change Date"),
          _buildListItem("Income-Expenses Color Setting", value: "Set. A"),
          _buildListItem("Time Input", value: "Input Only, Desc."),
          _buildListItem("Show description", value: "OFF"),
          _buildListItem("Autocomplete", value: "ON"),
          _buildListItem("Input order", value: "From Amount"),
          _buildListItem("Note button setting", value: "OFF"),

          _buildSectionHeader("Other"),
          _buildListItem("Passcode", value: "OFF"),
          _buildListItem("Alarm Setting", value: "ON"),
          _buildListItem("Quick add", value: "OFF"),
          _buildListItem("Style"),
          _buildListItem("Widget Settings"),
          _buildListItem("Language Setting"),
          
          const SizedBox(height: 20), 
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF151518), 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  Widget _buildListItem(String title, {String? value}) {
    return Column(
      children: [
        InkWell(
          onTap: () {}, 
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