import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String monthLabel;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onMonthTap;

  const CustomAppBar({
    super.key,
    required this.monthLabel,
    this.onPreviousMonth,
    this.onFavoriteTap,
    this.onFilterTap,
    this.onNextMonth,
    this.onSearchTap,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;
    final iconColor = appBarTheme.iconTheme?.color ?? Colors.white;
    final titleColor = appBarTheme.titleTextStyle?.color ?? Colors.white;

    return AppBar(
      backgroundColor: appBarTheme.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: iconColor),
            onPressed: onPreviousMonth,
          ),
          GestureDetector(
            onTap: onMonthTap,
            child: Text(
              monthLabel,
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: iconColor),
            onPressed: onNextMonth,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.star_border, color: iconColor),
          onPressed: onFavoriteTap,
        ),
        IconButton(
          icon: Icon(Icons.search, color: iconColor),
          onPressed: onSearchTap,
        ),
        IconButton(
          icon: Icon(Icons.tune, color: iconColor),
          onPressed: onFilterTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}