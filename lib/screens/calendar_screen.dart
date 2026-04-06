import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../models/bill_model.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../services/firestore_service.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<BillModel> _getBillsForDay(DateTime day, List<BillModel> bills) {
    return bills.where((bill) {
      return isSameDay(bill.nextDueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF060E20)),
        child: billsAsync.when(
          data: (bills) => Column(
            children: [
              _buildCalendar(bills),
              const SizedBox(height: 20),
              Expanded(child: _buildBillList(bills)),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  Widget _buildCalendar(List<BillModel> bills) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        blur: 20,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(25),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) => _getBillsForDay(day, bills),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Color(0xFFFF6F7E)),
            todayTextStyle: TextStyle(color: Colors.white),
            defaultTextStyle: TextStyle(color: Colors.white70),
            todayDecoration: BoxDecoration(
              color: Color(0x338B5CF6),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xFF8B5CF6),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Color(0xFFC59AFF),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBillList(List<BillModel> bills) {
    final selectedBills = _getBillsForDay(_selectedDay!, bills);

    if (selectedBills.isEmpty) {
      return const Center(
        child: Text('No bills due on this day.', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      itemCount: selectedBills.length,
      itemBuilder: (context, index) {
        final bill = selectedBills[index];
        return BillCard(
          bill: bill,
          onMarkPaid: () => FirestoreService().markAsPaid(bill),
        );
      },
    );
  }
}
