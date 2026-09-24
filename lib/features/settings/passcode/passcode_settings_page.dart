import 'package:flutter/material.dart';

import '../components/settings_grid.dart';
import 'passcode_screen.dart';
import 'passcode_lock.dart';
import '../../../theme/theme.dart';

String globalSelectedTimeout = "Immediately";
bool globalIsBiometricsOn = true;

class PasscodeSettingsPage extends StatefulWidget {
  const PasscodeSettingsPage({super.key});

  @override
  State<PasscodeSettingsPage> createState() => _PasscodeSettingsPageState();
}

class _PasscodeSettingsPageState extends State<PasscodeSettingsPage> {
  final List<String> _timeoutOptions = [
    "Immediately",
    "After 1 minute",
    "After 5 minutes",
    "After 15 minutes",
    "After 1 hour",
  ];

  void _showTimeoutBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF28282E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Request Passcode",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                height: 1,
                thickness: 1,
              ),

              ..._timeoutOptions.map((option) {
                bool isSelected = globalSelectedTimeout == option;
                return InkWell(
                  onTap: () {
                    setState(() {
                      PasscodeLock.saveTimeout(option);
                    });
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.accentRed
                                    : (isDark ? Colors.white : Colors.black),
                                fontSize: 15,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppTheme.accentRed,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      Divider(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return ValueListenableBuilder<String?>(
      valueListenable: passcodeNotifier,
      builder: (context, passcodeValue, child) {
        bool isOn = passcodeValue != null;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Passcode",
              style: TextStyle(color: textColor, fontSize: 18),
            ),
          ),
          body: ListView(
            children: [
              InkWell(
                onTap: () {
                  if (isOn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasscodeScreen(
                          action: PasscodeAction.turnOff,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasscodeScreen(
                          action: PasscodeAction.create,
                          fromSettings: true,
                        ),
                      ),
                    );
                  }
                },
                child: _buildListItemRow(
                  isOn ? "Turn off Passcode" : "Turn on Passcode",
                  textColor,
                  isDark,
                ),
              ),

              InkWell(
                onTap: () {
                  if (isOn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PasscodeScreen(action: PasscodeAction.change),
                      ),
                    );
                  }
                },
                child: _buildListItemRow(
                  "Change Passcode",
                  textColor,
                  isDark,
                  isDisabled: !isOn,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Biometrics",
                      style: TextStyle(color: textColor, fontSize: 15),
                    ),
                    Switch(
                      value: globalIsBiometricsOn,
                      activeColor: Colors.white,
                      activeTrackColor: AppTheme.accentRed,
                      inactiveThumbColor: isDark ? Colors.grey : Colors.white,
                      inactiveTrackColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      onChanged: (value) =>
                          setState(() => PasscodeLock.saveBiometrics(value)),
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                height: 1,
                thickness: 1,
              ),

              _buildSectionHeader("Request Passcode", isDark),

              InkWell(
                onTap: () => _showTimeoutBottomSheet(isDark),
                child: _buildListItemRow(
                  "Request Passcode",
                  textColor,
                  isDark,
                  value: globalSelectedTimeout,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF151518) : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildListItemRow(
    String title,
    Color textColor,
    bool isDark, {
    String? value,
    bool isDisabled = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDisabled ? Colors.grey.shade400 : textColor,
                  fontSize: 15,
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.accentRed,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        Divider(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
