import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import 'account_group_page.dart';
import 'account_list_page.dart';
import 'account_preferences.dart';
import 'card_expenses_config_page.dart';
import 'deleted_account_pages.dart';
import 'transfer_expense_page.dart';

class AccountsSettingsPage extends StatefulWidget {
  const AccountsSettingsPage({super.key});

  @override
  State<AccountsSettingsPage> createState() => _AccountsSettingsPageState();
}

class _AccountsSettingsPageState extends State<AccountsSettingsPage> {
  @override
  void initState() {
    super.initState();
    AccountPreferences.load();
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

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
          _buildListItem(
            "Account Group",
            textColor,
            dividerColor,
            onTap: () => _open(const AccountGroupPage()),
          ),
          _buildListItem(
            "Accounts Setting",
            textColor,
            dividerColor,
            onTap: () => _open(const AccountListPage()),
          ),
          _buildListItem(
            "Deleted account group",
            textColor,
            dividerColor,
            onTap: () => _open(const DeletedAccountGroupPage()),
          ),
          _buildListItem(
            "Deleted accounts",
            textColor,
            dividerColor,
            onTap: () => _open(const DeletedAccountsPage()),
          ),
          _buildListItem(
            "Transfer-Expense setting",
            textColor,
            dividerColor,
            onTap: () => _open(const TransferExpensePage()),
          ),
          ValueListenableBuilder<String>(
            valueListenable: AccountPreferences.cardDisplayMode,
            builder: (context, mode, child) {
              return _buildListItem(
                "Card expenses display config",
                textColor,
                dividerColor,
                value: AccountPreferences.cardDisplayLabel,
                onTap: () => _open(const CardExpensesConfigPage()),
              );
            },
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
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap ?? () {},
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
