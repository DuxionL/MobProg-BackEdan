import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.message = 'No data available',
    this.icon = Icons.savings_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).textTheme.bodySmall!.color;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}