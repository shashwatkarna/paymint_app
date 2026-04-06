import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';
import '../services/firestore_service.dart';

class AddBillScreen extends StatefulWidget {
  final BillModel? bill;

  const AddBillScreen({super.key, this.bill});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _category = 'Credit Card';
  RecurringFrequency _frequency = RecurringFrequency.monthly;

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
      final bill = BillModel(
        id: widget.bill?.id ?? '',
        name: _nameController.text,
        amount: double.tryParse(_amountController.text),
        dueDate: widget.bill?.dueDate ?? _dueDate,
        nextDueDate: _dueDate,
        category: _category,
        frequency: _frequency,
      );

      if (widget.bill == null) {
        await FirestoreService().addBill(bill);
      } else {
        await FirestoreService().updateBill(bill);
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill == null ? 'Add New Bill' : 'Edit Bill'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF060E20),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Bill Name'),
                  _buildTextField(_nameController, 'e.g. HDFC Credit Card'),
                  const SizedBox(height: 20),
                  _buildLabel('Amount (Optional)'),
                  _buildTextField(_amountController, 'e.g. 5000', isNumber: true),
                  const SizedBox(height: 20),
                  _buildLabel('Due Date'),
                  _buildDatePicker(),
                  const SizedBox(height: 20),
                  _buildLabel('Category'),
                  _buildCategorySelector(),
                  const SizedBox(height: 20),
                  _buildLabel('Frequency'),
                  _buildFrequencySelector(),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return GlassContainer(
      blur: 20,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) => value!.isEmpty && !isNumber ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return GlassContainer(
      blur: 20,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(15),
      child: ListTile(
        title: Text(
          DateFormat('EEEE, MMM dd, yyyy').format(_dueDate),
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _dueDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) setState(() => _dueDate = picked);
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Credit Card', 'EMI', 'Rent', 'Subscription', 'Utility'];
    return Wrap(
      spacing: 10,
      children: categories
          .map((c) => ChoiceChip(
                label: Text(c, style: TextStyle(color: _category == c ? Colors.white : Colors.white70)),
                selected: _category == c,
                onSelected: (val) => setState(() => _category = c),
                selectedColor: const Color(0xFF8B5CF6),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
              ))
          .toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return Wrap(
      spacing: 10,
      children: RecurringFrequency.values
          .map((f) => ChoiceChip(
                label: Text(
                  f.toString().split('.').last.toUpperCase(),
                  style: TextStyle(color: _frequency == f ? Colors.white : Colors.white70),
                ),
                selected: _frequency == f,
                onSelected: (val) => setState(() => _frequency = f),
                selectedColor: const Color(0xFF8B5CF6),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
              ))
          .toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: GlassContainer(
        blur: 20,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFC59AFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _saveBill,
          child: const Center(
            child: Text(
              'Save Bill',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
