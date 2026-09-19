import 'package:flutter/material.dart';

class AssetSummaryHeader extends StatelessWidget {
  final double assets;
  final double liabilities;
  final double total;

  const AssetSummaryHeader({
    super.key,
    required this.assets,
    required this.liabilities,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF151518) : Colors.white;
    final headerColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final totalColor = isDark ? Colors.white : Colors.black;
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Container(
      color: bgColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  "Assets",
                  assets,
                  Colors.blue[400]!,
                  headerColor,
                ),
                _buildSummaryItem(
                  "Liabilities",
                  liabilities,
                  Colors.red[400]!,
                  headerColor,
                ),
                _buildSummaryItem("Total", total, totalColor, headerColor),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    Color amountColor,
    Color headerColor,
  ) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: headerColor, fontSize: 13)),
        const SizedBox(height: 8),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(color: amountColor, fontSize: 16),
        ),
      ],
    );
  }
}
