import 'package:flutter/material.dart';

import 'components/settings_grid.dart';
import 'passcode_screen.dart';

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

  void _showTimeoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF28282E),
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
                    const Text(
                      "Request Passcode",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade800, height: 1, thickness: 1),

              ..._timeoutOptions.map((option) {
                bool isSelected = globalSelectedTimeout == option;

                return InkWell(
                  onTap: () {
                    setState(() {
                      globalSelectedTimeout = option;
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
                                    ? Colors.red[300]
                                    : Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                color: Colors.red[300],
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade800,
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
    return ValueListenableBuilder<String?>(
      valueListenable: passcodeNotifier,
      builder: (context, passcodeValue, child) {
        bool isOn = passcodeValue != null;

        return Scaffold(
          backgroundColor: const Color(0xFF1E1E24),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E24),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Passcode",
              style: TextStyle(color: Colors.white, fontSize: 18),
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
                child: _buildListItemRow("Change Passcode", isDisabled: !isOn),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Biometrics",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Switch(
                      value: globalIsBiometricsOn,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.red[300],
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade800,
                      onChanged: (value) =>
                          setState(() => globalIsBiometricsOn = value),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade900, height: 1, thickness: 1),

              _buildSectionHeader("Request Passcode"),

              InkWell(
                onTap: _showTimeoutBottomSheet,
                child: _buildListItemRow(
                  "Request Passcode",
                  value: globalSelectedTimeout,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF151518),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  Widget _buildListItemRow(
    String title, {
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
                  color: isDisabled ? Colors.grey.shade700 : Colors.white,
                  fontSize: 15,
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: TextStyle(color: Colors.red[300], fontSize: 14),
                ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade900, height: 1, thickness: 1),
      ],
    );
  }
}
