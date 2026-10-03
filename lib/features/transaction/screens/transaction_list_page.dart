import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/common/currency_formatter.dart';
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
                  trailing: SizedBox(
                    width: 104,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.type == TransactionType.expense ? '-' : '+'}${formatRupiah(transaction.amount)}',
                          style: TextStyle(
                            color: transaction.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(Icons.more_vert, size: 20),
                          tooltip: 'Transaction actions',
                          onSelected: (value) => _handleAction(
                            context,
                            provider,
                            transaction,
                            value,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Text('Duplicate'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

  void _handleAction(
    BuildContext context,
    TransactionProvider provider,
    Transaction transaction,
    String action,
  ) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddTransactionPage(transaction: transaction),
          ),
        );
        break;
      case 'duplicate':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                AddTransactionPage(transaction: transaction, isDuplicate: true),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, provider, transaction);
        break;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    TransactionProvider provider,
    Transaction transaction,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('You can undo this action briefly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.removeTransaction(transaction.id!);
              messenger.showSnackBar(
                SnackBar(
                  content: const Text('Transaction deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async => provider.addTransaction(transaction),
                  ),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
