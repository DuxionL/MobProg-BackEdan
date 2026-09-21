import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/theme.dart';
import 'select_main_category_page.dart';

class ExpenseCategoryItem {
  String name;
  String icon;
  List<String> subcategories;

  ExpenseCategoryItem({
    required this.name,
    required this.icon,
    List<String>? subcategories,
  }) : subcategories = subcategories ?? [];
}

final ValueNotifier<List<ExpenseCategoryItem>> expenseCategoriesNotifier =
    ValueNotifier<List<ExpenseCategoryItem>>([
      ExpenseCategoryItem(
        name: "Food",
        icon: "🍜",
        subcategories: ["Lunch", "Dinner", "Eating out", "Beverages"],
      ),
      ExpenseCategoryItem(
        name: "Social Life",
        icon: "🧑‍🤝‍🧑",
        subcategories: ["Friend", "Fellowship", "Alumni", "Dues"],
      ),
      ExpenseCategoryItem(name: "Pets", icon: "🐶"),
      ExpenseCategoryItem(
        name: "Transport",
        icon: "🚖",
        subcategories: ["Bus", "Subway", "Taxi", "Car"],
      ),
      ExpenseCategoryItem(
        name: "Culture",
        icon: "🖼️",
        subcategories: ["Books", "Movie", "Music", "Apps"],
      ),
      ExpenseCategoryItem(
        name: "Household",
        icon: "🪑",
        subcategories: [
          "Appliances",
          "Furniture",
          "Kitchen",
          "Toiletries",
          "Chandlery",
        ],
      ),
      ExpenseCategoryItem(
        name: "Apparel",
        icon: "🧥",
        subcategories: ["Clothing", "Fashion", "Shoes", "Laundry"],
      ),
      ExpenseCategoryItem(
        name: "Beauty",
        icon: "💄",
        subcategories: ["Cosmetics", "Makeup", "Accessories", "Beauty"],
      ),
      ExpenseCategoryItem(
        name: "Health",
        icon: "🧘",
        subcategories: ["Health", "Yoga", "Hospital", "Medicine"],
      ),
      ExpenseCategoryItem(
        name: "Education",
        icon: "📙",
        subcategories: ["Schooling", "Textbooks", "School supplies", "Academy"],
      ),
      ExpenseCategoryItem(name: "Gift", icon: "🎁"),
      ExpenseCategoryItem(name: "Other", icon: ""),
    ]);

class ExpenseCategoryPage extends StatefulWidget {
  const ExpenseCategoryPage({super.key});

  @override
  State<ExpenseCategoryPage> createState() => _ExpenseCategoryPageState();
}

class _ExpenseCategoryPageState extends State<ExpenseCategoryPage> {
  bool _isSubcategoryOn = true;

  @override
  void initState() {
    super.initState();
    _loadSubcategorySetting();
  }

  Future<void> _loadSubcategorySetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSubcategoryOn = prefs.getBool('expense_subcategory_on') ?? true;
    });
  }

  Future<void> _toggleSubcategory(bool value) async {
    setState(() {
      _isSubcategoryOn = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('expense_subcategory_on', value);
  }

  void _navigateToAddEdit({ExpenseCategoryItem? category, int? index}) async {
    final result = await Navigator.push<ExpenseCategoryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseCategoryPage(
          category: category,
          isSubcategoryOn: _isSubcategoryOn,
        ),
      ),
    );

    if (result != null && result.name.trim().isNotEmpty) {
      final currentList = List<ExpenseCategoryItem>.from(
        expenseCategoriesNotifier.value,
      );
      if (index != null) {
        currentList[index] = result;
      } else {
        currentList.add(result);
      }
      expenseCategoriesNotifier.value = currentList;
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
          "Expenses Category",
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
                  inactiveTrackColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  onChanged: (value) => _toggleSubcategory(value),
                ),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1, thickness: 1),
          Expanded(
            child: ValueListenableBuilder<List<ExpenseCategoryItem>>(
              valueListenable: expenseCategoriesNotifier,
              builder: (context, categories, child) {
                return ReorderableListView.builder(
                  itemCount: categories.length,
                  onReorder: (oldIndex, newIndex) {
                    final currentList = List<ExpenseCategoryItem>.from(
                      categories,
                    );
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = currentList.removeAt(oldIndex);
                    currentList.insert(newIndex, item);
                    expenseCategoriesNotifier.value = currentList;
                  },
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final hasSub =
                        _isSubcategoryOn && item.subcategories.isNotEmpty;

                    return Column(
                      key: ValueKey(item.name + index.toString()),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final currentList =
                                      List<ExpenseCategoryItem>.from(
                                        categories,
                                      );
                                  currentList.removeAt(index);
                                  expenseCategoriesNotifier.value = currentList;
                                },
                                child: const Icon(
                                  Icons.remove_circle,
                                  color: AppTheme.accentRed,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              if (item.icon.isNotEmpty) ...[
                                Text(
                                  item.icon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      hasSub
                                          ? "${item.name} (${item.subcategories.length})"
                                          : item.name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (hasSub) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subcategories.join(", "),
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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

class AddEditExpenseCategoryPage extends StatefulWidget {
  final ExpenseCategoryItem? category;
  final bool isSubcategoryOn;

  const AddEditExpenseCategoryPage({
    super.key,
    this.category,
    this.isSubcategoryOn = false,
  });

  @override
  State<AddEditExpenseCategoryPage> createState() =>
      _AddEditExpenseCategoryPageState();
}

class _AddEditExpenseCategoryPageState
    extends State<AddEditExpenseCategoryPage> {
  late TextEditingController _nameController;
  late List<String> _subcategories;
  final TextEditingController _newSubController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? "");
    _subcategories = List<String>.from(widget.category?.subcategories ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newSubController.dispose();
    super.dispose();
  }

  void _addSubcategory() {
    final text = _newSubController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        if (!_subcategories.contains(text)) {
          _subcategories.add(text);
        }
      });
      _newSubController.clear();
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
          "Expenses Category",
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        actions: [
          if (widget.isSubcategoryOn)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                height: 32,
                child: OutlinedButton(
                  onPressed: () async {
                    final currentCategoryName = _nameController.text.trim();
                    if (currentCategoryName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ketik nama kategori terlebih dahulu"),
                        ),
                      );
                      return;
                    }

                    final mainCategories = expenseCategoriesNotifier.value
                        .map((e) => e.name)
                        .where((name) => name != currentCategoryName)
                        .toList();

                    final targetMainCategory = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectMainCategoryPage(
                          categoryName: currentCategoryName,
                          mainCategories: mainCategories,
                        ),
                      ),
                    );

                    if (targetMainCategory != null && mounted) {
                      final currentList = List<ExpenseCategoryItem>.from(
                        expenseCategoriesNotifier.value,
                      );

                      final targetIndex = currentList.indexWhere(
                        (e) => e.name == targetMainCategory,
                      );

                      if (targetIndex != -1) {
                        final targetItem = currentList[targetIndex];
                        final newSubcategories = List<String>.from(
                          targetItem.subcategories,
                        );

                        if (!newSubcategories.contains(currentCategoryName)) {
                          newSubcategories.add(currentCategoryName);
                        }

                        for (var sub in _subcategories) {
                          if (!newSubcategories.contains(sub)) {
                            newSubcategories.add(sub);
                          }
                        }

                        currentList[targetIndex] = ExpenseCategoryItem(
                          name: targetItem.name,
                          icon: targetItem.icon,
                          subcategories: newSubcategories,
                        );

                        if (widget.category != null) {
                          currentList.removeWhere(
                            (e) => e.name == widget.category!.name,
                          );
                        } else {
                          currentList.removeWhere(
                            (e) => e.name == currentCategoryName,
                          );
                        }

                        expenseCategoriesNotifier.value = currentList;
                      }

                      Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text(
                    "→ Subcategory",
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppTheme.accentRed,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  if (widget.isSubcategoryOn) ...[
                    const SizedBox(height: 30),
                    Text(
                      "Subcategories",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subcategories.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: dividerColor, height: 1),
                      itemBuilder: (context, index) {
                        final subName = _subcategories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _subcategories.removeAt(index);
                                  });
                                },
                                child: const Icon(
                                  Icons.remove_circle,
                                  color: AppTheme.accentRed,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  subName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newSubController,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "+ Add new subcategory",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _addSubcategory(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.accentRed,
                          ),
                          onPressed: _addSubcategory,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final newName = _nameController.text.trim();
                  if (newName.isEmpty) return;

                  Navigator.pop(
                    context,
                    ExpenseCategoryItem(
                      name: newName,
                      icon: widget.category?.icon ?? "🏷️",
                      subcategories: _subcategories,
                    ),
                  );
                },
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
    );
  }
}
