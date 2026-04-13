import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bill_model.dart';
import '../services/firestore_service.dart';
import '../providers/bill_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/bill_card.dart';
import '../utils/bill_utils.dart';
import 'add_bill_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'settlement_history_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billStreamProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Ethereal Background System: Depth & Atmosphere
          Container(decoration: const BoxDecoration(color: Color(0xFF03050C))),
          
          // Primary Atmospheric Glow (Violet)
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    const Color(0xFF8B5CF6).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Secondary Atmospheric Glow (Cyan/Deep Blue)
          Positioned(
            bottom: 100,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                    const Color(0xFF0EA5E9).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: billsAsync.when(
              data: (bills) => CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverHeader(context),
                  SliverToBoxAdapter(child: _buildHeroSummary(ref, bills)),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 120),
                    sliver: _buildSliverBillList(context, bills),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white70))),
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

  Widget _buildSliverHeader(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PayMint',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Intelligent Ledger',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            _buildProfileButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateTo(context, const SettingsScreen()),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildHeroSummary(WidgetRef ref, List<BillModel> bills) {
    final currencyCode = ref.watch(currencyProvider);
    final symbol = BillUtils.getCurrencySymbol(currencyCode);
    
    double totalUnpaid = 0;
    double totalPaid = 0;
    
    for (var b in bills) {
      if (b.amount != null) {
        if (BillUtils.isPaidInCurrentMonth(b)) {
          totalPaid += b.amount!;
        } else {
          totalUnpaid += b.amount!;
        }
      }
    }
    
    final totalCommitment = totalPaid + totalUnpaid;
    final progress = totalCommitment > 0 ? (totalPaid / totalCommitment) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GlassContainer(
        height: 200,
        width: double.infinity,
        blur: 30,
        opacity: 0.05,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MONTHLY COMMITMENT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${(progress * 100).toInt()}% SETTLED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$symbol${totalUnpaid.toStringAsFixed(0)}',
                style: GoogleFonts.manrope(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
              ),
              const Expanded(child: SizedBox(height: 8)),
              Stack(
                children: [
                   Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  ),
                   FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFC59AFF)]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Remaining Balance', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                  Text('Goal: $symbol${totalCommitment.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white24)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSliverBillList(BuildContext context, List<BillModel> bills) {
    if (bills.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.blur_on_rounded, size: 80, color: Colors.white.withValues(alpha: 0.05)),
              const SizedBox(height: 20),
              Text('Your ledger is empty.', style: GoogleFonts.inter(color: Colors.white24, fontSize: 16, letterSpacing: 0.5)),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final overdue = bills.where((b) => !b.isPaid && !BillUtils.isPaidInCurrentMonth(b) && b.nextDueDate.isBefore(today)).toList();
    final dueToday = bills.where((b) => !b.isPaid && !BillUtils.isPaidInCurrentMonth(b) &&
        b.nextDueDate.year == today.year && b.nextDueDate.month == today.month && b.nextDueDate.day == today.day).toList();
    final upcoming = bills.where((b) => !b.isPaid && !BillUtils.isPaidInCurrentMonth(b) && b.nextDueDate.isAfter(today)).toList();
    
    // Sort settled bills by timestamp (newest first) and limit to 5
    final settledToday = bills.where((b) => BillUtils.isPaidInCurrentMonth(b)).toList();
    settledToday.sort((a, b) {
      final dateA = a.settledAt ?? a.lastPaidDate ?? DateTime(0);
      final dateB = b.settledAt ?? b.lastPaidDate ?? DateTime(0);
      return dateB.compareTo(dateA);
    });
    final visibleSettled = settledToday.take(5).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        if (overdue.isNotEmpty) ...[
          _buildEtherealSectionHeader('OVERDUE', const Color(0xFFF43F5E)),
          ...overdue.asMap().entries.map((entry) => _buildStaggeredBillCard(context, entry.value, entry.key, true)),
        ],
        if (dueToday.isNotEmpty) ...[
          _buildEtherealSectionHeader('DUE TODAY', const Color(0xFFFBBF24)),
          ...dueToday.asMap().entries.map((entry) => _buildStaggeredBillCard(context, entry.value, entry.key, false)),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildEtherealSectionHeader('UPCOMING', Colors.white38),
          ...upcoming.asMap().entries.map((entry) => _buildStaggeredBillCard(context, entry.value, entry.key, false)),
        ],
        if (settledToday.isNotEmpty) ...[
          _buildEtherealSectionHeader(
            'SETTLED (RECENT)', 
            const Color(0xFF10B981),
            trailing: GestureDetector(
              onTap: () => _navigateTo(context, const SettlementHistoryScreen()),
              child: Text(
                'VIEW ALL',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
              ),
            ),
          ),
          ...visibleSettled.asMap().entries.map((entry) => _buildStaggeredBillCard(context, entry.value, entry.key, false, isSettled: true)),
        ],
      ]),
    );
  }

  Widget _buildStaggeredBillCard(BuildContext context, BillModel bill, int index, bool isOverdue, {bool isSettled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: BillCard(
        bill: bill, 
        onMarkPaid: isSettled ? null : () => _confirmAndMarkPaid(context, bill)
      ),
    );
  }

  Widget _buildEtherealSectionHeader(String title, Color color, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 24, 12),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.05))),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing,
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndMarkPaid(BuildContext context, BillModel bill) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => GlassContainer(
        blur: 20,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(24),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text('Settle Bill?', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('Confirming payment for "${bill.name}"?', style: GoogleFonts.manrope(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.manrope(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Settle', style: GoogleFonts.manrope(color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await FirestoreService().markAsPaid(bill);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settled ${bill.name}!', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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
}
