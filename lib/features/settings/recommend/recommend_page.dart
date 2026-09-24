import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/theme.dart';
import 'recommend_store.dart';

class _Reward {
  final String id;
  final String name;
  final String? subtitle;
  final IconData icon;
  final int cost;

  const _Reward({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    this.subtitle,
  });
}

const List<_Reward> _rewards = [
  _Reward(
    id: 'pc_manager',
    name: 'PC Manager',
    icon: Icons.desktop_windows_outlined,
    cost: 1,
  ),
  _Reward(
    id: 'unlimited_accounts',
    name: 'Unlimited Account Numbers.',
    subtitle: '[15 → Unlimited]',
    icon: Icons.all_inclusive,
    cost: 1,
  ),
];

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    RecommendStore.load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _registerMessage(RegisterResult result) {
    switch (result) {
      case RegisterResult.success:
        return "Code registered. You earned 1 point!";
      case RegisterResult.invalid:
        return "Invalid code. A code has 10 characters (0-9, A-F).";
      case RegisterResult.ownCode:
        return "You can't register your own code.";
      case RegisterResult.alreadyRegistered:
        return "You have already registered a code.";
    }
  }

  Future<void> _showRegisterDialog(bool isDark) async {
    _codeController.clear();
    final input = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF28282E)
              : AppTheme.surfaceLight,
          title: Text(
            "Code Reg",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: _codeController,
            maxLength: 10,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Enter your friend's code",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentRed, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _codeController.text),
              child: const Text(
                "Register",
                style: TextStyle(color: AppTheme.accentRed),
              ),
            ),
          ],
        );
      },
    );

    if (input == null) return;
    final result = await RecommendStore.registerCode(input);
    if (!mounted) return;
    _showSnack(_registerMessage(result));
  }

  void _showInfoDialog(bool isDark) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF28282E)
              : AppTheme.surfaceLight,
          title: Text(
            "More Information",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Share your code with friends. Points are earned when a code is registered, and you can redeem points for premium features. Each person can register one friend's code.",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "OK",
                style: TextStyle(color: AppTheme.accentRed),
              ),
            ),
          ],
        );
      },
    );
  }

  void _copyCode() {
    Clipboard.setData(
      ClipboardData(
        text:
            "Join me on Money Manager! Use my referral code: ${RecommendStore.code.value}",
      ),
    );
    _showSnack("Code copied. Paste it into your messenger.");
  }

  Future<void> _redeem(_Reward reward) async {
    if (RecommendStore.unlocked.value.contains(reward.id)) return;
    final success = await RecommendStore.redeem(reward.id, reward.cost);
    if (!mounted) return;
    _showSnack(success ? "${reward.name} unlocked." : "Not enough points.");
  }

  Widget _buildRewardCell(
    _Reward reward,
    bool isUnlocked,
    Color textColor,
    Color borderColor,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => _redeem(reward),
        child: Container(
          height: 200,
          decoration: BoxDecoration(border: Border.all(color: borderColor)),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: Icon(reward.icon, color: Colors.grey.shade600, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                reward.name,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
              if (reward.subtitle != null)
                Text(
                  reward.subtitle!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isUnlocked ? Colors.green : borderColor,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.lock_outline,
                      color: isUnlocked ? Colors.green : Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isUnlocked ? "Unlocked" : "${reward.cost} Point",
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : Colors.white;
    final graySection = isDark ? const Color(0xFF151518) : Colors.grey.shade100;
    final codeBox = isDark ? const Color(0xFF28282E) : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

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
          "Recommend",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton(
                onPressed: () => _showRegisterDialog(isDark),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Code Reg",
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          RecommendStore.code,
          RecommendStore.points,
          RecommendStore.unlocked,
        ]),
        builder: (context, child) {
          final unlocked = RecommendStore.unlocked.value;

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      "${RecommendStore.points.value}",
                      style: TextStyle(color: textColor, fontSize: 44),
                    ),
                    Text(
                      "Point",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: graySection,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Refer your friends and award our premium features.",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Both you and your friends can earn points when they register your code. Collect all the points and unlock Money Manager's premium features!",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: codeBox,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Code",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            RecommendStore.code.value,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => _showInfoDialog(isDark),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade500),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "More Information",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _copyCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFA94D),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Send code to messengers",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  "Redeem points",
                  style: TextStyle(color: textColor, fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final reward in _rewards)
                      _buildRewardCell(
                        reward,
                        unlocked.contains(reward.id),
                        textColor,
                        borderColor,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
