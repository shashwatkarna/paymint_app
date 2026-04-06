import '../models/bill_model.dart';

class BillUtils {
  static bool isPaidInCurrentMonth(BillModel bill) {
    if (bill.lastPaidDate == null) return false;
    final now = DateTime.now();
    return bill.lastPaidDate!.month == now.month && 
           bill.lastPaidDate!.year == now.year;
  }

  static bool isDueInCurrentMonth(BillModel bill) {
    final now = DateTime.now();
    return bill.nextDueDate.month == now.month && 
           bill.nextDueDate.year == now.year;
  }

  static String getCurrencySymbol(String code) {
    switch (code) {
      case 'INR': return '₹';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'USD': return '\$';
      default: return '\$';
    }
  }
}
