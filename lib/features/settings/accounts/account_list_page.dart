import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../settings/configuration/currency_settings.dart';
import 'account_store.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  @override
  void initState() {
    super.initState();
    AccountStore.load();
  }

  void _openEdit([AccountItem? item]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditAccountPage(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;
    final headerBg = isDark ? const Color(0xFF151518) : Colors.grey.shade200;

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
          "Accounts Setting",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: textColor, size: 28),
            onPressed: () => _openEdit(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([AccountStore.groups, AccountStore.items]),
        builder: (context, child) {
          final groups = AccountStore.visibleGroups;
          final items = AccountStore.visibleItems;
          final children = <Widget>[];

          for (final group in groups) {
            final groupItems = items.where((i) => i.groupId == group.id);
            if (groupItems.isEmpty) continue;

            children.add(
              Container(
                width: double.infinity,
                color: headerBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Text(
                  group.name,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            );

            for (final item in groupItems) {
              children.add(
                Column(
                  children: [
                    InkWell(
                      onTap: () => _openEdit(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(color: textColor, fontSize: 15),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: dividerColor, height: 1, thickness: 1),
                  ],
                ),
              );
            }
          }

          return ListView(children: children);
        },
      ),
    );
  }
}

class AddEditAccountPage extends StatefulWidget {
  final AccountItem? item;

  const AddEditAccountPage({super.key, this.item});

  @override
  State<AddEditAccountPage> createState() => _AddEditAccountPageState();
}

class _AddEditAccountPageState extends State<AddEditAccountPage> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _groupId;

  @override
  void initState() {
    super.initState();
    AccountStore.load();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? "");
    _amountController = TextEditingController(
      text: item == null || item.amount == 0
          ? ""
          : item.amount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? "",
    );
    _groupId = item?.groupId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _groupName {
    final groups = AccountStore.visibleGroups;
    final selected = groups.where((g) => g.id == _groupId);
    if (selected.isNotEmpty) return selected.first.name;
    return groups.isNotEmpty ? groups.first.name : "";
  }

  String? get _effectiveGroupId {
    if (_groupId != null) return _groupId;
    final groups = AccountStore.visibleGroups;
    return groups.isNotEmpty ? groups.first.id : null;
  }

  void _showGroupSheet(bool isDark) {
    final groups = AccountStore.visibleGroups;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF28282E) : AppTheme.surfaceLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Account Group",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                height: 1,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: groups.map((group) {
                    final isSelected = group.id == _effectiveGroupId;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() => _groupId = group.id);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.accentRed
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black),
                                    fontSize: 15,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: AppTheme.accentRed,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                          height: 1,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final groupId = _effectiveGroupId;
    if (name.isEmpty || groupId == null) return;

    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ??
        0;
    final description = _descriptionController.text.trim();

    if (widget.item == null) {
      await AccountStore.addItem(
        groupId: groupId,
        name: name,
        amount: amount,
        description: description,
      );
    } else {
      await AccountStore.updateItem(
        widget.item!.copyWith(
          groupId: groupId,
          name: name,
          amount: amount,
          description: description,
        ),
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    await AccountStore.deleteItem(widget.item!.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildField({
    required String label,
    required Widget child,
    required Color dividerColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: dividerColor)),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final isEditing = widget.item != null;

    return ListenableBuilder(
      listenable: AccountStore.groups,
      builder: (context, child) {
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
              isEditing ? "Edit Account" : "Add Account",
              style: TextStyle(color: textColor, fontSize: 18),
            ),
            actions: [
              if (isEditing)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: textColor),
                  onPressed: _delete,
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildField(
                  label: "Group",
                  dividerColor: dividerColor,
                  child: InkWell(
                    onTap: () => _showGroupSheet(isDark),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _groupName,
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                _buildField(
                  label: "Name",
                  dividerColor: dividerColor,
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                _buildField(
                  label: "Amount",
                  dividerColor: dividerColor,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixText: "${CurrencySettings.notifier.value.symbol} ",
                      prefixStyle: TextStyle(color: textColor, fontSize: 16),
                    ),
                  ),
                ),
                _buildField(
                  label: "Description",
                  dividerColor: dividerColor,
                  child: TextField(
                    controller: _descriptionController,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
