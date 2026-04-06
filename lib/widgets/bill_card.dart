import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../models/bill_model.dart';
import 'package:intl/intl.dart';

class BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onMarkPaid,
  });

  Color _getStatusColor() {
    if (bill.isPaid) return Colors.greenAccent;
    if (bill.nextDueDate.isBefore(DateTime.now())) return const Color(0xFFFF6E84);
    if (bill.nextDueDate.difference(DateTime.now()).inDays <= 3) {
      return const Color(0xFFFBBF24);
    }
    return const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        height: 100,
        width: double.infinity,
        blur: 15,
        border: Border.fromBorderSide(
          BorderSide(color: statusColor.withValues(alpha: 0.2), width: 1),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(bill.nextDueDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (bill.amount != null)
                      Text(
                        '\$${bill.amount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC59AFF),
                        ),
                      ),
                    if (!bill.isPaid)
                      TextButton(
                        onPressed: onMarkPaid,
                        child: const Text('Mark Paid',
                            style: TextStyle(color: Colors.greenAccent)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
