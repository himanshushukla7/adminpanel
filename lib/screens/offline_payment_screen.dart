import 'dart:ui'; // Required for PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflinePaymentScreen extends StatefulWidget {
  // Navigation Callback
  final Function(String, String)? onViewDetails; 

  const OfflinePaymentScreen({super.key, this.onViewDetails});

  @override
  State<OfflinePaymentScreen> createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  // 1. STATE VARIABLES
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  List<OfflineBookingModel> _displayedData = [];

  @override
  void initState() {
    super.initState();
    _displayedData = List.from(_offlineDummyData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // 2. SEARCH LOGIC
  void _runFilter() {
    List<OfflineBookingModel> results = [];
    String keyword = _searchController.text.toLowerCase();

    results = _offlineDummyData.where((item) {
      return item.bookingId.toLowerCase().contains(keyword) ||
          item.customerName.toLowerCase().contains(keyword);
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
                "Offline Payment Booking List",
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
                    Text("Total Offline: ", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text("${_displayedData.length}", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),

        // 2. WARNING BANNER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // Light Pink
              border: Border.all(color: const Color(0xFFFECACA)), // Pink border
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "# Note: For offline payments please verify if the payments are safely received to your account. Customer is not liable if you confirm the bookings without checking payment transactions.",
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFB91C1C), height: 1.4),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 3. WHITE CARD CONTAINER
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
                      
                      // Filter Button (Visual)
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          foregroundColor: const Color(0xFF475569),
                        ),
                        icon: const Icon(Icons.filter_list, size: 18),
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

                // TABLE WITH 2-WAY SCROLLING
                Expanded(
                  child: _displayedData.isEmpty 
                  ? Center(child: Text("No offline bookings found", style: GoogleFonts.inter(color: Colors.grey)))
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: { PointerDeviceKind.touch, PointerDeviceKind.mouse },
                      ),
                      child: Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            controller: _horizontalScrollController,
                            thumbVisibility: true,
                            notificationPredicate: (notif) => notif.depth == 1,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 100), 
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(Colors.transparent),
                                  dataRowMinHeight: 70,
                                  dataRowMaxHeight: 85,
                                  horizontalMargin: 20,
                                  columnSpacing: 24,
                                  dividerThickness: 1,
                                  columns: const [
                                    DataColumn(label: _Header("SL")),
                                    DataColumn(label: _Header("BOOKING ID")),
                                    DataColumn(label: _Header("WHERE SERVICE WILL BE PROVIDED")),
                                    DataColumn(label: _Header("CUSTOMER INFO")),
                                    DataColumn(label: _Header("TOTAL AMOUNT")),
                                    DataColumn(label: _Header("PAYMENT STATUS")),
                                    DataColumn(label: _Header("SCHEDULE DATE")),
                                    DataColumn(label: _Header("BOOKING DATE")),
                                    DataColumn(label: _Header("STATUS")),
                                    DataColumn(label: _Header("ACTION")),
                                  ],
                                  rows: _displayedData.map((data) => DataRow(
                                    cells: [
                                      DataCell(Text(data.sl, style: _cellStyle())),
                                      DataCell(Text(data.bookingId, style: _cellStyle())),
                                      DataCell(Text(data.location, style: _cellStyle())),
                                      DataCell(Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data.customerName, style: _cellStyle(bold: true)),
                                          Text(data.customerPhone, style: _subStyle()),
                                        ],
                                      )),
                                      DataCell(Text(data.amount, style: _cellStyle(bold: true))),
                                      
                                      // Payment Status Badge
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE2E5), // Red/Pink bg
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(data.paymentStatus, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444))),
                                      )),

                                      DataCell(Text(data.scheduleDate, style: _cellStyle())),
                                      DataCell(Text(data.bookingDate, style: _cellStyle())),

                                      // Booking Status Badge (Pending - Blue)
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE), // Blue bg
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(data.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
                                      )),

                                      DataCell(_ActionButton(
                                        icon: Icons.visibility_outlined, 
                                        onTap: () {
                                          if (widget.onViewDetails != null) {
                                            widget.onViewDetails!(data.bookingId, data.status);
                                          }
                                        }
                                      )),
                                    ],
                                  )).toList(),
                                ),
                              ),
                            ),
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
        child: Icon(icon, size: 18, color: const Color(0xFF2563EB)), // Blue eye icon
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DATA MODEL (Specific to Offline)
// -----------------------------------------------------------------------------
class OfflineBookingModel {
  final String sl, bookingId, location, customerName, customerPhone, amount;
  final String paymentStatus, scheduleDate, bookingDate, status;

  OfflineBookingModel({
    required this.sl, required this.bookingId, required this.location, 
    required this.customerName, required this.customerPhone, required this.amount, 
    required this.paymentStatus, required this.scheduleDate, required this.bookingDate, 
    required this.status,
  });
}

final List<OfflineBookingModel> _offlineDummyData = [
  OfflineBookingModel(
    sl: "1", 
    bookingId: "100096", 
    location: "Customer Home (Alambagh)", 
    customerName: "Anjali Verma", 
    customerPhone: "+91 98765 43210", 
    amount: "₹3,200.00", 
    paymentStatus: "Unpaid", 
    scheduleDate: "14-Mar-2025 03:26pm", 
    bookingDate: "14-Mar-2025 12:26pm", 
    status: "Pending"
  ),
  OfflineBookingModel(
    sl: "2", 
    bookingId: "100095", 
    location: "Customer Home (Alambagh)", 
    customerName: "Anjali Verma", 
    customerPhone: "+91 98765 43210", 
    amount: "₹2,980.00", 
    paymentStatus: "Unpaid", 
    scheduleDate: "14-Mar-2025 03:26pm", 
    bookingDate: "14-Mar-2025 12:26pm", 
    status: "Pending"
  ),
  OfflineBookingModel(
    sl: "3", 
    bookingId: "100079", 
    location: "Customer Home (Mahanagar)", 
    customerName: "Anjali Verma", 
    customerPhone: "+91 98765 43210", 
    amount: "₹1,440.00", 
    paymentStatus: "Unpaid", 
    scheduleDate: "30-Jan-2025 09:49pm", 
    bookingDate: "30-Jan-2025 06:49pm", 
    status: "Pending"
  ),
  OfflineBookingModel(
    sl: "4", 
    bookingId: "100065", 
    location: "Customer Home (Indira Nagar)", 
    customerName: "Rohan Das", 
    customerPhone: "+91 88990 01122", 
    amount: "₹4,261.00", 
    paymentStatus: "Unpaid", 
    scheduleDate: "28-Feb-2025 10:30pm", 
    bookingDate: "28-Feb-2025 07:31pm", 
    status: "Pending"
  ),
  OfflineBookingModel(
    sl: "5", 
    bookingId: "100059", 
    location: "Office (Vibhuti Khand)", 
    customerName: "Vikram Singh", 
    customerPhone: "+91 76543 21098", 
    amount: "₹845.00", 
    paymentStatus: "Unpaid", 
    scheduleDate: "31-Aug-2025 11:26am", 
    bookingDate: "05-Sep-2025 12:02pm", 
    status: "Pending"
  ),
];