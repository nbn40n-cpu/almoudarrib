class Payment {
  final int? id;
  final double amount;
  final DateTime dateTime;
  final String? notes;

  Payment({
    this.id,
    required this.amount,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }

  Payment copyWith({
    int? id,
    double? amount,
    DateTime? dateTime,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
    );
  }
}