import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/statistic_item.dart';

class StatisticChart extends StatefulWidget {
  final List<StatisticItem> statistics;

  const StatisticChart({
    super.key,
    required this.statistics,
  });

  @override
  State<StatisticChart> createState() => _StatisticChartState();
}

class _StatisticChartState extends State<StatisticChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.statistics.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(
          child: Text(
            "No Transaction",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [

        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }

                    touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),

              borderData: FlBorderData(show: false),

              sectionsSpace: 2,

              centerSpaceRadius: 0,

              sections: List.generate(
                widget.statistics.length,
                (index) {
                  final item = widget.statistics[index];

                  final isTouched = index == touchedIndex;

                  return PieChartSectionData(
                    color: item.color,

                    value: item.total,

                    radius: isTouched ? 92 : 80,

                    title:
                        "${item.percentage.toStringAsFixed(0)}%",

                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTouched ? 18 : 14,
                    ),

                    badgeWidget: isTouched
                        ? _Badge(
                            emoji: item.emoji,
                            category: item.category,
                          )
                        : null,

                    badgePositionPercentageOffset: 1.25,
                  );
                },
              ),
            ),

            duration: const Duration(milliseconds: 300),

            curve: Curves.easeOut,
          ),
        ),

        const SizedBox(height: 25),

        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: widget.statistics.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  "${item.emoji} ${item.category}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

              ],
            );
          }).toList(),
        ),

      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String emoji;
  final String category;

  const _Badge({
    required this.emoji,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black26,
          ),
        ],
      ),
      child: Text(
        "$emoji $category",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}