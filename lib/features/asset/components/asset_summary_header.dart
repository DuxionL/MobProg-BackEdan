import 'package:flutter/material.dart';

class AssetSummaryHeader extends StatelessWidget {
  const AssetSummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade900, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildColumn("Assets", "10,900.00", Colors.blue[400]!),
          _buildColumn("Liabilities", "100.00", Colors.red[400]!),
          _buildColumn("Total", "10,800.00", Colors.white),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, String amount, Color amountColor) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Text(amount, style: TextStyle(color: amountColor, fontSize: 15)),
      ],
    );
  }
}