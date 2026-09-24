import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RegisterResult { success, invalid, ownCode, alreadyRegistered }

class RecommendStore {
  static const String _codeKey = 'recommend_code';
  static const String _pointsKey = 'recommend_points';
  static const String _registeredKey = 'recommend_registered';
  static const String _unlockedKey = 'recommend_unlocked';

  static final ValueNotifier<String> code = ValueNotifier<String>('');
  static final ValueNotifier<int> points = ValueNotifier<int>(0);
  static final ValueNotifier<bool> hasRegistered = ValueNotifier<bool>(false);
  static final ValueNotifier<Set<String>> unlocked = ValueNotifier<Set<String>>(
    {},
  );
  static bool _loaded = false;

  static String _generateCode() {
    const chars = '0123456789ABCDEF';
    final random = Random.secure();
    return List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static bool isValidCode(String value) {
    return RegExp(r'^[0-9A-F]{10}$').hasMatch(value);
  }

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    var saved = prefs.getString(_codeKey);
    if (saved == null) {
      saved = _generateCode();
      await prefs.setString(_codeKey, saved);
    }

    code.value = saved;
    points.value = prefs.getInt(_pointsKey) ?? 0;
    hasRegistered.value = prefs.getBool(_registeredKey) ?? false;
    unlocked.value = (prefs.getStringList(_unlockedKey) ?? []).toSet();
  }

  static Future<RegisterResult> registerCode(String input) async {
    final value = input.trim().toUpperCase();
    if (!isValidCode(value)) return RegisterResult.invalid;
    if (value == code.value) return RegisterResult.ownCode;
    if (hasRegistered.value) return RegisterResult.alreadyRegistered;

    hasRegistered.value = true;
    points.value = points.value + 1;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_registeredKey, true);
    await prefs.setInt(_pointsKey, points.value);
    return RegisterResult.success;
  }

  static Future<bool> redeem(String id, int cost) async {
    if (unlocked.value.contains(id) || points.value < cost) return false;

    points.value = points.value - cost;
    unlocked.value = {...unlocked.value, id};

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, points.value);
    await prefs.setStringList(_unlockedKey, unlocked.value.toList());
    return true;
  }
}
