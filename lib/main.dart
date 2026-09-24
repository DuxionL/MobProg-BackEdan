import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/theme.dart';
import 'features/transaction/transaction_provider.dart';
import '../features/splash/screens/splash_screen.dart';
import 'features/settings/configuration/category_persistence.dart';
import 'features/settings/passcode/passcode_lock.dart';
import 'features/settings/configuration/currency_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme_mode');
  themeNotifier.value = ThemeMode.values.firstWhere(
    (m) => m.name == saved,
    orElse: () => ThemeMode.system,
  );

  await PasscodeLock.init();
  await CurrencySettings.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = TransactionProvider();
        CategoryPersistence.attach(provider);
        return provider;
      },
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, child) {
          return ValueListenableBuilder<Color>(
            valueListenable: accentColorNotifier,
            builder: (context, currentAccent, child) {
              return MaterialApp(
                title: 'Money Manager',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(currentAccent),
                darkTheme: AppTheme.darkTheme,
                themeMode: currentMode,
                builder: (context, child) => AppLockGate(child: child!),
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}