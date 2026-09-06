import 'package:flutter/material.dart';
import 'package:money_manager/features/home/screens/home_page.dart';
import '../../../../../theme/theme.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
  @override
  void initState(){
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async{
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppTheme.accentRed,
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              'Money Manager',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: AppTheme.accentRed,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}