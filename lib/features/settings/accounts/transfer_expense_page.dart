import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import 'account_preferences.dart';
import 'account_store.dart';

class TransferExpensePage extends StatefulWidget {
  const TransferExpensePage({super.key});

  @override
  State<TransferExpensePage> createState() => _TransferExpensePageState();
}

class _TransferExpensePageState extends State<TransferExpensePage> {
  @override
  void initState() {
    super.initState();
    AccountStore.load();
    AccountPreferences.load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;
    final headerBg = isDark ? const Color(0xFF151518) : Colors.grey.shade200;

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
          "Transfer-Expense setting",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          AccountStore.groups,
          AccountStore.items,
          AccountPreferences.transferExpenseIds,
        ]),
        builder: (context, child) {
          final selected = AccountPreferences.transferExpenseIds.value;
          final items = AccountStore.visibleItems;
          final children = <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Amount transferred from the regular account to the selected "
                "account is shown as an expense on the Trans tab and the Stats "
                "tab. This is a feature that displays the transferred amount "
                "as an expense to the accounts that are difficult to "
                "liquidate, such as savings, investments, loans, and "
                "insurance. This is not applicable to cash/bank/card/check "
                "card account groups. The transferred amount from the "
                "selected account to the regular account will be displayed as "
                "an income.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            Divider(color: dividerColor, height: 1, thickness: 1),
          ];

          for (final group in AccountStore.visibleGroups) {
            if (group.isProtected) continue;
            final groupItems = items.where((i) => i.groupId == group.id);
            if (groupItems.isEmpty) continue;

            children.add(
              Container(
                width: double.infinity,
                color: headerBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Text(
                  group.name,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            );

            for (final item in groupItems) {
              final isSelected = selected.contains(item.id);
              children.add(
                Column(
                  children: [
                    InkWell(
                      onTap: () =>
                          AccountPreferences.toggleTransferExpense(item.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(color: textColor, fontSize: 15),
                            ),
                            if (isSelected)
                              Icon(Icons.check, color: textColor, size: 22),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: dividerColor, height: 1, thickness: 1),
                  ],
                ),
              );
            }
          }

          return ListView(children: children);
        },
      ),
    );
  }
}
