import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class SelectMainCategoryPage extends StatelessWidget {
  final String categoryName;
  final List<String> mainCategories;

  const SelectMainCategoryPage({
    super.key,
    required this.categoryName,
    required this.mainCategories,
  });

  void _showConfirmationDialog(BuildContext context, String targetCategory) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Text(
            'Category "$categoryName" will now become a subcategory of \'$targetCategory\'. '
            'All subcategories of category "$categoryName" will become subcategories of \'$targetCategory\'. '
            'Do you wish to continue?',
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : Colors.black87,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 12,
            right: 12,
            left: 12,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      "NO",
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context, targetCategory);
                    },
                    child: const Text(
                      "YES",
                      style: TextStyle(
                        color: AppTheme.accentRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBgColor = const Color(0xFF232B45);
    final bgColor = isDark ? AppTheme.background : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: headerBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Expenses Category",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: headerBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Text(
              "Select the main category to move",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: mainCategories.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final category = mainCategories[index];

                if (category == categoryName) return const SizedBox.shrink();

                return ListTile(
                  title: Text(
                    category,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                  onTap: () => _showConfirmationDialog(context, category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
