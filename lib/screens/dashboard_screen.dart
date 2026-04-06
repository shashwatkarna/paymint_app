import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bill_model.dart';
import '../services/firestore_service.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../utils/bill_utils.dart';
import 'add_bill_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billStreamProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background System: Radial Glows
          Container(
            decoration: const BoxDecoration(color: Color(0xFF03050C)),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E293B).withValues(alpha: 0.15),
                    const Color(0xFF1E293B).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: billsAsync.when(
                    data: (bills) => _buildBillList(context, bills),
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                    error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white70))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context),
      extendBody: true,
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: const Color(0xFF8B5CF6),
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        onPressed: () => _navigateTo(context, const AddBillScreen()),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PayMint',
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              Text(
                'Intelligent Bill Management',
                style: GoogleFonts.manrope(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateTo(context, const SettingsScreen()),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillList(BuildContext context, List<BillModel> bills) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 100, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 20),
            Text('No bills yet.', style: GoogleFonts.manrope(color: Colors.white30, fontSize: 18)),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Logic Refinement: Categorizing bills
    final overdue = bills.where((b) => !b.isPaid && !BillUtils.isPaidInCurrentMonth(b) && b.nextDueDate.isBefore(today)).toList();
    final dueToday = bills.where((b) => !b.isPaid && !BillUtils.isPaidInCurrentMonth(b) &&
        b.nextDueDate.year == today.year && 
        b.nextDueDate.month == today.month && 
        b.nextDueDate.day == today.day).toList();
    
    final upcoming = bills.where((b) {
      if (b.isPaid || BillUtils.isPaidInCurrentMonth(b)) return false;
      return b.nextDueDate.isAfter(today);
    }).toList();

    final settledToday = bills.where((b) => BillUtils.isPaidInCurrentMonth(b)).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10),
      children: [
        if (overdue.isNotEmpty) ...[
          _buildSectionTitle('Overdue', const Color(0xFFF43F5E)),
          ...overdue.map((b) => BillCard(bill: b, onMarkPaid: () => _markPaid(context, b))),
        ],
        if (dueToday.isNotEmpty) ...[
          _buildSectionTitle('Due Today', const Color(0xFFFBBF24)),
          ...dueToday.map((b) => BillCard(bill: b, onMarkPaid: () => _markPaid(context, b))),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildSectionTitle('Upcoming', Colors.white54),
          ...upcoming.map((b) => BillCard(bill: b, onMarkPaid: () => _markPaid(context, b))),
        ],
        if (settledToday.isNotEmpty) ...[
          _buildSectionTitle('Settled Today', const Color(0xFF10B981)),
          ...settledToday.map((b) => BillCard(bill: b, onMarkPaid: null)),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Future<void> _markPaid(BuildContext context, BillModel bill) async {
    await FirestoreService().markAsPaid(bill);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settled ${bill.name} for this cycle!', style: GoogleFonts.manrope()),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, Color markerColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(color: markerColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 25, left: 24, right: 24),
      child: GlassContainer(
        height: 70,
        blur: 30,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(30),
        border: Border.fromBorderSide(
          BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home_filled, true, null),
            _buildNavItem(context, Icons.calendar_month_rounded, false, const CalendarScreen()),
            const SizedBox(width: 40),
            _buildNavItem(context, Icons.bar_chart_rounded, false, const StatsScreen()),
            _buildNavItem(context, Icons.settings_rounded, false, const SettingsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, bool active, Widget? screen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: screen != null ? () => _navigateTo(context, screen) : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: active ? const Color(0xFF8B5CF6) : Colors.white38,
            size: active ? 28 : 24,
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
