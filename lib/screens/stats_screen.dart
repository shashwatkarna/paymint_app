import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bill_model.dart';
import 'dashboard_screen.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billStreamProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background System
          Container(color: const Color(0xFF03050C)),
          Positioned(
            top: 200,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    const Color(0xFF0EA5E9).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(context),
                SliverToBoxAdapter(
                  child: billsAsync.when(
                    data: (bills) => _buildStatsContent(context, bills),
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                    error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white70))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: Text(
          'Analytics',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, List<BillModel> bills) {
    final totalSpent = bills.where((b) => b.isPaid).fold(0.0, (sum, b) => sum + (b.amount ?? 0));
    final totalUpcoming = bills.where((b) => !b.isPaid).fold(0.0, (sum, b) => sum + (b.amount ?? 0));
    
    // Grouping by category
    final categoryTotals = <String, double>{};
    for (var bill in bills) {
      categoryTotals[bill.category] = (categoryTotals[bill.category] ?? 0) + (bill.amount ?? 0);
    }
    final sortedCategories = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(totalSpent, totalUpcoming),
          const SizedBox(height: 32),
          _buildSectionHeader('Spending by Category'),
          const SizedBox(height: 16),
          ...sortedCategories.map((entry) => _buildCategoryRow(entry.key, entry.value, totalSpent + totalUpcoming)),
          const SizedBox(height: 40),
          _buildInsightCard(bills),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double spent, double upcoming) {
    return GlassContainer(
      blur: 25,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Spent', '\$${spent.toStringAsFixed(0)}', const Color(0xFF10B981)),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildMetric('Upcoming', '\$${upcoming.toStringAsFixed(0)}', const Color(0xFF8B5CF6)),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (spent + upcoming) > 0 ? spent / (spent + upcoming) : 0,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.manrope(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCategoryRow(String category, double amount, double total) {
    final percentage = total > 0 ? amount / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('\$${amount.toStringAsFixed(0)}', style: GoogleFonts.manrope(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(3)),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInsightCard(List<BillModel> bills) {
    final unpaidCount = bills.where((b) => !b.isPaid).length;
    return GlassContainer(
      blur: 25,
      opacity: 0.05,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFBBF24), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'You have $unpaidCount upcoming bills this cycle. Total volume is normal.',
                style: GoogleFonts.manrope(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
