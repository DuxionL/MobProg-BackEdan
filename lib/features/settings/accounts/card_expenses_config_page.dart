import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import 'account_preferences.dart';

class CardExpensesConfigPage extends StatefulWidget {
  const CardExpensesConfigPage({super.key});

  @override
  State<CardExpensesConfigPage> createState() => _CardExpensesConfigPageState();
}

class _CardExpensesConfigPageState extends State<CardExpensesConfigPage> {
  @override
  void initState() {
    super.initState();
    AccountPreferences.load();
  }

  Widget _buildOption(String label, String mode, String selectedMode) {
    final isSelected = selectedMode == mode;
    return Expanded(
      child: SizedBox(
        height: 44,
        child: isSelected
            ? ElevatedButton(
                onPressed: () => AccountPreferences.setCardDisplayMode(mode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : OutlinedButton(
                onPressed: () => AccountPreferences.setCardDisplayMode(mode),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.accentRed,
                    fontSize: 16,
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;

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
          "Card expenses display config",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: AccountPreferences.cardDisplayMode,
        builder: (context, mode, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Text(
                  "Card expenses display config",
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  "The time credit card paid. You can configure your credit "
                  "card spendings to be reflected either on the moment of "
                  "usage, or show it as a lump sum on your card payment date.",
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                ),
              ),
              Divider(color: dividerColor, height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildOption("A. At the time", 'A', mode),
                    const SizedBox(width: 16),
                    _buildOption("B. Lump sum", 'B', mode),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
