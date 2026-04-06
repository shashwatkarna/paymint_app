import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bill_model.dart';
import '../services/firestore_service.dart';

/// Provider for the stream of all bills from Firestore.
final billStreamProvider = StreamProvider<List<BillModel>>((ref) {
  return FirestoreService().streamBills();
});
