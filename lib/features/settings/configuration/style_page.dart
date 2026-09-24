import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/theme.dart';

class StylePage extends StatelessWidget {
  const StylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
        final textColor = isDark
            ? AppTheme.textPrimary
            : AppTheme.textPrimaryLight;
        final dividerColor = isDark
            ? Colors.grey.shade900
            : Colors.grey.shade300;
        final iconColor = isDark
            ? AppTheme.textSecondary
            : AppTheme.textSecondaryLight;

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
              "Style",
              style: TextStyle(color: textColor, fontSize: 18),
            ),
          ),
          body: ListView(
            children: [
              _buildStyleOption(
                icon: Icons.sync,
                title: "System Mode",
                mode: ThemeMode.system,
                currentMode: currentMode,
                textColor: textColor,
                iconColor: iconColor,
                dividerColor: dividerColor,
              ),
              _buildStyleOption(
                icon: Icons.nightlight_round,
                title: "Dark Mode",
                mode: ThemeMode.dark,
                currentMode: currentMode,
                textColor: textColor,
                iconColor: iconColor,
                dividerColor: dividerColor,
              ),
              _buildStyleOption(
                icon: Icons.light_mode_outlined,
                title: "Light Mode",
                mode: ThemeMode.light,
                currentMode: currentMode,
                textColor: textColor,
                iconColor: iconColor,
                dividerColor: dividerColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyleOption({
    required IconData icon,
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required Color textColor,
    required Color iconColor,
    required Color dividerColor,
  }) {
    bool isSelected = currentMode == mode;
    return Column(
      children: [
        InkWell(
          onTap: () async {
            themeNotifier.value = mode;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('theme_mode', mode.name);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentRed
                          : Colors.grey.shade600,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accentRed,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        Divider(color: dividerColor, height: 1, thickness: 1),
      ],
    );
  }
}
