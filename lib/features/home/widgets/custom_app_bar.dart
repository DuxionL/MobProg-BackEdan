import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String monthLabel;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const CustomAppBar({
    super.key,
    required this.monthLabel,
    this.onPreviousMonth,
    this.onFavoriteTap,
    this.onFilterTap,
    this.onNextMonth,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      automaticallyImplyActions: false,
      titleSpacing: 12,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
            onPressed: onPreviousMonth,
          ),
          Text(
            monthLabel,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
            onPressed: onNextMonth,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.star_border, color: AppTheme.textPrimary),
          onPressed: onFavoriteTap,
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppTheme.textPrimary),
          onPressed: onSearchTap,
        ),
        IconButton(
          icon: Icon(Icons.tune, color: AppTheme.textPrimary),
          onPressed: onFilterTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
}