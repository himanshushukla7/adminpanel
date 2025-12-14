import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerListScreen extends StatefulWidget {
  final VoidCallback? onEditCustomer;
  final VoidCallback? onViewCustomer; // 1. ADDED: Callback for Overview
  const CustomerListScreen({
    super.key, 
    this.onEditCustomer, 
    this.onViewCustomer,
  });

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _selectedTab = 'All';

  // --- Filter State Variables ---
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'Latest';
  String _selectedArea = 'All Areas';

  // --- Constants for Dropdowns ---
  final List<String> _sortOptions = ['Latest', 'Oldest', 'Bookings High', 'Bookings Low'];
  final List<String> _areaOptions = ['All Areas', 'Gomti Nagar', 'Hazratganj', 'Aliganj', 'Indira Nagar'];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryOrange, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: kTextDark, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilter() {
    // Implement your actual filtering logic here (e.g., call an API or filter the list locally)
    print("Filtering with: Start: $_startDate, End: $_endDate, Sort: $_sortBy, Area: $_selectedArea");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filter Applied: $_sortBy in $_selectedArea'), backgroundColor: kPrimaryOrange, duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header (Add Button Removed) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Customer List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextDark)),
                SizedBox(height: 4),
                Text('Manage your customers across Lucknow', style: TextStyle(color: kTextLight)),
              ],
            ),
            const SizedBox(height: 24),

            // --- Filter Card (Fully Functional) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.filter_alt_outlined, color: kPrimaryOrange, size: 20),
                      SizedBox(width: 8),
                      Text('Search Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Start Date Picker
                      Expanded(
                        child: _buildDatePickerField(
                          label: 'Start Date', 
                          selectedDate: _startDate, 
                          onTap: () => _selectDate(context, true)
                        ),
                      ),
                      const SizedBox(width: 16),
                      // End Date Picker
                      Expanded(
                        child: _buildDatePickerField(
                          label: 'End Date', 
                          selectedDate: _endDate, 
                          onTap: () => _selectDate(context, false)
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Sort Dropdown
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Sort By',
                          value: _sortBy,
                          items: _sortOptions,
                          onChanged: (val) => setState(() => _sortBy = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Area Dropdown
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Area',
                          value: _selectedArea,
                          items: _areaOptions,
                          onChanged: (val) => setState(() => _selectedArea = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Filter Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _applyFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0
                            ),
                            child: const Text('Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Table Section ---
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  // Tabs & Search Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: ['All', 'Active', 'Inactive'].map((tab) {
                                final isSelected = _selectedTab == tab;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedTab = tab),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 24),
                                    padding: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      border: isSelected ? const Border(bottom: BorderSide(color: kPrimaryOrange, width: 2)) : null,
                                    ),
                                    child: Text(
                                      tab,
                                      style: TextStyle(
                                        color: isSelected ? kPrimaryOrange : kTextLight,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            Text('Total Customers: 128', style: TextStyle(color: kTextLight, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search by name, email or phone...',
                                  prefixIcon: const Icon(Icons.search, color: kTextLight),
                                  filled: true,
                                  fillColor: kBgColor,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: const Text('Search', style: TextStyle(color: Colors.white)),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 18, color: kTextDark),
                              label: const Text('Download', style: TextStyle(color: kTextDark)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: kBorderColor),

                  // Table Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: const [
                        SizedBox(width: 40, child: Text('SL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight))),
                        Expanded(flex: 2, child: Text('CUSTOMER NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight))),
                        Expanded(flex: 2, child: Text('CONTACT INFO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight))),
                        Expanded(flex: 1, child: Text('BOOKINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight))),
                        Expanded(flex: 2, child: Text('JOINED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight))),
                        Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight))),
                        Expanded(flex: 1, child: Text('ACTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight))),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: kBorderColor),

                  // Table Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mockCustomers.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1, color: kBorderColor),
                    itemBuilder: (context, index) {
                      final customer = mockCustomers[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        color: Colors.white,
                        child: Row(
                          children: [
                            SizedBox(width: 40, child: Text('${index + 1}', style: const TextStyle(color: kTextLight))),
                            Expanded(
                              flex: 2,
                              child: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600, color: kTextDark)),
                              // Circular avatar removed here
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer.email, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: kTextDark)),
                                  Text(customer.phone, style: const TextStyle(fontSize: 12, color: kTextLight)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: kBgColor, borderRadius: BorderRadius.circular(4)),
                                    child: Text('${customer.bookings}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer.joinedDate, style: const TextStyle(fontSize: 13, color: kTextDark)),
                                  Text(customer.location, style: const TextStyle(fontSize: 12, color: kTextLight)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Switch(
                                value: customer.isActive,
                                activeColor: Colors.white,
                                activeTrackColor: kPrimaryOrange,
                                onChanged: (v) {},
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  _ActionButton(
                                    icon: Icons.edit_outlined, 
                                    color: kPrimaryOrange,
                                    onTap: widget.onEditCustomer ?? () {},
                                  ),
                                  const SizedBox(width: 8),
                                  _ActionButton(icon: Icons.delete_outline, color: Colors.red.shade400, onTap: () {}),
                                  const SizedBox(width: 8),
_ActionButton(
                                    icon: Icons.visibility_outlined, 
                                    color: kTextLight, 
                                    onTap: widget.onViewCustomer ?? () {}, 
                                  ),                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Footer Pagination
                  Padding(
                     padding: const EdgeInsets.all(20),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text('Showing 1-4 of 128 entries', style: TextStyle(color: kTextLight, fontSize: 13)),
                         Row(
                           children: [
                             OutlinedButton(onPressed: (){}, child: const Text('Prev', style: TextStyle(color: kTextLight))),
                             const SizedBox(width: 8),
                             Container(
                               width: 32, height: 32,
                               alignment: Alignment.center,
                               decoration: BoxDecoration(color: kPrimaryOrange, borderRadius: BorderRadius.circular(4)),
                               child: const Text('1', style: TextStyle(color: Colors.white)),
                             ),
                             const SizedBox(width: 8),
                             OutlinedButton(onPressed: (){}, child: const Text('2', style: TextStyle(color: kTextLight))),
                             const SizedBox(width: 8),
                             OutlinedButton(onPressed: (){}, child: const Text('Next', style: TextStyle(color: kTextLight))),
                           ],
                         )
                       ],
                     ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for Filtering ---

  Widget _buildDatePickerField({required String label, DateTime? selectedDate, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kTextLight, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}" : "mm/dd/yyyy",
                    style: TextStyle(fontSize: 13, color: selectedDate != null ? kTextDark : Colors.grey),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16, color: kTextLight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label, 
    required String value, 
    required List<String> items, 
    required ValueChanged<String?> onChanged
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kTextLight, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderColor),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: kTextLight),
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: kTextDark),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
          color: color.withOpacity(0.05),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// =============================================================================
// MODELS & CONSTANTS
// =============================================================================

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int bookings;
  final String joinedDate;
  final String location;
  final bool isActive;
  final String avatarColor; 

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bookings,
    required this.joinedDate,
    required this.location,
    required this.isActive,
    required this.avatarColor,
  });
}

// --- Mock Data ---
final List<Customer> mockCustomers = [
  Customer(id: '1', name: 'Aarav Kumar', email: 'aarav.k@gmail.com', phone: '+91 98765 43210', bookings: 12, joinedDate: '15 Jan, 2024', location: 'Gomti Nagar', isActive: true, avatarColor: '0xFFFFF3E0'),
  Customer(id: '2', name: 'Priya Singh', email: 'priya.singh88@gmail.com', phone: '+91 88901 23456', bookings: 5, joinedDate: '22 Feb, 2024', location: 'Hazratganj', isActive: true, avatarColor: '0xFFE3F2FD'),
  Customer(id: '3', name: 'Rohan Verma', email: 'rohan.v@chayankaro.com', phone: '+91 76543 21098', bookings: 0, joinedDate: '01 Mar, 2024', location: 'Aliganj', isActive: false, avatarColor: '0xFFE8F5E9'),
  Customer(id: '4', name: 'Ananya Gupta', email: 'ananya.g@gmail.com', phone: '+91 99887 76655', bookings: 8, joinedDate: '10 Mar, 2024', location: 'Indira Nagar', isActive: true, avatarColor: '0xFFF3E5F5'),
];

// --- Constants ---
const Color kPrimaryOrange = Color(0xFFFF6B00); 
const Color kTextDark = Color(0xFF1E293B);
const Color kTextLight = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kBgColor = Color(0xFFF1F5F9);