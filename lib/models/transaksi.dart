import 'package:hive/hive.dart';

//im learning how to use Hive while doing ts man
//imbouttadie
@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type; //buat 'Income', 'Expense', 'Transfer'

  @HiveField(4)
  final String note;

  @HiveField(5)
  final String categoryId; //4income/Expense

  @HiveField(6)
  final String accountId; //4income/Expense

  //transfer field
  @HiveField(7)
  final String sourceAccountId; //from Account

  @HiveField(8)
  final String targetAccountId; //to Account

  @HiveField(9)
  final double? fees; //pajak boi

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    this.note = '',
    required this.categoryId,
    required this.accountId,
    this.sourceAccountId = '',
    this.targetAccountId = '',
    this.fees,
  });
}
