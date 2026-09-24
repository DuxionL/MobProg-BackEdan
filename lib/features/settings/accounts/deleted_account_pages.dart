import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import 'account_store.dart';

Future<bool> _confirmDelete(BuildContext context, String message) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF28282E)
            : AppTheme.surfaceLight,
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "No data available.",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _DeletedRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onRestore;
  final VoidCallback onDeleteForever;

  const _DeletedRow({
    required this.title,
    required this.onRestore,
    required this.onDeleteForever,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.restore, color: Colors.grey.shade500),
                tooltip: "Restore",
                onPressed: onRestore,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppTheme.accentRed,
                ),
                tooltip: "Delete permanently",
                onPressed: onDeleteForever,
              ),
            ],
          ),
        ),
        Divider(color: dividerColor, height: 1, thickness: 1),
      ],
    );
  }
}

class DeletedAccountGroupPage extends StatefulWidget {
  const DeletedAccountGroupPage({super.key});

  @override
  State<DeletedAccountGroupPage> createState() =>
      _DeletedAccountGroupPageState();
}

class _DeletedAccountGroupPageState extends State<DeletedAccountGroupPage> {
  @override
  void initState() {
    super.initState();
    AccountStore.load();
  }

  Future<void> _deleteForever(AccountGroup group) async {
    final confirmed = await _confirmDelete(
      context,
      'Delete "${group.name}" permanently? Accounts in this group will be deleted too.',
    );
    if (!confirmed) return;
    await AccountStore.permanentlyDeleteGroup(group.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Deleted account group",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([AccountStore.groups, AccountStore.items]),
        builder: (context, child) {
          final groups = AccountStore.deletedGroups;
          if (groups.isEmpty) return const _EmptyView();

          return ListView(
            children: groups.map((group) {
              return _DeletedRow(
                title: group.name,
                subtitle: group.subtitle,
                onRestore: () => AccountStore.restoreGroup(group.id),
                onDeleteForever: () => _deleteForever(group),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class DeletedAccountsPage extends StatefulWidget {
  const DeletedAccountsPage({super.key});

  @override
  State<DeletedAccountsPage> createState() => _DeletedAccountsPageState();
}

class _DeletedAccountsPageState extends State<DeletedAccountsPage> {
  @override
  void initState() {
    super.initState();
    AccountStore.load();
  }

  String _groupName(String groupId) {
    for (final group in AccountStore.groups.value) {
      if (group.id == groupId) return group.name;
    }
    return "";
  }

  Future<void> _restore(AccountItem item) async {
    final restored = await AccountStore.restoreItem(item.id);
    if (restored || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restore the group "${_groupName(item.groupId)}" first.'),
      ),
    );
  }

  Future<void> _deleteForever(AccountItem item) async {
    final confirmed = await _confirmDelete(
      context,
      'Delete "${item.name}" permanently?',
    );
    if (!confirmed) return;
    await AccountStore.permanentlyDeleteItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Deleted accounts",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([AccountStore.groups, AccountStore.items]),
        builder: (context, child) {
          final items = AccountStore.deletedItems;
          if (items.isEmpty) return const _EmptyView();

          return ListView(
            children: items.map((item) {
              return _DeletedRow(
                title: item.name,
                subtitle: _groupName(item.groupId),
                onRestore: () => _restore(item),
                onDeleteForever: () => _deleteForever(item),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
