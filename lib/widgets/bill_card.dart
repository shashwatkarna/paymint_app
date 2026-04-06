import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../models/bill_model.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
    if (bill.isPaid) return const Color(0xFF10B981); // Emerald Glow
    if (bill.nextDueDate.isBefore(DateTime.now())) return const Color(0xFFF43F5E); // Rose Glow
    if (bill.nextDueDate.difference(DateTime.now()).inDays <= 3) {
      return const Color(0xFFFBBF24); // Amber Glow
    }
    return const Color(0xFF8B5CF6); // Violet Glow
  }

  bool _isRecentlyPaid() {
    if (bill.lastPaidDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final paidDate = DateTime(bill.lastPaidDate!.year, bill.lastPaidDate!.month, bill.lastPaidDate!.day);
    return paidDate == today;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final recentlyPaid = _isRecentlyPaid();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GlassContainer(
        height: 110,
        width: double.infinity,
        blur: 25,
        opacity: 0.08,
        border: Border.fromBorderSide(
          BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                // Neon Status Indicator
                Container(
                  width: 6,
                  height: 45,
                  decoration: BoxDecoration(
                    color: recentlyPaid ? const Color(0xFF10B981) : statusColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (recentlyPaid ? const Color(0xFF10B981) : statusColor).withValues(alpha: 0.6),
                        blurRadius: 12,
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
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            recentlyPaid ? Icons.check_circle_outline_rounded : Icons.calendar_today_outlined,
                            size: 14,
                            color: recentlyPaid ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            recentlyPaid 
                              ? 'Settled Today'
                              : 'Due: ${DateFormat('MMM dd, yyyy').format(bill.nextDueDate)}',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: recentlyPaid ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
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
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: recentlyPaid ? Colors.white70 : const Color(0xFFC59AFF),
                        ),
                      ),
                    if (!bill.isPaid && !recentlyPaid)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: TextButton(
                          onPressed: onMarkPaid,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'MARK PAID',
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    if (recentlyPaid)
                      const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 24),
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
