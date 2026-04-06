import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../models/bill_model.dart';
import '../services/firestore_service.dart';
import '../widgets/bill_card.dart';
import 'add_bill_screen.dart';
import 'calendar_screen.dart';

final billStreamProvider = StreamProvider<List<BillModel>>((ref) {
  return FirestoreService().streamBills();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billStreamProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF060E20),
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.5,
            colors: [
              Color(0xFF1A1F3D),
              Color(0xFF060E20),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: billsAsync.when(
                  data: (bills) => _buildBillList(context, bills),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddBillScreen()),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PayMint',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              Text(
                'Smart Bill Reminders',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBillList(BuildContext context, List<BillModel> bills) {
    if (bills.isEmpty) {
      return const Center(
        child: Text('No bills added yet.', style: TextStyle(color: Colors.white54)),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final overdue = bills.where((b) => !b.isPaid && b.nextDueDate.isBefore(today)).toList();
    final dueToday = bills.where((b) => !b.isPaid && 
        b.nextDueDate.year == today.year && 
        b.nextDueDate.month == today.month && 
        b.nextDueDate.day == today.day).toList();
    final upcoming = bills.where((b) => !b.isPaid && b.nextDueDate.isAfter(today)).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        if (overdue.isNotEmpty) ...[
          _buildSectionTitle('Overdue'),
          ...overdue.map((b) => BillCard(bill: b, onMarkPaid: () => FirestoreService().markAsPaid(b))),
        ],
        if (dueToday.isNotEmpty) ...[
          _buildSectionTitle('Due Today'),
          ...dueToday.map((b) => BillCard(bill: b, onMarkPaid: () => FirestoreService().markAsPaid(b))),
        ],
        _buildSectionTitle('Upcoming'),
        ...upcoming.map((b) => BillCard(bill: b, onMarkPaid: () => FirestoreService().markAsPaid(b))),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
      child: GlassContainer(
        height: 65,
        blur: 20,
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.dashboard_rounded, color: Color(0xFF8B5CF6)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded, color: Colors.white54),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white54),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
