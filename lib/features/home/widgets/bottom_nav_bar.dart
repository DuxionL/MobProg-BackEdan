import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class BottomNavBar extends StatelessWidget{
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });
  
  static const List<_NavItemData> _items = [
    _NavItemData(icon : Icons.menu_book_outlined, label : 'Transaksi'),
    _NavItemData(icon : Icons.bar_chart_outlined, label: 'Statistik'),
    _NavItemData(icon : Icons.savings_outlined, label : 'Aset'),
    _NavItemData(icon : Icons.more_horiz, label: 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: AppTheme.surface, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index){
            final item = _items[index];
            final bool isSelected = selectedIndex == index;
            final Color color =
              isSelected ? AppTheme.accentRed : AppTheme.textSecondary;
            
            return InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: 
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

  class _NavItemData {
    final IconData icon;
    final String label;

    const _NavItemData({required this.icon, required this.label});
  }