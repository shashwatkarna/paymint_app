import 'package:cloud_firestore/cloud_firestore.dart';

enum RecurringFrequency { none, weekly, monthly, yearly }

class BillModel {
  final String id;
  final String name;
  final double? amount;
  final DateTime dueDate;
  final DateTime nextDueDate;
  final String category;
  final RecurringFrequency frequency;
  final bool isPaid;
  final DateTime? lastPaidDate; 
  final int reminderDaysBefore; // New field for notification logic

  BillModel({
    required this.id,
    required this.name,
    this.amount,
    required this.dueDate,
    required this.nextDueDate,
    required this.category,
    this.frequency = RecurringFrequency.monthly,
    this.isPaid = false,
    this.lastPaidDate,
    this.reminderDaysBefore = 1, // Default reminder is 1 day before
  });

  factory BillModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BillModel(
      id: id,
      name: data['name'] ?? '',
      amount: data['amount']?.toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      nextDueDate: (data['nextDueDate'] as Timestamp).toDate(),
      category: data['category'] ?? 'Miscellaneous',
      frequency: RecurringFrequency.values.firstWhere(
        (f) => f.toString() == data['frequency'],
        orElse: () => RecurringFrequency.monthly,
      ),
      isPaid: data['isPaid'] ?? false,
      lastPaidDate: data['lastPaidDate'] != null 
          ? (data['lastPaidDate'] as Timestamp).toDate() 
          : null,
      reminderDaysBefore: data['reminderDaysBefore'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'category': category,
      'frequency': frequency.toString(),
      'isPaid': isPaid,
      'lastPaidDate': lastPaidDate != null ? Timestamp.fromDate(lastPaidDate!) : null,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

  BillModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    DateTime? nextDueDate,
    String? category,
    RecurringFrequency? frequency,
    bool? isPaid,
    DateTime? lastPaidDate,
    int? reminderDaysBefore,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      isPaid: isPaid ?? this.isPaid,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }

  static DateTime calculateNextDueDate(DateTime current, RecurringFrequency freq) {
    switch (freq) {
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
