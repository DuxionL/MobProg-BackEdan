import 'package:flutter/material.dart';

class StatisticHeader extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String?> onChanged;

  const StatisticHeader({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(
              value: "Weekly",
              child: Text("Weekly"),
            ),
            DropdownMenuItem(
              value: "Monthly",
              child: Text("Monthly"),
            ),
            DropdownMenuItem(
              value: "Yearly",
              child: Text("Yearly"),
            ),
            DropdownMenuItem(
              value: "Period",
              child: Text("Period"),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}