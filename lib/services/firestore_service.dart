import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'bills';

  /// Adds a new bill to Firestore and schedules notifications.
  Future<void> addBill(BillModel bill) async {
    final docRef = _db.collection(_collection).doc();
    final newBill = BillModel.fromFirestore(bill.toFirestore(), docRef.id);
    await docRef.set(newBill.toFirestore());
    await NotificationService.scheduleBillNotifications(newBill);
  }

  /// Updates an existing bill.
  Future<void> updateBill(BillModel bill) async {
    await _db.collection(_collection).doc(bill.id).update(bill.toFirestore());
    await NotificationService.cancelNotifications(bill.id.hashCode);
    await NotificationService.scheduleBillNotifications(bill);
  }

  /// Marks a bill as paid and updates the next due date for recurring bills.
  Future<void> markAsPaid(BillModel bill) async {
    final now = DateTime.now();
    if (bill.frequency == RecurringFrequency.none) {
      await _db.collection(_collection).doc(bill.id).update({
        'isPaid': true,
        'lastPaidDate': Timestamp.fromDate(now),
      });
    } else {
      final nextDate =
          BillModel.calculateNextDueDate(bill.nextDueDate, bill.frequency);
      final updatedBill = bill.copyWith(
        isPaid: false, // Reset paid status for the next cycle
        dueDate: bill.nextDueDate,
        nextDueDate: nextDate,
        lastPaidDate: now, // Record it was paid today
      );
      await updateBill(updatedBill);
    }
  }

  /// Deletes a bill and cancels its notifications.
  Future<void> deleteBill(String id) async {
    await _db.collection(_collection).doc(id).delete();
    await NotificationService.cancelNotifications(id.hashCode);
  }

  /// Streams all bills from Firestore.
  Stream<List<BillModel>> streamBills() {
    return _db.collection(_collection).orderBy('nextDueDate').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => BillModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
