import 'package:flutter/material.dart';
import 'package:money_manager/common/currency_formatter.dart';

class StatisticHeaderButton extends StatelessWidget {
  final String title;
  final double amount;
  final bool selected;
  final VoidCallback onTap;

  const StatisticHeaderButton({
    super.key,
    required this.title,
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;

    return InkWell(
        onTap: onTap,
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.redAccent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: selected ? activeColor : Colors.grey,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                formatRupiah(amount),
                style: TextStyle(
                  fontSize: 16,
                  color: selected ? activeColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
    );
  }
}