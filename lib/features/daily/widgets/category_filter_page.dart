import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../theme/theme.dart';

class CategoryFilterPage extends StatefulWidget {
  final Set<String> initialSelection;

  const CategoryFilterPage({super.key, required this.initialSelection});

  static Future<Set<String>?> show(
    BuildContext context,
    Set<String> currentSelection,
  ) {
    return Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) =>
            CategoryFilterPage(initialSelection: currentSelection),
      ),
    );
  }

  @override
  State<CategoryFilterPage> createState() => _CategoryFilterPageState();
}

class _CategoryFilterPageState extends State<CategoryFilterPage>
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Filter by Category'),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => setState(() => _selected.clear()),
            child: const Text('Clear'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentRed,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accentRed,
          tabs: const [Tab(text: 'Income'), Tab(text: 'Expense')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(provider.incomeCategories),
          _buildCategoryList(provider.expenseCategories),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
              onPressed: () => Navigator.of(context).pop(_selected),
              child: Text(
                _selected.isEmpty ? 'Show All' : 'Apply (${_selected.length})',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List categories) {
    return ListView.builder(
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