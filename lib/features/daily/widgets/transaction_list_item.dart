import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/transaction.dart';
import '../../../theme/theme.dart';
import '../../transaction/transaction_provider.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onLongPress;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(transaction.id ?? transaction.hashCode),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentRed,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) {
        if (transaction.id != null) {
          context.read<TransactionProvider>().removeTransaction(transaction.id!);
        }
      },
      child: Card(
        color: AppTheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.color,
            child: Icon(_getIconForType(transaction.type), color: Colors.white),
          ),
          title: Text(_titleFor(transaction)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatTime(transaction.dateTime),
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              if (transaction.note != null)
                Text(
                  transaction.note!,
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
            ],
          ),
          trailing: Text(
            '${transaction.type == TransactionType.expense ? '-' : '+'}${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: transaction.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onLongPress: onLongPress,
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _titleFor(Transaction t) {
    if (t.category != null) {
      return '${t.category!.emoji} ${t.category!.name}';
    }
    return '${t.fromAccount?.name} → ${t.toAccount?.name}';
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}