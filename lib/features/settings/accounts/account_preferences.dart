import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPreferences {
  static const String _transferKey = 'transfer_expense_items';
  static const String _cardModeKey = 'card_expense_display';

  static final ValueNotifier<Set<String>> transferExpenseIds =
      ValueNotifier<Set<String>>({});
  static final ValueNotifier<String> cardDisplayMode = ValueNotifier<String>(
    'A',
  );
  static bool _loaded = false;

  static String get cardDisplayLabel =>
      cardDisplayMode.value == 'B' ? 'B. Lump sum' : 'A. At the time';

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    transferExpenseIds.value = (prefs.getStringList(_transferKey) ?? [])
        .toSet();
    cardDisplayMode.value = prefs.getString(_cardModeKey) ?? 'A';
  }

  static Future<void> toggleTransferExpense(String itemId) async {
    final updated = Set<String>.from(transferExpenseIds.value);
    if (!updated.remove(itemId)) {
      updated.add(itemId);
    }
    transferExpenseIds.value = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_transferKey, updated.toList());
  }

  static Future<void> setCardDisplayMode(String mode) async {
    cardDisplayMode.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardModeKey, mode);
  }
}
