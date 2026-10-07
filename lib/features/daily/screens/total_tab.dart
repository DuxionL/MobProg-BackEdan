import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/currency_formatter.dart';
import '../../../models/transaction.dart';
import '../../transaction/transaction_provider.dart';
import '../widgets/summary_header.dart';

class TotalTab extends StatelessWidget {
  final DateTime month;

  const TotalTab({super.key, required this.month});

  String _dmy(DateTime d) =>
      '${d.day}/${d.month}/${(d.year % 100).toString().padLeft(2, '0')}';

  bool _isCashOrBank(Account? a) =>
      a?.type == AccountType.cash || a?.type == AccountType.bank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodySmall!.color!;

    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final txs = provider.forMonth(month);

        double cashBankExpense = 0, cardExpense = 0, transferToCard = 0;
        for (final t in txs) {
          if (t.type == TransactionType.expense) {
            if (t.account?.type == AccountType.card) {
              cardExpense += t.amount;
            } else if (_isCashOrBank(t.account)) {
              cashBankExpense += t.amount;
            }
          } else if (t.type == TransactionType.transfer) {
            if (_isCashOrBank(t.fromAccount) &&
                t.toAccount?.type == AccountType.card) {
              transferToCard += t.amount;
            }
          }
        }

        final thisExpense = provider.totalExpense(month);
        final lastExpense = provider.totalExpense(
          DateTime(month.year, month.month - 1),
        );
        final compared = lastExpense > 0
            ? '${(thisExpense / lastExpense * 100).round()}%'
            : '-';

        final first = DateTime(month.year, month.month, 1);
        final last = DateTime(month.year, month.month + 1, 0);

        return Column(
          children: [
            SummaryHeader(month: month),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 26,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Accounts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_dmy(first)} ~ ${_dmy(last)}',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Compared Expenses',
                          hint: '(Last month)',
                          value: compared,
                        ),
                        _InfoRow(
                          label: 'Expenses',
                          hint: '(Cash, Accounts)',
                          value: formatRupiah(cashBankExpense),
                        ),
                        _InfoRow(
                          label: 'Expenses',
                          hint: '(Card)',
                          value: formatRupiah(cardExpense),
                        ),
                        _InfoRow(
                          label: 'Transfer',
                          hint: '(Cash, Accounts →)',
                          value: formatRupiah(transferToCard),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String hint;
  final String value;

  const _InfoRow({
    required this.label,
    required this.hint,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).textTheme.bodySmall!.color!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: label,
                style: const TextStyle(fontSize: 15),
                children: [
                  TextSpan(
                    text: ' $hint',
                    style: TextStyle(color: textSecondary),
                  ),
                ],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
