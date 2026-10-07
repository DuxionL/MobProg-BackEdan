import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/currency_formatter.dart';
import '../../../models/transaction.dart';
import '../../../theme/theme.dart';
import '../../transaction/screens/add_transaction_page.dart';
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
    final textSecondary = Theme.of(context).textTheme.bodySmall!.color;

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
        _deleteWithUndo(
          context.read<TransactionProvider>(),
          ScaffoldMessenger.of(context),
          Theme.of(context).brightness == Brightness.dark,
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.color,
            child: Icon(_getIconForType(transaction.type), color: Colors.white),
          ),
          title: Text(
            _titleFor(transaction),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatTime(transaction.dateTime),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              if (transaction.note != null)
                Text(
                  transaction.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
            ],
          ),
          trailing: Text(
            '${transaction.type == TransactionType.expense ? '-' : '+'}${formatRupiah(transaction.amount)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: transaction.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onTap: () => _showActionsSheet(context),
          onLongPress: onLongPress,
        ),
      ),
    );
  }

  Future<void> _showActionsSheet(BuildContext context) async {
    final navigator = Navigator.of(context);
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.of(context).pop('edit'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Duplicate'),
              onTap: () => Navigator.of(context).pop('duplicate'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    switch (result) {
      case 'edit':
        navigator.push(
          MaterialPageRoute(
            builder: (context) => AddTransactionPage(transaction: transaction),
          ),
        );
        break;
      case 'duplicate':
        navigator.push(
          MaterialPageRoute(
            builder: (context) =>
                AddTransactionPage(transaction: transaction, isDuplicate: true),
          ),
        );
        break;
      case 'delete':
        // ignore: use_build_context_synchronously
        final confirmed = await _confirmDelete(context);
        if (confirmed && transaction.id != null) {
          await _deleteWithUndo(
            provider,
            messenger,
            Theme.of(context).brightness == Brightness.dark,
          );
        }
        break;
    }
  }

  Future<void> _deleteWithUndo(
    TransactionProvider provider,
    ScaffoldMessengerState messenger,
    bool isDark,
  ) async {
    final id = transaction.id;
    if (id == null) return;

    await provider.removeTransaction(id);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: isDark ? AppTheme.background : AppTheme.surfaceLight,
        duration: const Duration(seconds: 5),
        dismissDirection: DismissDirection.horizontal,
        content: Row(
          children: [
            Expanded(
              child: Text(
                'Transaction deleted',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async => provider.addTransaction(transaction),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black,
              ),
              child: const Text('Undo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('You can undo this action briefly.'),
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
