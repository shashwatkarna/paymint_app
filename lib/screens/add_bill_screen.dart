import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';
import '../services/firestore_service.dart';
import '../providers/user_provider.dart';
import '../utils/bill_utils.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  final BillModel? bill;

  const AddBillScreen({super.key, this.bill});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _category = 'Credit Card';
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _nameController.text = widget.bill!.name;
      _amountController.text = widget.bill!.amount?.toString() ?? '';
      _dueDate = widget.bill!.nextDueDate;
      _category = widget.bill!.category;
      _frequency = widget.bill!.frequency;
    }
  }

  void _saveBill() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final bill = BillModel(
        id: widget.bill?.id ?? '',
        name: _nameController.text,
        amount: double.tryParse(_amountController.text),
        dueDate: widget.bill?.dueDate ?? _dueDate,
        nextDueDate: _dueDate,
        category: _category,
        frequency: _frequency,
      );

      try {
        if (widget.bill == null) {
          await FirestoreService().addBill(bill);
        } else {
          await FirestoreService().updateBill(bill);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${bill.name} saved successfully!', style: GoogleFonts.manrope(color: Colors.white)),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving bill: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(currencyProvider);
    final symbol = BillUtils.getCurrencySymbol(currencyCode);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.bill == null ? 'Add New Bill' : 'Edit Bill',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background System
          Container(color: const Color(0xFF03050C)),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    const Color(0xFF8B5CF6).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Bill Name'),
                    _buildTextField(_nameController, 'e.g. HDFC Credit Card', null, iconData: Icons.receipt_long_rounded),
                    const SizedBox(height: 24),
                    _buildLabel('Amount (Optional)'),
                    _buildTextField(_amountController, 'e.g. 5000', symbol, isNumber: true),
                    const SizedBox(height: 24),
                    _buildLabel('Due Date'),
                    _buildDatePicker(),
                    const SizedBox(height: 24),
                    _buildLabel('Category'),
                    _buildCategorySelector(),
                    const SizedBox(height: 24),
                    _buildLabel('Frequency'),
                    _buildFrequencySelector(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
          
          if (_isSaving)
            const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, String? symbol, {IconData? iconData, bool isNumber = false}) {
    return GlassContainer(
      blur: 25,
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      border: Border.fromBorderSide(
        BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.manrope(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: symbol != null 
            ? Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(symbol, style: GoogleFonts.manrope(color: const Color(0xFF8B5CF6), fontSize: 18, fontWeight: FontWeight.bold)),
              )
            : (iconData != null ? Icon(iconData, color: const Color(0xFF8B5CF6), size: 20) : null),
          hintStyle: GoogleFonts.manrope(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) => value!.isEmpty && !isNumber ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return GlassContainer(
      blur: 25,
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      border: Border.fromBorderSide(
        BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B5CF6), size: 20),
        title: Text(
          DateFormat('EEEE, MMM dd, yyyy').format(_dueDate),
          style: GoogleFonts.manrope(color: Colors.white, fontSize: 16),
        ),
        trailing: const Icon(Icons.edit_calendar_rounded, color: Colors.white38, size: 20),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _dueDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF8B5CF6),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E293B),
                ),
              ),
              child: child!,
            ),
          );
          if (picked != null) setState(() => _dueDate = picked);
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Credit Card', 'EMI', 'Rent', 'Subscription', 'Utility'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((c) => _buildChip(c, _category == c, () => setState(() => _category = c))).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: RecurringFrequency.values
          .map((f) => _buildChip(
                f.toString().split('.').last.toUpperCase(),
                _frequency == f,
                () => setState(() => _frequency = f),
              ))
          .toList(),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onSelected) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GlassContainer(
        blur: 20,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _isSaving ? null : _saveBill,
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Text(
              'Confirm Changes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
