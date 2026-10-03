import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/features/transaction/transaction_provider.dart';
import 'package:money_manager/models/transaction.dart';

//help
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({
    super.key,
    this.transaction,
    this.isDuplicate = false,
  });

  final Transaction? transaction;
  final bool isDuplicate;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionType _type = TransactionType.income;
  DateTime _dateTime = DateTime.now();

  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();

  Category? _category;
  Account? _account;
  Account? _fromAccount;
  Account? _toAccount;

  bool get _isEditing => widget.transaction != null && !widget.isDuplicate;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _dateTime = widget.transaction!.dateTime;
      _amountController.text = widget.transaction!.amount.toString();
      _feeController.text = (widget.transaction!.fee ?? 0).toString();
      _noteController.text = widget.transaction!.note ?? '';
      _category = widget.transaction!.category;
      _account = widget.transaction!.account;
      _fromAccount = widget.transaction!.fromAccount;
      _toAccount = widget.transaction!.toAccount;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dateTime.hour,
        time?.minute ?? _dateTime.minute,
      );
    });
  }

  bool _validate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return false;
    if (_type == TransactionType.transfer) {
      if (_fromAccount == null || _toAccount == null) return false;
      if (_fromAccount!.id == _toAccount!.id) return false;
      return true;
    }
    return _category != null && _account != null;
  }

  Future<void> _save() async {
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fill amount, category and account. Transfers need different accounts.',
          ),
        ),
      );
      return;
    }

    final provider = context.read<TransactionProvider>();
    final amount = double.parse(_amountController.text);
    final fee = double.tryParse(_feeController.text) ?? 0;
    final transactionId = _isEditing
        ? widget.transaction!.id
        : (widget.isDuplicate
              ? DateTime.now().microsecondsSinceEpoch.toString()
              : DateTime.now().microsecondsSinceEpoch.toString());

    final transaction = Transaction(
      id: transactionId,
      type: _type,
      dateTime: _dateTime,
      amount: amount,
      category: _type == TransactionType.transfer ? null : _category,
      account: _type == TransactionType.transfer ? null : _account,
      fromAccount: _type == TransactionType.transfer ? _fromAccount : null,
      toAccount: _type == TransactionType.transfer ? _toAccount : null,
      fee: _type == TransactionType.transfer ? fee : 0,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (_isEditing) {
      await provider.updateTransaction(transaction);
    } else {
      await provider.addTransaction(transaction);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final categories = _type == TransactionType.income
        ? provider.incomeCategories
        : provider.expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit Transaction'
              : widget.isDuplicate
              ? 'Duplicate Transaction'
              : 'Add Transaction',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type selector
          SegmentedButton<TransactionType>(
            segments: TransactionType.values
                .map(
                  (type) => ButtonSegment(value: type, label: Text(type.label)),
                )
                .toList(),
            selected: {_type},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                _selectType(selection.first);
              }
            },
          ),
          const Divider(),

          // Date
          ListTile(
            title: const Text('Date'),
            subtitle: Text(_formatDateTime(_dateTime)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDateTime,
          ),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 12),

          if (_type == TransactionType.transfer)
            ..._buildTransferFields(provider)
          else
            ..._buildIncomeExpenseFields(categories, provider),

          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),

          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }

  void _selectType(TransactionType type) {
    setState(() {
      _type = type;
      _category = null;
      _account = null;
      _fromAccount = null;
      _toAccount = null;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
  }

  List<Widget> _buildIncomeExpenseFields(
    List<Category> categories,
    TransactionProvider provider,
  ) {
    final selectedCategoryIndex = _category == null
        ? null
        : categories.indexWhere(
            (category) =>
                category.name == _category!.name &&
                category.emoji == _category!.emoji,
          );
    final categoryValue =
        selectedCategoryIndex != null && selectedCategoryIndex >= 0
        ? selectedCategoryIndex
        : null;

    return [
      DropdownButtonFormField<int>(
        initialValue: categoryValue,
        decoration: const InputDecoration(labelText: 'Category'),
        items: [
          for (var index = 0; index < categories.length; index++)
            DropdownMenuItem(
              value: index,
              child: Text(
                '${categories[index].emoji} ${categories[index].name}',
              ),
            ),
        ],
        onChanged: (index) => setState(() {
          _category = index == null ? null : categories[index];
        }),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _account?.id,
        decoration: const InputDecoration(labelText: 'Account'),
        items: provider.accounts
            .map(
              (account) => DropdownMenuItem(
                value: account.id,
                child: Text(account.name),
              ),
            )
            .toList(),
        onChanged: (id) => setState(() {
          _account = id == null
              ? null
              : provider.accounts.firstWhere((account) => account.id == id);
        }),
      ),
    ];
  }

  List<Widget> _buildTransferFields(TransactionProvider provider) {
    return [
      TextField(
        controller: _feeController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Fee (optional)',
          prefixText: 'Rp ',
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _fromAccount?.id,
        decoration: const InputDecoration(labelText: 'From'),
        items: provider.accounts
            .map(
              (account) => DropdownMenuItem(
                value: account.id,
                child: Text(account.name),
              ),
            )
            .toList(),
        onChanged: (id) => setState(() {
          _fromAccount = id == null
              ? null
              : provider.accounts.firstWhere((account) => account.id == id);
        }),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _toAccount?.id,
        decoration: const InputDecoration(labelText: 'To'),
        items: provider.accounts
            .map(
              (account) => DropdownMenuItem(
                value: account.id,
                child: Text(account.name),
              ),
            )
            .toList(),
        onChanged: (id) => setState(() {
          _toAccount = id == null
              ? null
              : provider.accounts.firstWhere((account) => account.id == id);
        }),
      ),
    ];
  }
}
