class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  });

  // Convert to Map for SQLite insert/update
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  // Parse from SQLite Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      isIncome: (map['isIncome'] as int) == 1,
    );
  }

  // Copy with helper
  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    bool? isIncome,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
