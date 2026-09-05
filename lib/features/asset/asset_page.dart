import 'package:flutter/material.dart';
import 'components/asset_summary_header.dart';
import 'components/asset_trend_chart.dart';
import 'components/asset_list_item.dart';

class AssetPage extends StatelessWidget {
  const AssetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        elevation: 0,
        title: const Text("Accounts", style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: const [
          Icon(Icons.bar_chart, color: Colors.white),
          SizedBox(width: 16),
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AssetSummaryHeader(),
            const AssetTrendChart(),
            
            Expanded(
              child: ListView(
                children: [

                  AssetListItem(
                    title: "Cash", 
                    titleAmount: "\$ 100.00",
                    titleAmountColor: Colors.red[400]!,
                    itemLabel: "Cash", 
                    itemAmount: "\$ 100.00",
                    itemAmountColor: Colors.red[400]!,
                  ),
                  
                  AssetListItem(
                    title: "Accounts", 
                    titleAmount: "\$ 1,000.00",
                    titleAmountColor: Colors.blue[400]!,
                    itemLabel: "Accounts", 
                    itemAmount: "\$ 1,000.00",
                    itemAmountColor: Colors.blue[400]!,
                  ),

                  AssetListItem(
                    isCard: true,
                    title: "Card", 
                    itemLabel: "Card", 
                    cardPayableAmount: "\$ 0.00",
                    cardOutstAmount: "\$ 9,900.00",
                    cardOutstColor: Colors.blue[400]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}