import 'dart:math'; // Required for max function
import 'package:flutter/material.dart';

// --- THEME COLORS ---
const _bg = Color(0xFFF1F5F9); 
const _panelBg = Colors.white;
const _muted = Color(0xFF64748B); 
const _textDark = Color(0xFF0F172A); 
const _border = Color(0xFFE2E8F0); 
const _orange = Color(0xFFF97316); 
const _orangeLight = Color(0xFFFFF7ED); 
const _shadow = BoxShadow(
  color: Color(0x0F000000),
  blurRadius: 12,
  offset: Offset(0, 4),
);

class BookingReportScreen extends StatefulWidget {
  const BookingReportScreen({super.key});

  @override
  State<BookingReportScreen> createState() => _BookingReportScreenState();
}

class _BookingReportScreenState extends State<BookingReportScreen> {
  // --- FILTER STATE ---
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedProvider;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  // Mock Data for Dropdowns
  final List<String> _categories = ['Cleaning', 'Plumbing', 'Electrical', 'Beauty'];
  final List<String> _subCategories = ['Deep Clean', 'Pipe Repair', 'Wiring', 'Facial'];
  final List<String> _providers = ['All Providers', 'Lucknow Home Svcs', 'Gomti Cleaners'];

  void _applyFilters() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filters applied successfully!')),
      );
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
initialEntryMode: DatePickerEntryMode.calendar,      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600), // "Decent way in screen only"
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: _orange,
                  onPrimary: Colors.white,
                  onSurface: _textDark,
                  surface: Colors.white,
                ),
                dialogBackgroundColor: Colors.white,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: _orange),
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopAppBar(),
              const SizedBox(height: 24),
              
              // Search Filters
              _buildSearchFilters(),
              const SizedBox(height: 24),
              
              // Stats & Chart (Responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1100) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(flex: 3, child: _SummaryStatsCard()),
                        SizedBox(width: 24),
                        Expanded(flex: 7, child: _BookingChartCard()),
                      ],
                    );
                  } else {
                    return Column(
                      children: const [
                        _SummaryStatsCard(isFullWidth: true),
                        SizedBox(height: 24),
                        _BookingChartCard(),
                      ],
                    );
                  }
                },
              ),
              
              const SizedBox(height: 24),
              const _BookingListCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [_shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.filter_alt_outlined, color: _orange),
              SizedBox(width: 8),
              Text(
                'Filter Booking Data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _buildDropdown('Category', _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v)),
                  _buildDropdown('Sub Category', _subCategories, _selectedSubCategory, (v) => setState(() => _selectedSubCategory = v)),
                  _buildDropdown('Provider', _providers, _selectedProvider, (v) => setState(() => _selectedProvider = v)),
                  
                  // Date Picker Field
                  SizedBox(
                    width: 240,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date Range', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDateRange,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedDateRange == null 
                                    ? 'Select Range' 
                                    : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                                  style: TextStyle(fontSize: 13, color: _selectedDateRange == null ? _muted : _textDark),
                                ),
                                const Icon(Icons.calendar_month_outlined, size: 18, color: _muted),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Submit Button
                  SizedBox(
                    height: 48,
                    width: 120,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _applyFilters,
                      icon: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                        : const Icon(Icons.search, size: 18),
                      label: Text(_isLoading ? '...' : 'Filter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue, ValueChanged<String?> onChanged) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                hint: Text('Select $label', style: const TextStyle(fontSize: 13, color: _muted)),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: _muted),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Booking Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textDark),
            ),
            SizedBox(height: 4),
            Text('Monitor booking status and revenue', style: TextStyle(fontSize: 14, color: _muted)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          color: _muted,
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: _orangeLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text('A', style: TextStyle(color: _orange, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ],
    );
  }
}

class _SummaryStatsCard extends StatelessWidget {
  final bool isFullWidth;
  const _SummaryStatsCard({this.isFullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [_shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _orangeLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.confirmation_number_outlined, color: _orange, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Total Bookings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _muted)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('1,452', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: _textDark)),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: const [
              _StatItem(color: Color(0xFFEF4444), label: 'Canceled', value: '42', icon: Icons.cancel_outlined),
              _StatItem(color: Color(0xFF10B981), label: 'Completed', value: '1,154', icon: Icons.check_circle_outline),
              _StatItem(color: Color(0xFF3B82F6), label: 'Accepted', value: '128', icon: Icons.thumb_up_outlined),
              _StatItem(color: Color(0xFFF59E0B), label: 'Ongoing', value: '85', icon: Icons.timelapse),
              _StatItem(color: Color(0xFF64748B), label: 'Pending', value: '43', icon: Icons.pending_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.color, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BookingChartCard extends StatelessWidget {
  const _BookingChartCard();

  @override
  Widget build(BuildContext context) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final values = [0.1, 0.2, 0.25, 0.5, 0.3, 0.4, 0.45, 0.6, 0.8, 0.7, 0.9, 1.0]; 

    return Container(
      height: 340, 
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [_shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Booking Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Text('2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: _muted)
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['1000', '800', '600', '400', '200', '0']
                      .map((e) => Text(e, style: const TextStyle(fontSize: 10, color: _muted)))
                      .toList(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // FIX: Explicitly reserving height for labels to prevent bottom overflow
                      const double labelHeight = 24.0;
                      final double maxBarHeight = constraints.maxHeight - labelHeight;
                      
                      final w = constraints.maxWidth / months.length;
                      
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(months.length, (i) {
                          // Prevent overflow by clamping calculation
                          double h = maxBarHeight * values[i];
                          if (h < 0) h = 0;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Tooltip(
                                message: '${(values[i] * 1000).toInt()} bookings',
                                child: Container(
                                  width: w * 0.5,
                                  height: h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        _orange.withOpacity(0.8),
                                        _orange,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 16, // Fixed height for text
                                child: Text(months[i], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _muted)),
                              ),
                            ],
                          );
                        }),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingListCard extends StatelessWidget {
  const _BookingListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [_shadow],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Recent Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark)),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _orange,
                    side: const BorderSide(color: _orange),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          
          // FIX: Use LayoutBuilder to force full width
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  // Forces table to be at least as wide as the card
                  constraints: BoxConstraints(minWidth: max(constraints.maxWidth, 1000)), 
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(_bg),
                    dataRowHeight: 70,
                    horizontalMargin: 20,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('SL', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('BOOKING ID', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('CUSTOMER INFO', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('PROVIDER INFO', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('SVC DISCOUNT', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('COUPON', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('VAT / TAX', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                      DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold, color: _muted))),
                    ],
                    rows: _sampleRows(),
                  ),
                ),
              );
            }
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Showing 1 to 5 of 132 results', style: TextStyle(fontSize: 13, color: _muted)),
                Row(
                  children: [
                    _PageButton(icon: Icons.chevron_left, onPressed: () {}),
                    const SizedBox(width: 8),
                    _PageButton(text: '1', isActive: true, onPressed: () {}),
                    const SizedBox(width: 8),
                    _PageButton(text: '2', onPressed: () {}),
                    const SizedBox(width: 8),
                    _PageButton(text: '...', onPressed: null),
                    const SizedBox(width: 8),
                    _PageButton(icon: Icons.chevron_right, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _sampleRows() {
    return [
      _buildRow('1','100131','Rajesh Kumar','+91 98765 43210','Lucknow Home Services','+91 522 2345678','₹7,600.00','₹400.00', true,'₹0.00','₹690.00'),
      _buildRow('2','100130','Priya Singh','+91 87654 32109','Gomti Nagar Cleaners','GST: 09ABCDE1234F1Z5','₹10,981.45','₹1,161.00', false,'₹0.00','₹522.45'),
      _buildRow('3','100129','Amit Verma','+91 76543 21098','Hazratganj Electricals','+91 522 4567890','₹482.50','₹50.00', false,'₹0.00','₹22.50'),
      _buildRow('4','100128','Sneha Gupta','+91 99887 76655','','-','₹8,568.00','₹200.00', true,'₹0.00','₹778.00'),
      _buildRow('5','100127','Mohd. Irfan','+91 88990 01122','Alambagh Plumbers','+91 522 9876543','₹8,722.00','₹880.00', false,'₹0.00','₹792.00'),
    ];
  }

  DataRow _buildRow(String sl, String id, String cName, String cPhone, String pName, String pPhone, String amt, String disc, bool hasCampaign, String cpn, String vat) {
    final bool providerMissing = pName.isEmpty;
    
    return DataRow(cells: [
      DataCell(Text(sl, style: const TextStyle(color: _muted))),
      DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(cName, style: const TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
          Text(cPhone, style: const TextStyle(fontSize: 11, color: _muted)),
        ],
      )),
      DataCell(
        providerMissing 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(16)),
            child: const Text('Provider Not Available', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(pName, style: const TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
              Text(pPhone, style: const TextStyle(fontSize: 11, color: _muted)),
            ],
          )
      ),
      DataCell(Text(amt, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(disc, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (hasCampaign)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
              child: const Text('Campaign', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            )
        ],
      )),
      DataCell(Text(cpn)),
      DataCell(Text(vat)),
      DataCell(
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF818CF8)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF4F46E5)),
            onPressed: () {},
          ),
        ),
      ),
    ]);
  }
}

class _PageButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool isActive;
  final VoidCallback? onPressed;

  const _PageButton({this.text, this.icon, this.isActive = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 32, height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? _orange : Colors.white,
          border: Border.all(color: isActive ? _orange : _border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: icon != null 
          ? Icon(icon, size: 16, color: _muted)
          : Text(text!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isActive ? Colors.white : _muted)),
      ),
    );
  }
}