import 'package:flutter/material.dart';

import '../configuration_page.dart';
import '../accounts_settings_page.dart';
import '../passcode_screen.dart';

final ValueNotifier<String?> passcodeNotifier = ValueNotifier<String?>(null);

class SettingsGrid extends StatelessWidget {
  const SettingsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: passcodeNotifier,
      builder: (context, passcodeValue, child) {
        bool isPasscodeOn = passcodeValue != null; 

        final List<Map<String, dynamic>> menuItems = [
          {'icon': Icons.settings_outlined, 'label': 'Configuration'},
          {'icon': Icons.account_balance_wallet_outlined, 'label': 'Accounts'},
          {'icon': isPasscodeOn ? Icons.lock_outline : Icons.lock_open_outlined, 'label': 'Passcode'},
          {'icon': Icons.calculate_outlined, 'label': 'CalcBox'},
          {'icon': Icons.desktop_windows_outlined, 'label': 'PC Manager'},
          {'icon': Icons.restore, 'label': 'Backup'},
          {'icon': Icons.mail_outline, 'label': 'Feedback'},
          {'icon': Icons.help_outline, 'label': 'Help'},
          {'icon': Icons.thumb_up_outlined, 'label': 'Recommend'},
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuItems.length,
          padding: const EdgeInsets.only(top: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                if (menuItems[index]['label'] == 'Configuration') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfigurationPage(),
                    ),
                  );
                } else if (menuItems[index]['label'] == 'Accounts') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountsSettingsPage(),
                    ),
                  );
                } else if (menuItems[index]['label'] == 'Passcode') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasscodeScreen(
                        action: isPasscodeOn
                            ? PasscodeAction.authenticate
                            : PasscodeAction.create,
                      ),
                    ),
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(menuItems[index]['icon'], color: Colors.white, size: 28),
                  const SizedBox(height: 10),
                  Text(
                    menuItems[index]['label'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
