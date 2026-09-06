import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class FabButton extends StatelessWidget{
  final VoidCallback onPressed;

  const FabButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppTheme.accentRed,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 28),
    );
  }
}