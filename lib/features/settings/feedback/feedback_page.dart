import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/theme.dart';

const String feedbackEmail = 'your-email@example.com';

const String _specialThanks = 'To the Project Team : 535250077 - Garry Malvin Jiu, 535250078 - Moureno Surianto, 535250081 - Steven Verdychen, 535250087 - Gilbert Immanuel Susanto, 535250093 - Jessica Jeslyn Sutanto';

class _Faq {
  final String question;
  final String answer;

  const _Faq(this.question, this.answer);
}

const List<_Faq> _faqs = [
  _Faq(
    'Do we need to repurchase when changing device?',
    'There is no paid version yet, so nothing needs to be repurchased.',
  ),
  _Faq(
    'Ads still show up after purchasing the paid version.',
    'There is no paid version yet, and ads are not part of this app.',
  ),
  _Faq(
    'Can we sync data between devices?',
    'Your data is stored on this device. Syncing between devices is not available yet.',
  ),
  _Faq(
    'How to backup and restore data',
    'Backup and restore is not available yet. It will be added in a future update.',
  ),
  _Faq(
    'Is the subscription one-time payment?',
    'There is no subscription in this app.',
  ),
];

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int? _openFaq;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _copy(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack(message);
  }

  void _showInfoDialog(String title, String message, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF28282E)
              : AppTheme.surfaceLight,
          title: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF151518) : Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
      ),
    );
  }

  Widget _buildFaq(int index, Color textColor) {
    final faq = _faqs[index];
    final isOpen = _openFaq == index;

    return InkWell(
      onTap: () => setState(() => _openFaq = isOpen ? null : index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Q.",
                  style: TextStyle(color: AppTheme.accentRed, fontSize: 15),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    faq.question,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 24),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    Color textColor,
    Color dividerColor,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ),
        ),
        Divider(color: dividerColor, height: 1, thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

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
          "Feedback",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Frequently Asked Questions", isDark),
          for (int i = 0; i < _faqs.length; i++) _buildFaq(i, textColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => _copy(
                  feedbackEmail,
                  "Email address copied. Send your feedback to $feedbackEmail.",
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Feedback ($feedbackEmail)",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
              ),
            ),
          ),
          Divider(color: dividerColor, height: 1, thickness: 1),
          _buildMenuItem(
            "Check for Updates",
            textColor,
            dividerColor,
            () => _showSnack("You are using the latest version."),
          ),
          _buildMenuItem(
            "Share",
            textColor,
            dividerColor,
            () => _copy(
              "Check out Money Manager, an app to track your income and expenses!",
              "Share text copied to clipboard.",
            ),
          ),
          _buildMenuItem(
            "Mistranslation/Typo",
            textColor,
            dividerColor,
            () => _copy(
              feedbackEmail,
              "Email address copied. Send us the mistranslation or typo you found.",
            ),
          ),
          _buildMenuItem(
            "Write a Review",
            textColor,
            dividerColor,
            () => _showSnack(
              "Thank you! Reviews will be available once the app is published.",
            ),
          ),
          _buildMenuItem(
            "Privacy Policy",
            textColor,
            dividerColor,
            () => _showInfoDialog(
              "Privacy Policy",
              "Your transactions, accounts, categories, and settings are stored only on this device. The app does not send your data to any server.",
              isDark,
            ),
          ),
          _buildMenuItem(
            "Open Source License",
            textColor,
            dividerColor,
            () => showLicensePage(
              context: context,
              applicationName: "Money Manager",
            ),
          ),
          _buildSectionHeader("Special thanks", isDark),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _specialThanks,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
