import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletedBookingScreen extends StatefulWidget {
  final Function(String) onViewDetails;
  
  const CompletedBookingScreen({super.key, required this.onViewDetails});

  @override
  State<CompletedBookingScreen> createState() => _CompletedBookingScreenState();
}

class _CompletedBookingScreenState extends State<CompletedBookingScreen> {
  // 1. STATE VARIABLES
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All'; 
  List<CompletedBookingModel> _displayedData = [];

  @override
  void initState() {
    super.initState();
    _displayedData = List.from(_completedDummyData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 2. SEARCH LOGIC
  void _runFilter() {
    List<CompletedBookingModel> results = [];
    String keyword = _searchController.text.toLowerCase();

    results = _completedDummyData.where((item) {
      final matchesKeyword = item.bookingId.toLowerCase().contains(keyword) ||
          item.customerName.toLowerCase().contains(keyword) ||
          item.providerName.toLowerCase().contains(keyword);
      
      bool matchesStatus = true;
      if (_filterStatus == 'Paid') matchesStatus = item.paymentStatus == 'Paid';
      if (_filterStatus == 'Unpaid') matchesStatus = item.paymentStatus == 'Unpaid';

      return matchesKeyword && matchesStatus;
    }).toList();

    setState(() {
      _displayedData = results;
    });
  }

  // 3. DOWNLOAD FUNCTION
  void _handleDownload() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text("Downloaded ${_displayedData.length} completed records!"),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E), // Green for success
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 4. FILTER DIALOG
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Filter by Payment", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(ctx, "All", 'All'),
            _buildFilterOption(ctx, "Paid Only", 'Paid'),
            _buildFilterOption(ctx, "Unpaid Only", 'Unpaid'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext ctx, String label, String value) {
    return RadioListTile<String>(
      title: Text(label, style: GoogleFonts.inter()),
      value: value,
      groupValue: _filterStatus,
      activeColor: const Color(0xFFEF7822),
      onChanged: (val) {
        setState(() => _filterStatus = val!);
        _runFilter();
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. PAGE HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                "Completed",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
               Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text("Total Completed: ", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text("${_displayedData.length}", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF22C55E))),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),

        // 2. WHITE CARD CONTAINER
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), 
                topRight: Radius.circular(16)
              ), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Column(
              children: [
                // TOOLBAR
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 44,
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _runFilter(),
                            decoration: InputDecoration(
                              hintText: 'Search ID, Name...',
                              hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(top: 8), 
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      
                      // Filter Button
                      OutlinedButton.icon(
                        onPressed: _showFilterDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          side: BorderSide(color: _filterStatus == 'All' ? const Color(0xFFE2E8F0) : const Color(0xFFEF7822)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          foregroundColor: const Color(0xFF475569),
                        ),
                        icon: Icon(Icons.filter_list, size: 18, color: _filterStatus == 'All' ? null : const Color(0xFFEF7822)),
                        label: Text("Filter", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Download Button
                      ElevatedButton.icon(
                        onPressed: _handleDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF7822),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.download, size: 18, color: Colors.white),
                        label: Text("Download", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // TABLE
                Expanded(
                  child: _displayedData.isEmpty 
                  ? Center(child: Text("No completed bookings found", style: GoogleFonts.inter(color: Colors.grey)))
                  : SingleChildScrollView(
                    padding: EdgeInsets.zero, 
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300), 
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.transparent),
                          dataRowMinHeight: 70,
                          dataRowMaxHeight: 85,
                          horizontalMargin: 20,
                          columnSpacing: 24,
                          dividerThickness: 1,
                          columns: const [
                            DataColumn(label: _Header("SL")),
                            DataColumn(label: _Header("BOOKING\nID")),
                            DataColumn(label: _Header("BOOKING\nDATE")),
                            DataColumn(label: _Header("SERVICE\nLOCATION")),
                            DataColumn(label: _Header("SCHEDULE\nDATE")),
                            DataColumn(label: _Header("CUSTOMER INFO")),
                            DataColumn(label: _Header("PROVIDER INFO")),
                            DataColumn(label: _Header("TOTAL\nAMOUNT")),
                            DataColumn(label: _Header("PAYMENT\nSTATUS")),
                            DataColumn(label: _Header("ACTION")),
                          ],
                          rows: _displayedData.map((data) => DataRow(
                            cells: [
                              DataCell(Text(data.sl, style: _cellStyle())),
                              DataCell(Text(data.bookingId, style: _cellStyle())),
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.bookingDate, style: _cellStyle(bold: true)),
                                  Text(data.bookingTime, style: _subStyle()),
                                ],
                              )),
                              DataCell(Text(data.location, style: _cellStyle())),
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.scheduleDate, style: _cellStyle(bold: true)),
                                  Text(data.scheduleTime, style: _subStyle()),
                                ],
                              )),
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.customerName, style: _cellStyle(bold: true)),
                                  Text(data.customerPhone, style: _subStyle()),
                                ],
                              )),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data.providerName, style: _cellStyle(bold: true)),
                                    if(data.providerCompany.isNotEmpty) Text(data.providerCompany, style: _cellStyle(size: 11)),
                                    Text(data.providerPhone, style: _subStyle()),
                                  ],
                                )
                              ),
                              DataCell(Text(data.amount, style: _cellStyle(bold: true))),
                              // STATUS BADGE (Green for Paid)
                              DataCell(_StatusBadge(status: data.paymentStatus)),
                              DataCell(Row(
                                children: [
// New code passes the specific ID back to the dashboard
_ActionButton(
  icon: Icons.visibility_outlined, 
  onTap: () {
    // 3. CALL THE FUNCTION WITH THE BOOKING ID
   widget.onViewDetails(data.bookingId);
   // onViewDetails(data.bookingId); 
  }
),                                  const SizedBox(width: 8),
                                  _ActionButton(icon: Icons.download_outlined, onTap: () {}),
                                ],
                              )),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STYLES & WIDGETS
  static TextStyle _cellStyle({bool bold = false, double size = 13}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      color: const Color(0xFF334155),
    );
  }

  static TextStyle _subStyle() {
    return GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8));
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8)));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFFE2E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFF75555),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DATA MODEL (Specific to Completed)
// -----------------------------------------------------------------------------
class CompletedBookingModel {
  final String sl, bookingId, bookingDate, bookingTime, location;
  final String scheduleDate, scheduleTime, customerName, customerPhone;
  final String providerName, providerCompany, providerPhone, amount;
  final String paymentStatus;

  CompletedBookingModel({
    required this.sl, required this.bookingId, required this.bookingDate, 
    required this.bookingTime, required this.location, required this.scheduleDate, 
    required this.scheduleTime, required this.customerName, required this.customerPhone,
    required this.providerName, this.providerCompany = "", required this.providerPhone,
    required this.amount, required this.paymentStatus,
  });
}

final List<CompletedBookingModel> _completedDummyData = [
  CompletedBookingModel(
    sl: "1", 
    bookingId: "100131", 
    bookingDate: "25-Aug-2025", 
    bookingTime: "11:27am", 
    location: "Customer Home (Gomti Nagar)", 
    scheduleDate: "25-Aug-2025", 
    scheduleTime: "11:28am", 
    customerName: "Vikram Singh", 
    customerPhone: "+91 98765 43210", 
    providerName: "Ramesh Gupta", 
    providerCompany: "Gupta Traders", 
    providerPhone: "+91 91234 56789", 
    amount: "₹1,200.00", 
    paymentStatus: "Paid"
  ),
  CompletedBookingModel(
    sl: "2", 
    bookingId: "100130", 
    bookingDate: "25-Aug-2025", 
    bookingTime: "11:26am", 
    location: "Customer Home (Indira Nagar)", 
    scheduleDate: "25-Aug-2025", 
    scheduleTime: "11:28am", 
    customerName: "Vikram Singh", 
    customerPhone: "+91 98765 43210", 
    providerName: "Suresh Electricals", 
    providerCompany: "Lucknow Services Pvt Ltd", 
    providerPhone: "+91 88997 76655", 
    amount: "₹2,500.00", 
    paymentStatus: "Paid"
  ),
  CompletedBookingModel(
    sl: "3", 
    bookingId: "100122", 
    bookingDate: "22-Apr-2025", 
    bookingTime: "10:35am", 
    location: "Customer Home (Aliganj)", 
    scheduleDate: "22-Apr-2025", 
    scheduleTime: "10:25am", 
    customerName: "Priya Sharma", 
    customerPhone: "+91 76543 21098", 
    providerName: "Amit Kumar", 
    providerCompany: "Amit Repairs", 
    providerPhone: "+91 99880 01122", 
    amount: "₹850.00", 
    paymentStatus: "Paid"
  ),
  CompletedBookingModel(
    sl: "4", 
    bookingId: "100121", 
    bookingDate: "22-Apr-2025", 
    bookingTime: "10:32am", 
    location: "Provider Shop (Aminabad)", 
    scheduleDate: "22-Apr-2025", 
    scheduleTime: "10:24am", 
    customerName: "Priya Sharma", 
    customerPhone: "+91 76543 21098", 
    providerName: "Amit Kumar", 
    providerCompany: "Amit Repairs", 
    providerPhone: "+91 99880 01122", 
    amount: "₹1,500.00", 
    paymentStatus: "Paid"
  ),
  CompletedBookingModel(
    sl: "5", 
    bookingId: "100119", 
    bookingDate: "23-Jan-2025", 
    bookingTime: "06:08pm", 
    location: "Customer Home (Chowk)", 
    scheduleDate: "23-Jan-2025", 
    scheduleTime: "06:10pm", 
    customerName: "Arjun Verma", 
    customerPhone: "+91 88776 65544", 
    providerName: "Amit Kumar", 
    providerCompany: "Amit Repairs", 
    providerPhone: "+91 99880 01122", 
    amount: "₹450.00", 
    paymentStatus: "Paid"
  ),
];