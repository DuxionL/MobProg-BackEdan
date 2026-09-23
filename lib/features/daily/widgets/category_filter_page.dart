import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transaction/transaction_provider.dart';
import '../../../models/transaction.dart';
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
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodySmall!.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
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
          unselectedLabelColor: textSecondary,
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
          _buildCategoryList(context, provider.incomeCategories),
          _buildCategoryList(context, provider.expenseCategories),
          _buildAccountList(context, provider.accounts, provider),
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

  Widget _buildCategoryList(BuildContext context, List categories) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge!.color;
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
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
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
            style: TextStyle(color: textPrimary),
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

  Widget _buildAccountList(
    BuildContext context,
    List accounts,
    TransactionProvider provider,
  ) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge!.color;
    final allNames = accounts.map((a) => a.name as String).toSet();
    final allChecked = allNames.isNotEmpty &&
        allNames.every((name) => _selectedAccounts.contains(name));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Income', style: TextStyle(color: Colors.blue, fontSize: 12)),
                    Text(
                      'Transfer-In',
                      style: TextStyle(color: Colors.blue.withOpacity(0.6), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Expenses', style: TextStyle(color: AppTheme.accentRed, fontSize: 12)),
                    Text(
                      'Transfer-Out',
                      style: TextStyle(color: AppTheme.accentRed.withOpacity(0.6), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: accounts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return CheckboxListTile(
                  value: allChecked,
                  activeColor: AppTheme.accentRed,
                  title: Text(
                    'All',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
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
              final income = _accountTotal(provider, account.name, TransactionType.income);
              final expense = _accountTotal(provider, account.name, TransactionType.expense);
              final transferIn = _accountTransferTotal(provider, account.name, incoming: true);
              final transferOut = _accountTransferTotal(provider, account.name, incoming: false);

              return CheckboxListTile(
                value: isChecked,
                activeColor: AppTheme.accentRed,
                title: Text(account.name, style: TextStyle(color: textPrimary)),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            income.toStringAsFixed(2),
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                          Text(
                            transferIn.toStringAsFixed(2),
                            style: TextStyle(color: Colors.blue.withOpacity(0.6), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            expense.toStringAsFixed(2),
                            style: TextStyle(color: AppTheme.accentRed, fontSize: 12),
                          ),
                          Text(
                            transferOut.toStringAsFixed(2),
                            style: TextStyle(color: AppTheme.accentRed.withOpacity(0.6), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          ),
        ),
      ],
    );
  }

  double _accountTotal(
    TransactionProvider provider,
    String accountName,
    TransactionType type,
  ) {
    return provider.all
        .where((t) => t.type == type && t.account?.name == accountName)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _accountTransferTotal(
    TransactionProvider provider,
    String accountName, {
    required bool incoming,
  }) {
    return provider.all
        .where((t) =>
            t.type == TransactionType.transfer &&
            (incoming
                ? t.toAccount?.name == accountName
                : t.fromAccount?.name == accountName))
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}