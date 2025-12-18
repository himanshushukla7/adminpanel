import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddDiscountScreen extends StatefulWidget {
  const AddDiscountScreen({super.key});

  @override
  State<AddDiscountScreen> createState() => _AddDiscountScreenState();
}

class _AddDiscountScreenState extends State<AddDiscountScreen> {
  // Form State Variables
  final _formKey = GlobalKey<FormState>();
  String _discountType = 'percentage';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  String? _selectedService = 'all';

  // Controllers
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxDiscountController = TextEditingController();

  // Date Picker Function
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

  // Reusable Label Widget
  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        children: [
          if (isRequired)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  // Reusable Input Decoration
  InputDecoration _buildInputDecoration({String? hintText, IconData? prefixIcon, String? prefixText}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Screen Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Add New Discount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create a new discount campaign for services.',
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
                  child: const Icon(Icons.settings, color: Colors.grey),
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
                    // 1. Discount Title
                    _buildLabel('Discount Title', isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration(hintText: 'e.g. Summer Sale 2025', prefixIcon: Icons.title),
                    ),
                    const SizedBox(height: 20),

                    // 2. Category & Services
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
                                  DropdownMenuItem(value: 'cleaning', child: Text('Cleaning')),
                                  DropdownMenuItem(value: 'repair', child: Text('Repair')),
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
                                  DropdownMenuItem(value: 's1', child: Text('Service 1')),
                                ],
                                onChanged: (val) => setState(() => _selectedService = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Select specific services or apply to all.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 20),

                    Divider(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 20),

                    // 3. Discount amount type
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

                    // 4. Amount, Start Date, End Date
                    Row(
                      children: [
                        // Amount
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
                        // Start Date
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
                                    decoration: _buildInputDecoration(hintText: 'MM/DD/YYYY', prefixIcon: Icons.calendar_today),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // End Date
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
                                    decoration: _buildInputDecoration(hintText: 'MM/DD/YYYY', prefixIcon: Icons.calendar_today),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 5. Min Purchase & Max Discount
                    Row(
                      children: [
                        // Min Purchase
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
                        // Max Discount
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
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate and Submit
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB5725),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
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