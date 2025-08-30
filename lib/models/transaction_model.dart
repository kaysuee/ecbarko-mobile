class Transaction {
  final DateTime date;
  final String type; // 'load' or 'use'
  final double amount;
  final String status;

  Transaction({
    required this.date,
    required this.type,
    required this.amount,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Parse the date and convert to Philippine timezone (UTC+8)
    DateTime philippineTime = DateTime.parse(json['dateTransaction'])
        .toUtc()
        .add(const Duration(hours: 8));

    return Transaction(
      date: philippineTime,
      type: json['type'], // or another field like 'type' if it exists
      amount: (json['payment'] as num).toDouble(),
      status: json['status'],
    );
  }
}
