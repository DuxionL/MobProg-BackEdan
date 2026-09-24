import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/settings_grid.dart';
import '../../../theme/theme.dart';
import 'passcode_screen.dart';
import 'passcode_settings_page.dart';

class PasscodeLock {
  static const String _pinKey = 'passcode_pin';
  static const String _timeoutKey = 'passcode_timeout';
  static const String _biometricsKey = 'passcode_biometrics';
  static const String _pausedAtKey = 'passcode_paused_at';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    passcodeNotifier.value = _prefs.getString(_pinKey);
    globalSelectedTimeout = _prefs.getString(_timeoutKey) ?? "Immediately";
    globalIsBiometricsOn = _prefs.getBool(_biometricsKey) ?? true;

    passcodeNotifier.addListener(() {
      final pin = passcodeNotifier.value;
      if (pin == null) {
        _prefs.remove(_pinKey);
      } else {
        _prefs.setString(_pinKey, pin);
      }
    });
  }

  static void saveTimeout(String value) {
    globalSelectedTimeout = value;
    _prefs.setString(_timeoutKey, value);
  }

  static void saveBiometrics(bool value) {
    globalIsBiometricsOn = value;
    _prefs.setBool(_biometricsKey, value);
  }

  static Duration get _timeout {
    switch (globalSelectedTimeout) {
      case "After 1 minute":
        return const Duration(minutes: 1);
      case "After 5 minutes":
        return const Duration(minutes: 5);
      case "After 15 minutes":
        return const Duration(minutes: 15);
      case "After 1 hour":
        return const Duration(hours: 1);
      default:
        return Duration.zero;
    }
  }

  static void markPaused() {
    _prefs.setInt(_pausedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static bool shouldLock() {
    if (passcodeNotifier.value == null) return false;
    final pausedAt = _prefs.getInt(_pausedAtKey);
    if (pausedAt == null) return true;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(pausedAt),
    );
    return elapsed >= _timeout;
  }
}

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _locked = false;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locked = PasscodeLock.shouldLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
      PasscodeLock.markPaused();
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      if (PasscodeLock.shouldLock()) {
        setState(() => _locked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked)
          Positioned.fill(
            child: PopScope(
              canPop: false,
              child: PasscodeScreen(
                action: PasscodeAction.unlock,
                onUnlocked: () => setState(() => _locked = false),
              ),
            ),
          ),
      ],
    );
  }
}
