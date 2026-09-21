import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class AccountsSettingsPage extends StatelessWidget {
  const AccountsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Accounts",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ListView(
        children: [
          _buildListItem("Account Group", textColor, dividerColor),
          _buildListItem("Accounts Setting", textColor, dividerColor),
          _buildListItem("Deleted account group", textColor, dividerColor),
          _buildListItem("Deleted accounts", textColor, dividerColor),
          _buildListItem("Transfer-Expense setting", textColor, dividerColor),
          _buildListItem(
            "Card expenses display config",
            textColor,
            dividerColor,
            value: "A. At the time",
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    String title,
    Color textColor,
    Color dividerColor, {
    String? value,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 15)),
                if (value != null)
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.accentRed,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Divider(color: dividerColor, height: 1, thickness: 1),
      ],
    );
  }
}
