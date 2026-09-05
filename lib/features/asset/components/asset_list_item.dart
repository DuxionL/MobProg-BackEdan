import 'package:flutter/material.dart';

class AssetListItem extends StatelessWidget {
  final String title;
  final String titleAmount;
  final Color titleAmountColor;
  
  final String itemLabel;
  final String itemAmount;
  final Color itemAmountColor;
  
  final bool isCard;

  final String? cardPayableAmount;
  final String? cardOutstAmount;
  final Color? cardOutstColor;

  const AssetListItem({
    super.key,
    required this.title,
    this.titleAmount = "",
    this.titleAmountColor = Colors.white,
    required this.itemLabel,
    this.itemAmount = "",
    this.itemAmountColor = Colors.white,
    this.isCard = false,
    this.cardPayableAmount,
    this.cardOutstAmount,
    this.cardOutstColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              if (!isCard)
                Text(titleAmount, style: TextStyle(color: titleAmountColor, fontSize: 14))
              else
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Balance Payable", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(cardPayableAmount ?? "", style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Outst. Balance", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(cardOutstAmount ?? "", style: TextStyle(color: cardOutstColor, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade900, height: 1, thickness: 1),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(itemLabel, style: const TextStyle(color: Colors.white, fontSize: 15)),
              if (!isCard)
                Text(itemAmount, style: TextStyle(color: itemAmountColor, fontSize: 15))
              else
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        cardPayableAmount ?? "", 
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white, fontSize: 15)
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 80,
                      child: Text(
                        cardOutstAmount ?? "", 
                        textAlign: TextAlign.right,
                        style: TextStyle(color: cardOutstColor, fontSize: 15)
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade900, height: 1, thickness: 1),
      ],
    );
  }
}