import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bill_model.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'bills';

  /// Adds a new bill to Firestore and schedules notifications.
  Future<void> addBill(BillModel bill) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection(_collection).doc();
    final newBill = bill.copyWith(id: docRef.id, userId: user.uid);
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
        'settledAt': Timestamp.fromDate(now),
      });
    } else {
      final nextDate =
          BillModel.calculateNextDueDate(bill.nextDueDate, bill.frequency);

      // Check if we've passed the end date
      bool shouldEnd = false;
      if (bill.endDateTime != null && nextDate.isAfter(bill.endDateTime!)) {
        shouldEnd = true;
      }

      if (shouldEnd) {
        // If it's the last cycle, mark as paid and stop recurring
        await _db.collection(_collection).doc(bill.id).update({
          'isPaid': true,
          'lastPaidDate': Timestamp.fromDate(now),
          'settledAt': Timestamp.fromDate(now),
          'frequency': RecurringFrequency.none.toString(),
        });
      } else {
        final updatedBill = bill.copyWith(
          isPaid: false, // Reset paid status for the next cycle
          dueDate: bill.nextDueDate,
          nextDueDate: nextDate,
          lastPaidDate: now,
          settledAt: now,
        );
        await updateBill(updatedBill);
      }
    }
  }

  /// Deletes a bill and cancels its notifications.
  Future<void> deleteBill(String id) async {
    await _db.collection(_collection).doc(id).delete();
    await NotificationService.cancelNotifications(id.hashCode);
  }

  /// Streams all bills for the CURRENT user from Firestore.
  Stream<List<BillModel>> streamBills() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('nextDueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BillModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
