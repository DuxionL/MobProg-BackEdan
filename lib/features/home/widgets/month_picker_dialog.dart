import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const MonthPickerDialog({super.key, required this.initialDate});

  static Future<DateTime?> show(BuildContext context, DateTime initialDate) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => MonthPickerDialog(initialDate: initialDate),
    );
  }

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth; // 1-12

  static const List<String> _monthLabels = [
    'JAN', 'FEB', 'MAR', 'APR',
    'MEI', 'JUN', 'JUL', 'AGU',
    'SEP', 'OKT', 'NOV', 'DES',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    Navigator.of(context).pop(DateTime(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2E3352),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Text(
                  'Tanggal',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectThisMonth,
                  child: const Text(
                    'BULAN INI',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: AppTheme.textPrimary),
                  onPressed: () => setState(() => _selectedYear--),
                ),
                Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: AppTheme.textPrimary),
                  onPressed: () => setState(() => _selectedYear++),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (context, index) {
                final monthNumber = index + 1;
                final isSelected = monthNumber == _selectedMonth;

                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pop(DateTime(_selectedYear, monthNumber));
                  },
                  child: Center(
                    child: Text(
                      _monthLabels[index],
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.accentRed
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}