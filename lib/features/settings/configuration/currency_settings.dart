import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyConfig {
  final String symbol;
  final String position;
  final int decimals;

  const CurrencyConfig({
    required this.symbol,
    required this.position,
    required this.decimals,
  });
}

class CurrencySettings {
  static final ValueNotifier<CurrencyConfig> notifier = ValueNotifier(
    const CurrencyConfig(symbol: '\$', position: 'Front', decimals: 2),
  );

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final decimal = prefs.getString('currency_decimal') ?? '1.00';
    notifier.value = CurrencyConfig(
      symbol: prefs.getString('currency_symbol') ?? '\$',
      position: prefs.getString('currency_position') ?? 'Front',
      decimals: decimal == 'None' ? 0 : decimal.split('.')[1].length,
    );
  }

  static String format(double amount) {
    final c = notifier.value;
    final fixed = amount.abs().toStringAsFixed(c.decimals);
    final parts = fixed.split('.');
    final grouped = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    final number = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
    final sign = amount < 0 ? '-' : '';
    return c.position == 'Front'
        ? '$sign${c.symbol} $number'
        : '$sign$number ${c.symbol}';
  }
}
