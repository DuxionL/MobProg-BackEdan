import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/theme.dart';
import 'style_page.dart';
import 'income_category_page.dart';
import 'expenses_category_page.dart';
import 'main_currency_page.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  String _subCategory = "OFF";
  String _mainCurrency = "USD (\$)";
  String _subCurrency = "";
  String _startScreen = "Daily";
  String _monthlyStartDate = "Every 1";
  String _weeklyStartDay = "Sunday";
  String _carryOver = "OFF";
  String _swipe = "To Change Date";
  String _colorSetting = "Set. A";
  String _timeInput = "Input Only, Desc.";
  String _showDescription = "OFF";
  String _autocomplete = "ON";
  String _inputOrder = "From Amount";
  String _noteButton = "OFF";
  String _passcode = "OFF";
  String _alarmSetting = "ON";
  String _quickAdd = "OFF";

  @override
  void initState() {
    super.initState();
    _loadAllConfigurations();
  }

  Future<void> _loadAllConfigurations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _subCategory = prefs.getString('cfg_sub_category') ?? "OFF";
      _mainCurrency = prefs.getString('cfg_main_currency') ?? "USD (\$)";
      _subCurrency = prefs.getString('cfg_sub_currency') ?? "";
      _startScreen = prefs.getString('cfg_start_screen') ?? "Daily";
      _monthlyStartDate = prefs.getString('cfg_monthly_start_date') ?? "Every 1";
      _weeklyStartDay = prefs.getString('cfg_weekly_start_day') ?? "Sunday";
      _carryOver = prefs.getString('cfg_carry_over') ?? "OFF";
      _swipe = prefs.getString('cfg_swipe') ?? "To Change Date";
      _colorSetting = prefs.getString('cfg_color_setting') ?? "Set. A";
      _timeInput = prefs.getString('cfg_time_input') ?? "Input Only, Desc.";
      _showDescription = prefs.getString('cfg_show_description') ?? "OFF";
      _autocomplete = prefs.getString('cfg_autocomplete') ?? "ON";
      _inputOrder = prefs.getString('cfg_input_order') ?? "From Amount";
      _noteButton = prefs.getString('cfg_note_button') ?? "OFF";
      _passcode = prefs.getString('cfg_passcode') ?? "OFF";
      _alarmSetting = prefs.getString('cfg_alarm_setting') ?? "ON";
      _quickAdd = prefs.getString('cfg_quick_add') ?? "OFF";
    });
  }

  Future<void> _saveConfig(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showSelectionSheet(
    String title,
    List<String> options,
    String currentValue,
    Function(String) onSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF28282E) : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
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
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                height: 1,
                thickness: 1,
              ),
              ...options.map((option) {
                bool isSelected = currentValue == option;
                return InkWell(
                  onTap: () {
                    onSelected(option);
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
                            : Colors.grey.shade300,
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

  String _toggleOnOff(String current) => current == "ON" ? "OFF" : "ON";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

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
          "Configuration",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Category/Repeat", isDark),
          _buildListItem(
            "Income Category Setting",
            textColor,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncomeCategoryPage(),
                ),
              );
            },
          ),
          _buildListItem(
            "Expenses Category Setting",
            textColor,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseCategoryPage(),
                ),
              );
            },
          ),
          _buildListItem(
            "Subcategory",
            textColor,
            isDark,
            value: _subCategory,
            onTap: () {
              final newVal = _toggleOnOff(_subCategory);
              setState(() => _subCategory = newVal);
              _saveConfig('cfg_sub_category', newVal);
            },
          ),
          _buildListItem("Budget Setting", textColor, isDark, onTap: () {}),
          _buildListItem("Repeat Setting", textColor, isDark, onTap: () {}),

          _buildSectionHeader("Configuration", isDark),
          _buildListItem(
            "Main Currency Setting",
            textColor,
            isDark,
            value: _mainCurrency,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainCurrencySettingPage(),
                ),
              );
              if (result != null) {
                final formatted =
                    "${result['currency'].code} (${result['currency'].displaySymbol})";
                setState(() {
                  _mainCurrency = formatted;
                });
                _saveConfig('cfg_main_currency', formatted);
              }
            },
          ),
          _buildListItem(
            "Sub Currency Setting",
            textColor,
            isDark,
            value: _subCurrency,
            onTap: () {},
          ),
          _buildListItem(
            "Start Screen (Daily/Calendar)",
            textColor,
            isDark,
            value: _startScreen,
            onTap: () {
              _showSelectionSheet(
                "Start Screen",
                ["Daily", "Calendar", "Weekly", "Monthly", "Summary"],
                _startScreen,
                (val) {
                  setState(() => _startScreen = val);
                  _saveConfig('cfg_start_screen', val);
                },
              );
            },
          ),
          _buildListItem(
            "Monthly Start Date",
            textColor,
            isDark,
            value: _monthlyStartDate,
            onTap: () {
              _showSelectionSheet(
                "Monthly Start Date",
                ["Every 1", "Every 2", "Every 5", "Every 15", "End of Month"],
                _monthlyStartDate,
                (val) {
                  setState(() => _monthlyStartDate = val);
                  _saveConfig('cfg_monthly_start_date', val);
                },
              );
            },
          ),
          _buildListItem(
            "Weekly Start Day",
            textColor,
            isDark,
            value: _weeklyStartDay,
            onTap: () {
              _showSelectionSheet(
                "Weekly Start Day",
                ["Sunday", "Monday", "Saturday"],
                _weeklyStartDay,
                (val) {
                  setState(() => _weeklyStartDay = val);
                  _saveConfig('cfg_weekly_start_day', val);
                },
              );
            },
          ),
          _buildListItem(
            "Carry-over Setting",
            textColor,
            isDark,
            value: _carryOver,
            onTap: () {
              final newVal = _toggleOnOff(_carryOver);
              setState(() => _carryOver = newVal);
              _saveConfig('cfg_carry_over', newVal);
            },
          ),
          _buildListItem(
            "Swipe",
            textColor,
            isDark,
            value: _swipe,
            onTap: () {
              _showSelectionSheet(
                "Swipe",
                ["To Change Date", "To Change Tab", "Do Nothing"],
                _swipe,
                (val) {
                  setState(() => _swipe = val);
                  _saveConfig('cfg_swipe', val);
                },
              );
            },
          ),
          _buildListItem(
            "Income-Expenses Color Setting",
            textColor,
            isDark,
            value: _colorSetting,
            onTap: () {
              _showSelectionSheet(
                "Color Setting",
                ["Set. A", "Set. B (Reverse)"],
                _colorSetting,
                (val) {
                  setState(() => _colorSetting = val);
                  _saveConfig('cfg_color_setting', val);
                },
              );
            },
          ),
          _buildListItem(
            "Time Input",
            textColor,
            isDark,
            value: _timeInput,
            onTap: () {},
          ),
          _buildListItem(
            "Show description",
            textColor,
            isDark,
            value: _showDescription,
            onTap: () {
              final newVal = _toggleOnOff(_showDescription);
              setState(() => _showDescription = newVal);
              _saveConfig('cfg_show_description', newVal);
            },
          ),
          _buildListItem(
            "Autocomplete",
            textColor,
            isDark,
            value: _autocomplete,
            onTap: () {
              final newVal = _toggleOnOff(_autocomplete);
              setState(() => _autocomplete = newVal);
              _saveConfig('cfg_autocomplete', newVal);
            },
          ),
          _buildListItem(
            "Input order",
            textColor,
            isDark,
            value: _inputOrder,
            onTap: () {
              _showSelectionSheet(
                "Input order",
                ["From Amount", "From Category"],
                _inputOrder,
                (val) {
                  setState(() => _inputOrder = val);
                  _saveConfig('cfg_input_order', val);
                },
              );
            },
          ),
          _buildListItem(
            "Note button setting",
            textColor,
            isDark,
            value: _noteButton,
            onTap: () {
              final newVal = _toggleOnOff(_noteButton);
              setState(() => _noteButton = newVal);
              _saveConfig('cfg_note_button', newVal);
            },
          ),

          _buildSectionHeader("Other", isDark),
          _buildListItem(
            "Passcode",
            textColor,
            isDark,
            value: _passcode,
            onTap: () {
              final newVal = _toggleOnOff(_passcode);
              setState(() => _passcode = newVal);
              _saveConfig('cfg_passcode', newVal);
            },
          ),
          _buildListItem(
            "Alarm Setting",
            textColor,
            isDark,
            value: _alarmSetting,
            onTap: () {
              final newVal = _toggleOnOff(_alarmSetting);
              setState(() => _alarmSetting = newVal);
              _saveConfig('cfg_alarm_setting', newVal);
            },
          ),
          _buildListItem(
            "Quick add",
            textColor,
            isDark,
            value: _quickAdd,
            onTap: () {
              final newVal = _toggleOnOff(_quickAdd);
              setState(() => _quickAdd = newVal);
              _saveConfig('cfg_quick_add', newVal);
            },
          ),
          _buildListItem(
            "Style",
            textColor,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StylePage()),
              );
            },
          ),
          _buildListItem("Widget Settings", textColor, isDark, onTap: () {}),
          _buildListItem("Language Setting", textColor, isDark, onTap: () {}),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF151518) : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.grey : Colors.grey.shade700,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListItem(
    String title,
    Color textColor,
    bool isDark, {
    String? value,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 15)),
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
        ),
        Divider(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}