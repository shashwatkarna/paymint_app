import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';

class SettlementHistoryScreen extends ConsumerWidget {
  const SettlementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billStreamProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Settlement History',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF03050C)),
          
          // Background Glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.1),
                    const Color(0xFF10B981).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: billsAsync.when(
              data: (bills) {
                // Filter for settled bills
                final settledBills = bills.where((b) => b.isPaid || b.lastPaidDate != null).toList();
                
                // Sort by settlement date (newest first)
                settledBills.sort((a, b) {
                  final dateA = a.settledAt ?? a.lastPaidDate ?? DateTime(0);
                  final dateB = b.settledAt ?? b.lastPaidDate ?? DateTime(0);
                  return dateB.compareTo(dateA);
                });

                if (settledBills.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 60, color: Colors.white10),
                        const SizedBox(height: 16),
                        Text(
                          'No settled transactions yet.',
                          style: GoogleFonts.manrope(color: Colors.white38),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: settledBills.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BillCard(
                        bill: settledBills[index],
                        onMarkPaid: null, // Read-only in history
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
              error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }
}
