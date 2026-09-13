import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../theme/theme.dart';

class CategoryFilterDialog extends StatefulWidget {
  final Set<String> initialSelection;

  const CategoryFilterDialog({super.key, required this.initialSelection});

  static Future<Set<String>?> show(
    BuildContext context,
    Set<String> currentSelection,
  ) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          CategoryFilterDialog(initialSelection: currentSelection),
    );
  }

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog>
    with SingleTickerProviderStateMixin {
  late Set<String> _selected;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelection};
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Category',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () => setState(() => _selected.clear()),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.accentRed,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.accentRed,
              tabs: const [Tab(text: 'Income'), Tab(text: 'Expense')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryList(provider.incomeCategories, scrollController),
                  _buildCategoryList(provider.expenseCategories, scrollController),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentRed,
                  ),
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: Text(
                    _selected.isEmpty
                        ? 'Show All'
                        : 'Apply (${_selected.length})',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryList(List categories, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isChecked = _selected.contains(category.name);
        return CheckboxListTile(
          value: isChecked,
          activeColor: AppTheme.accentRed,
          title: Text(
            '${category.emoji} ${category.name}',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selected.add(category.name);
              } else {
                _selected.remove(category.name);
              }
            });
          },
        );
      },
    );
  }
}