import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OngoingBookingScreen extends StatefulWidget {
  final Function(String) onViewDetails;
  
  const OngoingBookingScreen({super.key, required this.onViewDetails});

  @override
  State<OngoingBookingScreen> createState() => _OngoingBookingScreenState();
}

class _OngoingBookingScreenState extends State<OngoingBookingScreen> {
  // 1. STATE VARIABLES
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All'; // Options: All, Paid, Unpaid
  List<BookingModel> _displayedData = [];

  @override
  void initState() {
    super.initState();
    _displayedData = List.from(_allDummyData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 2. SEARCH & FILTER LOGIC
  void _runFilter() {
    List<BookingModel> results = [];
    String keyword = _searchController.text.toLowerCase();

    results = _allDummyData.where((item) {
      // Search Logic
      final matchesKeyword = item.bookingId.toLowerCase().contains(keyword) ||
          item.customerName.toLowerCase().contains(keyword) ||
          item.providerName.toLowerCase().contains(keyword);
      
      // Filter Logic
      bool matchesStatus = true;
      if (_filterStatus == 'Paid') matchesStatus = item.isPaid;
      if (_filterStatus == 'Unpaid') matchesStatus = !item.isPaid;

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
            Text("Downloaded ${_displayedData.length} records successfully!"),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 4. FILTER DIALOG
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Filter by Status", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(ctx, "All Orders", 'All'),
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
        // We keep padding here so the Title isn't glued to the sidebar, 
        // but the rest of the content will be wider.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                "Ongoing",
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
                    Text("Total Request: ", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text("${_displayedData.length}", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
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
              // Round top corners only
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
                        label: Text("Filter: $_filterStatus", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
                  ? Center(child: Text("No bookings found", style: GoogleFonts.inter(color: Colors.grey)))
                  : SingleChildScrollView(
                    // FIX: REMOVED HORIZONTAL PADDING HERE so "SL" touches the left edge
                    padding: EdgeInsets.zero, 
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        // Ensure table fills width
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300), 
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.transparent),
                          dataRowMinHeight: 70,
                          dataRowMaxHeight: 85,
                          horizontalMargin: 20, // Adds nice internal spacing inside the row, but keeps edge flush
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
                                  Text("Next upcoming", style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                                  const SizedBox(height: 2),
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
                                data.providerName == "Unassigned" 
                                ? Text("Unassigned", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFEF4444), fontWeight: FontWeight.w500))
                                : Column(
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
                              DataCell(_StatusBadge(isPaid: data.isPaid)),
                              DataCell(Row(
                                children: [
// New code passes the specific ID back to the dashboard
_ActionButton(
  icon: Icons.visibility_outlined, 
  onTap: () {
    // 3. CALL THE FUNCTION WITH THE BOOKING ID
     widget.onViewDetails(data.bookingId); 
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
  final bool isPaid;
  const _StatusBadge({required this.isPaid});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFFE2E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? "Paid" : "Unpaid",
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFF75555)),
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
// DATA MODEL (Same as before)
// -----------------------------------------------------------------------------
class BookingModel {
  final String sl, bookingId, bookingDate, bookingTime, location;
  final String scheduleDate, scheduleTime, customerName, customerPhone;
  final String providerName, providerCompany, providerPhone, amount;
  final bool isPaid;

  BookingModel({
    required this.sl, required this.bookingId, required this.bookingDate, 
    required this.bookingTime, required this.location, required this.scheduleDate, 
    required this.scheduleTime, required this.customerName, required this.customerPhone,
    required this.providerName, this.providerCompany = "", required this.providerPhone,
    required this.amount, required this.isPaid,
  });
}
final List<BookingModel> _allDummyData = [
  BookingModel(
    sl: "1", 
    bookingId: "100127", 
    bookingDate: "25-Aug-2025", 
    bookingTime: "11:23am", 
    location: "Provider Center (Hazratganj)", 
    scheduleDate: "30-Aug-2025", 
    scheduleTime: "11:23am", 
    customerName: "Rajesh Gupta", 
    customerPhone: "+91 98765 43210", 
    providerName: "Amit Kumar", 
    providerCompany: "Lucknow Electronics", 
    providerPhone: "+91 99887 76655", 
    amount: "₹850.00", 
    isPaid: false
  ),
  BookingModel(
    sl: "2", 
    bookingId: "100124", 
    bookingDate: "22-Apr-2025", 
    bookingTime: "10:38am", 
    location: "Customer Home (Gomti Nagar)", 
    scheduleDate: "24-Apr-2025", 
    scheduleTime: "10:27am", 
    customerName: "Priya Singh", 
    customerPhone: "+91 87654 32109", 
    providerName: "Amit Kumar", 
    providerCompany: "Lucknow Electronics", 
    providerPhone: "+91 99887 76655", 
    amount: "₹1,200.00", 
    isPaid: false
  ),
  BookingModel(
    sl: "3", 
    bookingId: "100123", 
    bookingDate: "22-Apr-2025", 
    bookingTime: "10:37am", 
    location: "Provider Center (Aliganj)", 
    scheduleDate: "24-Apr-2025", 
    scheduleTime: "10:26am", 
    customerName: "Priya Singh", 
    customerPhone: "+91 87654 32109", 
    providerName: "Amit Kumar", 
    providerCompany: "Lucknow Electronics", 
    providerPhone: "+91 99887 76655", 
    amount: "₹450.00", 
    isPaid: false
  ),
  BookingModel(
    sl: "4", 
    bookingId: "100084", 
    bookingDate: "30-Dec-2023", 
    bookingTime: "06:52pm", 
    location: "Customer Home (Indira Nagar)", 
    scheduleDate: "30-Dec-2023", 
    scheduleTime: "09:52pm", 
    customerName: "Anjali Verma", 
    customerPhone: "+91 76543 21098", 
    providerName: "Sneha Gupta", 
    providerCompany: "Glow & Shine Salon", 
    providerPhone: "+91 88990 01122", 
    amount: "₹2,500.00", 
    isPaid: false
  ),
  BookingModel(
    sl: "5", 
    bookingId: "100083", 
    bookingDate: "30-Dec-2023", 
    bookingTime: "06:51pm", 
    location: "Customer Home (Indira Nagar)", 
    scheduleDate: "30-Dec-2023", 
    scheduleTime: "09:51pm", 
    customerName: "Anjali Verma", 
    customerPhone: "+91 76543 21098", 
    providerName: "Sneha Gupta", 
    providerCompany: "Glow & Shine Salon", 
    providerPhone: "+91 88990 01122", 
    amount: "₹900.00", 
    isPaid: true
  ),
  BookingModel(
    sl: "6", 
    bookingId: "100081", 
    bookingDate: "30-Dec-2023", 
    bookingTime: "06:50pm", 
    location: "Customer Home (Chowk)", 
    scheduleDate: "30-Dec-2023", 
    scheduleTime: "09:50pm", 
    customerName: "Anjali Verma", 
    customerPhone: "+91 76543 21098", 
    providerName: "Unassigned", 
    providerCompany: "", 
    providerPhone: "", 
    amount: "₹5,000.00", 
    isPaid: false
  ),
];