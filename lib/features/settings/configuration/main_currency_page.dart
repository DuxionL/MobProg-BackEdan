import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_settings.dart';
import '../../../theme/theme.dart';

class Currency {
  final String code;
  final String country;
  final String symbol;
  final String displaySymbol;

  const Currency({
    required this.code,
    required this.country,
    required this.symbol,
    required this.displaySymbol,
  });

  String get fullName => '$code - $country ($symbol)';
}

class MainCurrencySettingPage extends StatefulWidget {
  const MainCurrencySettingPage({super.key});

  @override
  State<MainCurrencySettingPage> createState() =>
      _MainCurrencySettingPageState();
}

class _MainCurrencySettingPageState extends State<MainCurrencySettingPage> {
  final List<Currency> _currencies = const [
    Currency(code: 'USD', country: 'USA', symbol: 'US\$', displaySymbol: '\$'),
    Currency(
      code: 'EUR',
      country: 'Euro Member Countries',
      symbol: '€',
      displaySymbol: '€',
    ),
    Currency(code: 'JPY', country: 'Japan', symbol: '¥', displaySymbol: '¥'),
    Currency(code: 'CNY', country: 'China', symbol: '¥', displaySymbol: '¥'),
    Currency(
      code: 'IDR',
      country: 'Indonesia',
      symbol: 'Rp',
      displaySymbol: 'Rp',
    ),
    Currency(
      code: 'SGD',
      country: 'Singapore',
      symbol: 'S\$',
      displaySymbol: 'S\$',
    ),
    Currency(
      code: 'MYR',
      country: 'Malaysia',
      symbol: 'RM',
      displaySymbol: 'RM',
    ),
    Currency(code: 'THB', country: 'Thailand', symbol: '฿', displaySymbol: '฿'),
    Currency(
      code: 'PHP',
      country: 'Philippines',
      symbol: '₱',
      displaySymbol: '₱',
    ),
    Currency(code: 'VND', country: 'Vietnam', symbol: '₫', displaySymbol: '₫'),
    Currency(
      code: 'BND',
      country: 'Brunei',
      symbol: 'B\$',
      displaySymbol: 'B\$',
    ),
  ];

  late Currency _selectedCurrency;
  String _unitPosition = 'Front';
  String _decimalPoint = '1.00';

  final List<String> _decimalOptions = [
    'None',
    '1.0',
    '1.00',
    '1.000',
    '1.0000',
    '1.00000',
    '1.00000000',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _currencies.first;
    _loadSavedSettings();
  }

  // Baca pilihan tersimpan dari HP saat halaman dibuka
  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code');
    final position = prefs.getString('currency_position');
    final decimal = prefs.getString('currency_decimal');

    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCurrency = _currencies.firstWhere(
        (c) => c.code == code,
        orElse: () => _currencies.first,
      );
      if (position != null) {
        _unitPosition = position;
      }
      if (decimal != null && _decimalOptions.contains(decimal)) {
        _decimalPoint = decimal;
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', _selectedCurrency.code);
    await prefs.setString('currency_symbol', _selectedCurrency.displaySymbol);
    await prefs.setString('currency_position', _unitPosition);
    await prefs.setString('currency_decimal', _decimalPoint);
    await CurrencySettings.load();
  }

  String _getFormattedPreview([String? positionOverride]) {
    final pos = positionOverride ?? _unitPosition;
    String numberPart = '1,000';

    if (_decimalPoint != 'None') {
      final decimals = _decimalPoint.split('.')[1];
      numberPart += '.$decimals';
    }

    final symbol = _selectedCurrency.displaySymbol;
    return pos == 'Front' ? '$symbol $numberPart' : '$numberPart $symbol';
  }

  void _showUnitPositionSheet(bool isDark) {
    _showCustomBottomSheet(
      title: 'Unit position',
      isDark: isDark,
      child: Column(
        children: [
          _buildSheetOption(
            title: 'Front (${_getFormattedPreview('Front')})',
            isSelected: _unitPosition == 'Front',
            isDark: isDark,
            onTap: () {
              setState(() => _unitPosition = 'Front');
              Navigator.pop(context);
            },
          ),
          _buildSheetOption(
            title: 'End (${_getFormattedPreview('End')})',
            isSelected: _unitPosition == 'End',
            isDark: isDark,
            onTap: () {
              setState(() => _unitPosition = 'End');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDecimalPointSheet(bool isDark) {
    _showCustomBottomSheet(
      title: 'Decimal point',
      isDark: isDark,
      child: Column(
        children: _decimalOptions.map((opt) {
          return _buildSheetOption(
            title: opt,
            isSelected: _decimalPoint == opt,
            isDark: isDark,
            onTap: () {
              setState(() => _decimalPoint = opt);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showCustomBottomSheet({
    required String title,
    required bool isDark,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF28282E) : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: isDark ? Colors.white : Colors.black,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                height: 1,
              ),
              child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetOption({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
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
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.accentRed
                        : (isDark ? Colors.white : Colors.black),
                    fontSize: 15,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check, color: AppTheme.accentRed, size: 20),
              ],
            ),
          ),
        ),
        Divider(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          height: 1,
        ),
      ],
    );
  }

  void _openCurrencyPicker(bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _CurrencyPickerPage(
          currencies: _currencies,
          selected: _selectedCurrency,
          isDark: isDark,
          onSelect: (currency) {
            setState(() => _selectedCurrency = currency);
          },
        ),
      ),
    );
  }

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
          "Main Currency Setting",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => _openCurrencyPicker(isDark),
            style: TextButton.styleFrom(
              side: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Change",
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  _selectedCurrency.fullName,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _getFormattedPreview(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
            height: 1,
          ),
          _buildListItem(
            title: "Unit position",
            value: _unitPosition,
            textColor: textColor,
            isDark: isDark,
            onTap: () => _showUnitPositionSheet(isDark),
          ),
          _buildListItem(
            title: "Decimal point",
            value: _decimalPoint,
            textColor: textColor,
            isDark: isDark,
            onTap: () => _showDecimalPointSheet(isDark),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await _saveSettings();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.pop(context, {
                    'currency': _selectedCurrency,
                    'position': _unitPosition,
                    'decimal': _decimalPoint,
                  });
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required String value,
    required Color textColor,
    required bool isDark,
    required VoidCallback onTap,
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
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                Text(value, style: TextStyle(color: textColor, fontSize: 15)),
              ],
            ),
          ),
        ),
        Divider(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
          height: 1,
        ),
      ],
    );
  }
}

class _CurrencyPickerPage extends StatelessWidget {
  final List<Currency> currencies;
  final Currency selected;
  final bool isDark;
  final Function(Currency) onSelect;

  const _CurrencyPickerPage({
    required this.currencies,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
          "Main Currency Setting",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ListView.separated(
        itemCount: currencies.length,
        separatorBuilder: (context, index) => Divider(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final item = currencies[index];
          final isSelected = item.code == selected.code;

          return InkWell(
            onTap: () {
              onSelect(item);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                item.fullName,
                style: TextStyle(
                  color: isSelected ? AppTheme.accentRed : textColor,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
