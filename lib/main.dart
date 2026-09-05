import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/theme.dart';
import 'features/home/screens/home_page.dart';
import 'features/transaction/transaction_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'Money Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const HomePage(),
      ),
    );
  }
}
