import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bill_model.dart';
import '../providers/bill_provider.dart';
import '../providers/user_provider.dart';
import '../utils/bill_utils.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billStreamProvider);
    final currencyCode = ref.watch(currencyProvider);
    final symbol = BillUtils.getCurrencySymbol(currencyCode);

    return Scaffold(
      body: Stack(
        children: [
          // Background System
          Container(color: const Color(0xFF03050C)),
          _buildRadialGlow(context),
          
          SafeArea(
            child: billsAsync.when(
              data: (bills) {
                // Calculation Logic using BillUtils for cycle-aware tracking
                final spent = bills.where((b) => BillUtils.isPaidInCurrentMonth(b))
                    .fold(0.0, (sum, b) => sum + (b.amount ?? 0));
                
                final upcoming = bills.where((b) => !b.isPaid && !BillUtils.isPaidInCurrentMonth(b) && BillUtils.isDueInCurrentMonth(b))
                    .fold(0.0, (sum, b) => sum + (b.amount ?? 0));

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(context),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryCard(spent, upcoming, symbol),
                            const SizedBox(height: 32),
                            _buildSectionHeader('Spending Breakdown'),
                            const SizedBox(height: 16),
                            _buildBreakdownList(bills, symbol),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white70))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialGlow(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              const Color(0xFF8B5CF6).withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Analytics',
        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      ),
      centerTitle: true,
    );
  }


  Widget _buildSummaryCard(double spent, double upcoming, String symbol) {
    return GlassContainer(
      width: double.infinity,
      blur: 30,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(32),
      border: Border.fromBorderSide(BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Monthly Spending',
              style: GoogleFonts.manrope(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '$symbol${(spent + upcoming).toStringAsFixed(0)}',
              style: GoogleFonts.manrope(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildMetric('Spent', '$symbol${spent.toStringAsFixed(0)}', const Color(0xFF10B981)),
                const SizedBox(width: 16),
                _buildMetric('Upcoming', '$symbol${upcoming.toStringAsFixed(0)}', const Color(0xFF8B5CF6)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.manrope(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Container(height: 3, width: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
    );
  }

  Widget _buildBreakdownList(List<BillModel> bills, String symbol) {
    // Group by category
    final categories = <String, double>{};
    for (var b in bills) {
      if (b.amount != null) {
        categories[b.category] = (categories[b.category] ?? 0) + b.amount!;
      }
    }

    final sortedCategories = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.map((entry) => _buildBreakdownItem(entry.key, entry.value, symbol)).toList(),
    );
  }

  Widget _buildBreakdownItem(String category, double amount, String symbol) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        blur: 20,
        opacity: 0.05,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getCategoryIcon(category), color: const Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(category, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              Text('$symbol${amount.toStringAsFixed(0)}', style: GoogleFonts.manrope(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Credit Card': return Icons.credit_card_rounded;
      case 'EMI': return Icons.account_balance_rounded;
      case 'Rent': return Icons.home_rounded;
      case 'Subscription': return Icons.subscriptions_rounded;
      case 'Utility': return Icons.lightbulb_outline_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }
}
