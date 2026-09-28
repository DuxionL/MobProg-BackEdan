import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class PcmanagerPage extends StatefulWidget {
  const PcmanagerPage({super.key});

  @override
  State<PcmanagerPage> createState() => _PcmanagerPageState();
}

class _PcmanagerPageState extends State<PcmanagerPage> {

  void _onPurchase() {
    // TODO: hook up in-app purchase here.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final surface = isDark ? AppTheme.surface : AppTheme.surfaceLight;
    final textPrimary = isDark
        ? AppTheme.textPrimary
        : AppTheme.textPrimaryLight;
    final textSecondary = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentRed : AppTheme.accentRedLight;
    final borderColor = isDark
        ? const Color(0xFF2C2F3D)
        : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Premium Upgrade')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(textPrimary, textSecondary, surface, borderColor),
                  Divider(color: textPrimary, height: 1, thickness: 1),
                  _buildFeatures(
                    textPrimary,
                    textSecondary,
                    surface,
                    borderColor,
                  ),
                  _buildRecommend(
                    textPrimary,
                    textSecondary,
                    accent,
                    isDark,
                  ),
                ],
              ),
            ),
          ),
          _buildPurchaseButton(bg, accent),
        ],
      ),
    );
  }

  
  Widget _buildHeader(
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Try Money Manager's all advanced features!",
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Go Premium to enjoy unlimited functions and to support '
                  'us to develop more exciting features!',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _buildIllustration(textSecondary, surface, borderColor),
          ),
        ],
      ),
    );
  }

  
  Widget _buildIllustration(
    Color iconColor,
    Color surface,
    Color borderColor,
  ) {
    return SizedBox(
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Icon(Icons.desktop_windows_outlined,
                  size: 64, color: iconColor),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 44,
              height: 78,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: iconColor, width: 1.5),
              ),
              child: Icon(Icons.phone_android, size: 28, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildFeatures(
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgraded features',
            style: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _FeatureRow(
            number: 1,
            icon: Icons.block,
            title: 'No ads.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            surface: surface,
            borderColor: borderColor,
          ),
          _FeatureRow(
            number: 2,
            icon: Icons.all_inclusive,
            title: 'Unlimited list of accounts.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            surface: surface,
            borderColor: borderColor,
          ),
          _FeatureRow(
            number: 3,
            icon: Icons.desktop_windows_outlined,
            title: 'PC Manager.',
            description: 'A router is required for using PC Manager. '
                'This function may be limited depending on your router.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            surface: surface,
            borderColor: borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommend(
    Color textPrimary,
    Color textSecondary,
    Color accent,
    bool isDark,
  ) {
    final sectionBg =
        isDark ? const Color(0xFF233238) : const Color(0xFFE6F2EE);

    return Container(
      width: double.infinity,
      color: sectionBg,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommend',
            style: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium, color: accent, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium (one-time)',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All advanced features, forever.',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Placeholder price - replace with the real product price.
                Text(
                  '\$0.00',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  
  Widget _buildPurchaseButton(Color bg, Color accent) {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _onPurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Premium Upgrade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}


class _FeatureRow extends StatelessWidget {
  final int number;
  final IconData icon;
  final String title;
  final String? description;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color borderColor;

  const _FeatureRow({
    required this.number,
    required this.icon,
    required this.title,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.borderColor,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surface,
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: textPrimary, size: 34),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: textPrimary,
                      ),
                      child: Text(
                        '$number',
                        style: TextStyle(
                          color: surface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(color: textPrimary, fontSize: 19),
                      ),
                    ),
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}