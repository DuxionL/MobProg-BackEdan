import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/features/transaction/transaction_provider.dart';
import 'package:money_manager/features/transaction/screens/add_transaction_page.dart';
import 'package:money_manager/models/transaction.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'), elevation: 0),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.all.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No transactions yet'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddTransactionPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Transaction'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.all.length,
            itemBuilder: (context, index) {
              final transaction = provider.all[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.color,
                    child: Icon(
                      _getIconForType(transaction.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    transaction.category?.name ??
                        '${transaction.fromAccount?.name} → ${transaction.toAccount?.name}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(transaction.dateTime),
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (transaction.note != null)
                        Text(
                          transaction.note!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${transaction.type == TransactionType.expense ? '-' : '+'}${transaction.amount}',
                    style: TextStyle(
                      color: transaction.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onLongPress: () {
                    _showDeleteDialog(context, provider, transaction.id!);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(
    BuildContext context,
    TransactionProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeTransaction(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
