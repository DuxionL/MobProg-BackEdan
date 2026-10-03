import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  TransactionType _type = TransactionType.income;
  DateTime _dateTime = DateTime.now();

  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();

  Category? _category;
  Account? _account;
  Account? _fromAccount;
  Account? _toAccount;
  bool _showValidationErrors = false;

  bool get _isEditing => widget.transaction != null && !widget.isDuplicate;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _dateTime = widget.transaction!.dateTime;
      _amountController.text = _formatAmountNumber(widget.transaction!.amount);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _showValidationErrors = true);
      return;
    }

    final provider = context.read<TransactionProvider>();
    final amount = _parseAmount(_amountController.text)!;
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
      body: Form(
        key: _formKey,
        autovalidateMode: _showValidationErrors
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type selector
            SegmentedButton<TransactionType>(
              segments: TransactionType.values
                  .map(
                    (type) =>
                        ButtonSegment(value: type, label: Text(type.label)),
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
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const [_ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
              ),
              validator: (value) {
                final amount = _parseAmount(value);
                if (amount == null || !amount.isFinite) {
                  return 'Enter a valid amount';
                }
                if (amount <= 0) return 'Amount must be greater than zero';
                return null;
              },
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
        validator: (index) => index == null ? 'Select a category' : null,
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
        validator: (id) => id == null ? 'Select an account' : null,
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
      TextFormField(
        controller: _feeController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Fee (optional)',
          prefixText: 'Rp ',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return null;
          final fee = double.tryParse(value.trim());
          if (fee == null || !fee.isFinite) return 'Enter a valid fee';
          if (fee < 0) return 'Fee cannot be negative';
          return null;
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _fromAccount?.id,
        decoration: const InputDecoration(labelText: 'From'),
        validator: (id) => id == null ? 'Select a source account' : null,
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
        validator: (id) {
          if (id == null) return 'Select a destination account';
          if (_fromAccount?.id == id) {
            return 'Choose an account different from the source';
          }
          return null;
        },
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

String _formatGroupedAmount(String value) {
  final decimalIndex = value.indexOf(',');
  final integerPart =
      (decimalIndex < 0 ? value : value.substring(0, decimalIndex)).replaceAll(
        RegExp(r'\D'),
        '',
      );
  final fractionalPart = decimalIndex < 0
      ? ''
      : value.substring(decimalIndex + 1).replaceAll(RegExp(r'\D'), '');
  final result = StringBuffer();
  for (var index = 0; index < integerPart.length; index++) {
    if (index > 0 && (integerPart.length - index) % 3 == 0) {
      result.write('.');
    }
    result.write(integerPart[index]);
  }
  if (decimalIndex >= 0) result.write(',$fractionalPart');
  return result.toString();
}

String _formatAmountNumber(double amount) {
  final fixed = amount.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  final parts = fixed.split('.');
  final input = parts.length == 1 ? parts.first : '${parts[0]},${parts[1]}';
  return _formatGroupedAmount(input);
}

double? _parseAmount(String? value) {
  final normalized = (value ?? '')
      .trim()
      .replaceAll('.', '')
      .replaceFirst(',', '.');
  return double.tryParse(normalized);
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const _ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawText = newValue.text;
    final pastedDecimal =
        oldValue.text.isEmpty && RegExp(r'^\d+\.\d{1,2}$').hasMatch(rawText);
    final typedDecimalPoint =
        rawText.endsWith('.') &&
        !oldValue.text.endsWith('.') &&
        !rawText.contains(',');
    final decimalPoint = rawText.lastIndexOf('.');
    final normalizedText = rawText.contains(',')
        ? rawText
        : (decimalPoint >= 0 && (pastedDecimal || typedDecimalPoint))
        ? '${rawText.substring(0, decimalPoint)},${rawText.substring(decimalPoint + 1)}'
        : rawText;
    final formatted = _formatGroupedAmount(normalizedText);

    int formattedOffset(int originalOffset) {
      final safeOffset = originalOffset.clamp(0, newValue.text.length).toInt();
      final logicalCharacterCount = normalizedText
          .substring(0, safeOffset)
          .replaceAll(RegExp(r'[^\d,]'), '')
          .length;
      if (logicalCharacterCount == 0) return 0;

      var seenCharacters = 0;
      for (var index = 0; index < formatted.length; index++) {
        if (RegExp(r'[\d,]').hasMatch(formatted[index])) {
          seenCharacters++;
          if (seenCharacters == logicalCharacterCount) return index + 1;
        }
      }
      return formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection(
        baseOffset: formattedOffset(newValue.selection.baseOffset),
        extentOffset: formattedOffset(newValue.selection.extentOffset),
      ),
    );
  }
}
