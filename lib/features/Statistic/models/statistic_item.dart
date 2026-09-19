import 'package:flutter/material.dart';

class StatisticItem {
  final String category;
  final String emoji;
  final double total;
  final double percentage;
  final Color color;

  const StatisticItem({
    required this.category,
    required this.emoji,
    required this.total,
    required this.percentage,
    required this.color,
  });
}