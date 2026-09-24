import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import 'account_store.dart';

class AccountGroupPage extends StatefulWidget {
  const AccountGroupPage({super.key});

  @override
  State<AccountGroupPage> createState() => _AccountGroupPageState();
}

class _AccountGroupPageState extends State<AccountGroupPage> {
  @override
  void initState() {
    super.initState();
    AccountStore.load();
  }

  void _openEdit([AccountGroup? group]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAccountGroupPage(group: group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;

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
          "Account Group",
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
        listenable: AccountStore.groups,
        builder: (context, child) {
          final groups = AccountStore.visibleGroups;
          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: groups.length,
            onReorder: AccountStore.reorderGroups,
            itemBuilder: (context, index) {
              final group = groups[index];
              final subtitle = group.subtitle;

              return Column(
                key: ValueKey(group.id),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        if (group.isProtected)
                          Icon(
                            Icons.toll,
                            color: Colors.grey.shade500,
                            size: 22,
                          )
                        else
                          GestureDetector(
                            onTap: () => AccountStore.deleteGroup(group.id),
                            child: const Icon(
                              Icons.remove_circle,
                              color: AppTheme.accentRed,
                              size: 22,
                            ),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
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
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () => _openEdit(group),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.menu,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: dividerColor, height: 1, thickness: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AddEditAccountGroupPage extends StatefulWidget {
  final AccountGroup? group;

  const AddEditAccountGroupPage({super.key, this.group});

  @override
  State<AddEditAccountGroupPage> createState() =>
      _AddEditAccountGroupPageState();
}

class _AddEditAccountGroupPageState extends State<AddEditAccountGroupPage> {
  late TextEditingController _nameController;
  late AccountGroupType _type;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? "");
    _type = widget.group?.type ?? AccountGroupType.normal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (widget.group == null) {
      await AccountStore.addGroup(name, _type);
    } else {
      await AccountStore.updateGroup(widget.group!.id, name, _type);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildRadio(String title, AccountGroupType value, Color textColor) {
    final isSelected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.accentRed : Colors.grey.shade500,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentRed,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(color: textColor, fontSize: 15)),
          ],
        ),
      ),
    );
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
          "Account Group",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor, fontSize: 16),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.grey.shade500),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentRed, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildRadio("Default", AccountGroupType.normal, textColor),
            _buildRadio(
              "Account group for credit cards",
              AccountGroupType.credit,
              textColor,
            ),
            _buildRadio(
              "Account group for debit cards",
              AccountGroupType.debit,
              textColor,
            ),
            const SizedBox(height: 24),
            SizedBox(
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
          ],
        ),
      ),
    );
  }
}
