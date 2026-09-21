import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/theme.dart';
import 'features/transaction/transaction_provider.dart';
import '../features/splash/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
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
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}