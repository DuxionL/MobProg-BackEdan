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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        border: Border(bottom: BorderSide(color: Colors.grey.shade900, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildColumn("Assets", assets.toStringAsFixed(2), Colors.blue[400]!),
          _buildColumn("Liabilities", liabilities.toStringAsFixed(2), Colors.red[400]!),
          _buildColumn("Total", total.toStringAsFixed(2), Colors.white),
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