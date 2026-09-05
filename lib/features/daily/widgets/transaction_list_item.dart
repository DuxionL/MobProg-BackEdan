import 'package:flutter/material.dart';
import '../../../models/transaction.dart';

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
    return Card(
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
            Text(_formatTime(transaction.dateTime), style: const TextStyle(fontSize: 12)),
            if (transaction.note != null)
              Text(
                transaction.note!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
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
    );
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