import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/features/transaction/transaction_provider.dart';
import 'package:money_manager/models/transaction.dart';

//help
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

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
      return _fromAccount != null && _toAccount != null;
    }
    return _category != null && _account != null;
  }

  void _save() {
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill amount, category and account.')),
      );
      return;
    }

    final provider = context.read<TransactionProvider>();
    final amount = double.parse(_amountController.text);
    final fee = double.tryParse(_feeController.text) ?? 0;

    final transaction = Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
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

    provider.addTransaction(transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final categories = _type == TransactionType.income
        ? provider.incomeCategories
        : provider.expenseCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type selector
          Row(
            children: TransactionType.values.map((t) {
              return Expanded(
                child: RadioListTile<TransactionType>(
                  title: Text(t.label),
                  value: t,
                  groupValue: _type,
                  onChanged: (v) => setState(() {
                    _type = v!;
                    _category = null;
                    _account = null;
                    _fromAccount = null;
                    _toAccount = null;
                  }),
                ),
              );
            }).toList(),
          ),
          const Divider(),

          // Date
          ListTile(
            title: const Text('Date'),
            subtitle: Text(_dateTime.toString()),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDateTime,
          ),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
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

  List<Widget> _buildIncomeExpenseFields(
    List<Category> categories,
    TransactionProvider provider,
  ) {
    return [
      DropdownButtonFormField<Category>(
        initialValue: _category,
        decoration: const InputDecoration(labelText: 'Category'),
        items: categories
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text('${c.emoji} ${c.name}'),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _category = v),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<Account>(
        initialValue: _account,
        decoration: const InputDecoration(labelText: 'Account'),
        items: provider.accounts
            .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
            .toList(),
        onChanged: (v) => setState(() => _account = v),
      ),
    ];
  }

  List<Widget> _buildTransferFields(TransactionProvider provider) {
    return [
      TextField(
        controller: _feeController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Fee (optional)'),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<Account>(
        initialValue: _fromAccount,
        decoration: const InputDecoration(labelText: 'From'),
        items: provider.accounts
            .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
            .toList(),
        onChanged: (v) => setState(() => _fromAccount = v),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<Account>(
        initialValue: _toAccount,
        decoration: const InputDecoration(labelText: 'To'),
        items: provider.accounts
            .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
            .toList(),
        onChanged: (v) => setState(() => _toAccount = v),
      ),
    ];
  }
}
