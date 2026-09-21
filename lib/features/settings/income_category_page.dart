import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class IncomeCategoryItem {
  String name;
  String icon;

  IncomeCategoryItem({required this.name, required this.icon});
}

final ValueNotifier<List<IncomeCategoryItem>> incomeCategoriesNotifier =
    ValueNotifier<List<IncomeCategoryItem>>([
  IncomeCategoryItem(name: "Allowance", icon: "🤑"),
  IncomeCategoryItem(name: "Salary", icon: "💰"),
  IncomeCategoryItem(name: "Petty cash", icon: "💵"),
  IncomeCategoryItem(name: "Bonus", icon: "🏅"),
  IncomeCategoryItem(name: "Other", icon: ""),
]);

class IncomeCategoryPage extends StatefulWidget {
  const IncomeCategoryPage({super.key});

  @override
  State<IncomeCategoryPage> createState() => _IncomeCategoryPageState();
}

class _IncomeCategoryPageState extends State<IncomeCategoryPage> {
  bool _isSubcategoryOn = false;

  void _navigateToAddEdit({IncomeCategoryItem? category, int? index}) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditIncomeCategoryPage(
          initialName: category?.name,
        ),
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final currentList = List<IncomeCategoryItem>.from(incomeCategoriesNotifier.value);
      if (index != null) {
        currentList[index].name = result;
      } else {
        currentList.add(IncomeCategoryItem(name: result, icon: "🏷️"));
      }
      incomeCategoriesNotifier.value = currentList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

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
          "Income Category",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: textColor, size: 28),
            onPressed: () => _navigateToAddEdit(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subcategory",
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
                Switch(
                  value: _isSubcategoryOn,
                  activeColor: Colors.white,
                  activeTrackColor: AppTheme.accentRed,
                  inactiveThumbColor: isDark ? Colors.grey : Colors.white,
                  inactiveTrackColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() {
                      _isSubcategoryOn = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1, thickness: 1),
          Expanded(
            child: ValueListenableBuilder<List<IncomeCategoryItem>>(
              valueListenable: incomeCategoriesNotifier,
              builder: (context, categories, child) {
                return ReorderableListView.builder(
                  itemCount: categories.length,
                  onReorder: (oldIndex, newIndex) {
                    final currentList = List<IncomeCategoryItem>.from(categories);
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = currentList.removeAt(oldIndex);
                    currentList.insert(newIndex, item);
                    incomeCategoriesNotifier.value = currentList;
                  },
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return Column(
                      key: ValueKey(item.name + index.toString()),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final currentList =
                                      List<IncomeCategoryItem>.from(categories);
                                  currentList.removeAt(index);
                                  incomeCategoriesNotifier.value = currentList;
                                },
                                child: const Icon(
                                  Icons.remove_circle,
                                  color: AppTheme.accentRed,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Row(
                                  children: [
                                    if (item.icon.isNotEmpty) ...[
                                      Text(
                                        item.icon,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                onPressed: () => _navigateToAddEdit(
                                  category: item,
                                  index: index,
                                ),
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
          ),
        ],
      ),
    );
  }
}

class AddEditIncomeCategoryPage extends StatefulWidget {
  final String? initialName;

  const AddEditIncomeCategoryPage({super.key, this.initialName});

  @override
  State<AddEditIncomeCategoryPage> createState() =>
      _AddEditIncomeCategoryPageState();
}

class _AddEditIncomeCategoryPageState
    extends State<AddEditIncomeCategoryPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? "");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : Colors.white;
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
          "Income Category",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: textColor, fontSize: 16),
              decoration: InputDecoration(
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _controller.text),
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