class Transaction {
  final DateTime date;
  final String type; // 'load' or 'use'
  final double amount;

  Transaction({
    required this.date,
    required this.type,
    required this.amount,
  });
}
