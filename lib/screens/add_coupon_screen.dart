import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Requires intl package

class AddCouponScreen extends StatefulWidget {
  const AddCouponScreen({super.key});

  @override
  State<AddCouponScreen> createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends State<AddCouponScreen> {
  // Form State
  final _formKey = GlobalKey<FormState>();
  String _discountType = 'percentage'; // Default radio selection
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now().add(const Duration(days: 2));
  String? _selectedCategory;
  String? _selectedService = 'all';

  // Controllers
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _amountController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _limitUserController = TextEditingController(text: '1');

  // Date Picker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEB5725), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Helper: Input Decoration
  InputDecoration _buildInputDecoration({
    String? hintText, 
    IconData? prefixIcon, 
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey, size: 20)
          : prefixText != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 14.0, bottom: 14.0),
                  child: Text(prefixText, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                )
              : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEB5725)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
    );
  }

  // Helper: Label Builder
  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        children: [
          if (isRequired)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Add New Coupon',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create a new coupon campaign for services.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.dark_mode, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Main Form Card ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW 1: Title & Code
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Coupon Title', isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _titleController,
                                decoration: _buildInputDecoration(hintText: 'e.g. Summer Sale 2025', prefixIcon: Icons.title),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Coupon Code', isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _codeController,
                                decoration: _buildInputDecoration(hintText: 'E.G. SUMMER25', prefixIcon: Icons.confirmation_number_outlined),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ROW 2: Category & Service
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Select Category', isRequired: true),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: _buildInputDecoration(),
                                hint: const Text('Choose a category...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                items: const [
                                  DropdownMenuItem(value: 'cat1', child: Text('Cleaning')),
                                  DropdownMenuItem(value: 'cat2', child: Text('Repair')),
                                ],
                                onChanged: (val) => setState(() => _selectedCategory = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Select Services', isRequired: true),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedService,
                                decoration: _buildInputDecoration(),
                                hint: const Text('All Services in Category', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('All Services in Category')),
                                ],
                                onChanged: (val) => setState(() => _selectedService = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select specific services or apply to all.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    
                    const SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 20),

                    // Discount Type Radio Buttons
                    _buildLabel('Discount amount type', isRequired: true),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'percentage',
                          groupValue: _discountType,
                          activeColor: const Color(0xFFEB5725),
                          onChanged: (val) => setState(() => _discountType = val!),
                        ),
                        const Text('Percentage (%)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 24),
                        Radio<String>(
                          value: 'fixed',
                          groupValue: _discountType,
                          activeColor: const Color(0xFFEB5725),
                          onChanged: (val) => setState(() => _discountType = val!),
                        ),
                        const Text('Fixed Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ROW 3: Amount, Start Date, End Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Amount (%)', isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: _buildInputDecoration(hintText: '0', prefixText: '% '),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Date', isRequired: true),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: _startDate == null ? '' : DateFormat('MM/dd/yyyy').format(_startDate!),
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'MM/DD/YYYY', 
                                      prefixIcon: Icons.calendar_today_outlined
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('End Date', isRequired: true),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, false),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: _endDate == null ? '' : DateFormat('MM/dd/yyyy').format(_endDate!),
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'MM/DD/YYYY', 
                                      prefixIcon: Icons.calendar_today_outlined
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ROW 4: Min Purchase, Max Discount, User Limit
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Min Purchase Amount (\$)', isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _minPurchaseController,
                                keyboardType: TextInputType.number,
                                decoration: _buildInputDecoration(hintText: '0', prefixText: '\$ '),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Max Discount (\$)', isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _maxDiscountController,
                                keyboardType: TextInputType.number,
                                decoration: _buildInputDecoration(hintText: '0', prefixText: '\$ '),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Limit For Same User', isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _limitUserController,
                                keyboardType: TextInputType.number,
                                decoration: _buildInputDecoration(hintText: '1', prefixIcon: Icons.person_outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          child: const Text('Reset', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEB5725),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}