import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../theme/theme.dart';

class FilterSelection {
  final Set<String> categories;
  final Set<String> accounts;

  const FilterSelection({this.categories = const {}, this.accounts = const {}});

  bool get isEmpty => categories.isEmpty && accounts.isEmpty;
}

class CategoryFilterPage extends StatefulWidget {
  final FilterSelection initialSelection;

  const CategoryFilterPage({super.key, required this.initialSelection});

  static Future<FilterSelection?> show(
    BuildContext context,
    FilterSelection currentSelection,
  ) {
    return Navigator.of(context).push<FilterSelection>(
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
  late Set<String> _selectedCategories;
  late Set<String> _selectedAccounts;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedCategories = {...widget.initialSelection.categories};
    _selectedAccounts = {...widget.initialSelection.accounts};
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalSelected => _selectedCategories.length + _selectedAccounts.length;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Filter'),
        actions: [
          TextButton(
            onPressed: _totalSelected == 0
                ? null
                : () => setState(() {
                      _selectedCategories.clear();
                      _selectedAccounts.clear();
                    }),
            child: const Text('Clear'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: AppTheme.accentRed,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accentRed,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
            Tab(text: 'Account'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(provider.incomeCategories),
          _buildCategoryList(provider.expenseCategories),
          _buildAccountList(provider.accounts),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
              onPressed: () => Navigator.of(context).pop(
                FilterSelection(
                  categories: _selectedCategories,
                  accounts: _selectedAccounts,
                ),
              ),
              child: Text(
                _totalSelected == 0 ? 'Show All' : 'Apply ($_totalSelected)',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List categories) {
    final allNames = categories.map((c) => c.name as String).toSet();
    final allChecked = allNames.isNotEmpty &&
        allNames.every((name) => _selectedCategories.contains(name));

    return ListView.builder(
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return CheckboxListTile(
            value: allChecked,
            activeColor: AppTheme.accentRed,
            title: Text(
              'All',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedCategories.addAll(allNames);
                } else {
                  _selectedCategories.removeAll(allNames);
                }
              });
            },
          );
        }

        final category = categories[index - 1];
        final isChecked = _selectedCategories.contains(category.name);
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
                _selectedCategories.add(category.name);
              } else {
                _selectedCategories.remove(category.name);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildAccountList(List accounts) {
    final allNames = accounts.map((a) => a.name as String).toSet();
    final allChecked = allNames.isNotEmpty &&
        allNames.every((name) => _selectedAccounts.contains(name));

    return ListView.builder(
      itemCount: accounts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return CheckboxListTile(
            value: allChecked,
            activeColor: AppTheme.accentRed,
            title: Text(
              'All',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedAccounts.addAll(allNames);
                } else {
                  _selectedAccounts.removeAll(allNames);
                }
              });
            },
          );
        }

        final account = accounts[index - 1];
        final isChecked = _selectedAccounts.contains(account.name);
        return CheckboxListTile(
          value: isChecked,
          activeColor: AppTheme.accentRed,
          title: Text(account.name, style: TextStyle(color: AppTheme.textPrimary)),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedAccounts.add(account.name);
              } else {
                _selectedAccounts.remove(account.name);
              }
            });
          },
        );
      },
    );
  }
}