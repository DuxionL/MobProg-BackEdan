import 'package:flutter/material.dart';

class AssetRow {
  final String label;
  final String? amount;
  final Color? amountColor;
  final String? payableAmount;
  final String? outstAmount;
  final Color? outstColor;

  const AssetRow({
    required this.label,
    this.amount,
    this.amountColor,
    this.payableAmount,
    this.outstAmount,
    this.outstColor,
  });
}

class AssetListItem extends StatelessWidget {
  final String title;
  final String? titleAmount;
  final Color? titleAmountColor;
  final List<AssetRow> rows;
  final bool isCard;

  const AssetListItem({
    super.key,
    required this.title,
    required this.rows,
    this.titleAmount,
    this.titleAmountColor,
    this.isCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black;
    final headerBgColor = isDark
        ? const Color(0xFF151518)
        : Colors.grey.shade200;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;
    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: headerBgColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (titleAmount != null)
                Text(
                  titleAmount!,
                  style: TextStyle(color: titleAmountColor, fontSize: 14),
                ),
            ],
          ),
        ),
        ...rows.map((row) {
          return Column(
            children: [
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: TextStyle(color: textColor, fontSize: 15),
                    ),
                    if (!isCard && row.amount != null)
                      Text(
                        row.amount!,
                        style: TextStyle(color: row.amountColor, fontSize: 15),
                      ),
                    if (isCard)
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Balance Payable",
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                row.payableAmount ?? "",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Outst. Balance",
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                row.outstAmount ?? "",
                                style: TextStyle(
                                  color: row.outstColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Divider(color: dividerColor, height: 1, thickness: 1),
            ],
          );
        }),
      ],
    );
  }
}
