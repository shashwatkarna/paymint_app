import 'package:cloud_firestore/cloud_firestore.dart';

enum RecurringFrequency { weekly, monthly, yearly, none }

class BillModel {
  final String id;
  final String name;
  final double? amount;
  final DateTime dueDate;
  final DateTime nextDueDate;
  final String category;
  final RecurringFrequency frequency;
  final bool isPaid;
  final int reminderDaysBefore;

  BillModel({
    required this.id,
    required this.name,
    this.amount,
    required this.dueDate,
    required this.nextDueDate,
    required this.category,
    this.frequency = RecurringFrequency.monthly,
    this.isPaid = false,
    this.reminderDaysBefore = 3,
  });

  factory BillModel.fromFirestore(Map<String, dynamic> json, String id) {
    return BillModel(
      id: id,
      name: json['name'] ?? '',
      amount: json['amount']?.toDouble(),
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      nextDueDate: (json['nextDueDate'] as Timestamp).toDate(),
      category: json['category'] ?? 'Other',
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == (json['frequency'] ?? 'monthly'),
        orElse: () => RecurringFrequency.monthly,
      ),
      isPaid: json['isPaid'] ?? false,
      reminderDaysBefore: json['reminderDaysBefore'] ?? 3,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'category': category,
      'frequency': frequency.toString().split('.').last,
      'isPaid': isPaid,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

  BillModel copyWith({
    String? name,
    double? amount,
    DateTime? dueDate,
    DateTime? nextDueDate,
    String? category,
    RecurringFrequency? frequency,
    bool? isPaid,
    int? reminderDaysBefore,
  }) {
    return BillModel(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      isPaid: isPaid ?? this.isPaid,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }

  /// Calculates the next due date based on the frequency.
  static DateTime calculateNextDueDate(DateTime current, RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.weekly:
        return current.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(current.year, current.month + 1, current.day);
      case RecurringFrequency.yearly:
        return DateTime(current.year + 1, current.month, current.day);
      case RecurringFrequency.none:
        return current;
    }
  }
}
