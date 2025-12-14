import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CanceledBookingScreen extends StatefulWidget {
  // Callback to handle navigation to details
  final Function(String) onViewDetails;

  const CanceledBookingScreen({super.key, required this.onViewDetails});

  @override
  State<CanceledBookingScreen> createState() => _CanceledBookingScreenState();
}

class _CanceledBookingScreenState extends State<CanceledBookingScreen> {
  // 1. STATE VARIABLES
  final TextEditingController _searchController = TextEditingController();
  List<CanceledBookingModel> _displayedData = [];

  @override
  void initState() {
    super.initState();
    _displayedData = List.from(_canceledDummyData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 2. SEARCH LOGIC
  void _runFilter() {
    List<CanceledBookingModel> results = [];
    String keyword = _searchController.text.toLowerCase();

    results = _canceledDummyData.where((item) {
      return item.bookingId.toLowerCase().contains(keyword) ||
          item.customerName.toLowerCase().contains(keyword) ||
          item.providerName.toLowerCase().contains(keyword);
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
            Text("Downloaded ${_displayedData.length} canceled records!"),
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
                "Canceled",
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
                    Text("Total Canceled: ", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text("${_displayedData.length}", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
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
                      
                      // Filter Button (Visual only)
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

                // TABLE
                Expanded(
                  child: _displayedData.isEmpty 
                  ? Center(child: Text("No canceled bookings found", style: GoogleFonts.inter(color: Colors.grey)))
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
                                data.providerName == "Unassigned" 
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFFFE2E5), borderRadius: BorderRadius.circular(4)),
                                    child: Text("Unassigned", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFEF4444), fontWeight: FontWeight.w600))
                                  )
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
                              // CANCELED BADGE
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE2E5), // Red bg
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Canceled",
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444)),
                                ),
                              )),
                              DataCell(Row(
                                children: [
                                  // --- UPDATED ACTION BUTTON ---
                                  _ActionButton(
                                    icon: Icons.visibility_outlined, 
                                    onTap: () {
                                      // Call the passed callback function
                                      widget.onViewDetails(data.bookingId);
                                    }
                                  ),
                                  const SizedBox(width: 8),
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
// DATA MODEL (Specific to Canceled)
// -----------------------------------------------------------------------------
class CanceledBookingModel {
  final String sl, bookingId, bookingDate, bookingTime, location;
  final String scheduleDate, scheduleTime, customerName, customerPhone;
  final String providerName, providerCompany, providerPhone, amount;

  CanceledBookingModel({
    required this.sl, required this.bookingId, required this.bookingDate, 
    required this.bookingTime, required this.location, required this.scheduleDate, 
    required this.scheduleTime, required this.customerName, required this.customerPhone,
    required this.providerName, this.providerCompany = "", required this.providerPhone,
    required this.amount,
  });
}

final List<CanceledBookingModel> _canceledDummyData = [
  CanceledBookingModel(
    sl: "1", 
    bookingId: "100028", 
    bookingDate: "23-Jan-2025", 
    bookingTime: "02:32pm", 
    location: "Customer Home (Mahanagar)", 
    scheduleDate: "22-Jan-2025", 
    scheduleTime: "10:32am", 
    customerName: "Rahul Mishra", 
    customerPhone: "+91 94150 12345", 
    providerName: "Suresh Electrician", 
    providerCompany: "Suresh Services", 
    providerPhone: "+91 88552 21100", 
    amount: "₹1,250.00"
  ),
  CanceledBookingModel(
    sl: "2", 
    bookingId: "100027", 
    bookingDate: "23-Jan-2025", 
    bookingTime: "02:31pm", 
    location: "Customer Home (Gomti Nagar Ext)", 
    scheduleDate: "22-Jan-2025", 
    scheduleTime: "10:31am", 
    customerName: "Rahul Mishra", 
    customerPhone: "+91 94150 12345", 
    providerName: "Urban Cleaners", 
    providerCompany: "Lucknow Hygiene Pvt", 
    providerPhone: "+91 99360 54321", 
    amount: "₹850.00"
  ),
  CanceledBookingModel(
    sl: "3", 
    bookingId: "100012", 
    bookingDate: "23-Jan-2025", 
    bookingTime: "02:24pm", 
    location: "Customer Home (Alambagh)", 
    scheduleDate: "22-Jan-2025", 
    scheduleTime: "10:22am", 
    customerName: "Rahul Mishra", 
    customerPhone: "+91 94150 12345", 
    providerName: "Unassigned", 
    providerCompany: "", 
    providerPhone: "", 
    amount: "₹450.00"
  ),
  CanceledBookingModel(
    sl: "4", 
    bookingId: "100003", 
    bookingDate: "23-Jan-2025", 
    bookingTime: "02:08pm", 
    location: "Customer Home (Indira Nagar)", 
    scheduleDate: "22-Jan-2025", 
    scheduleTime: "10:08am", 
    customerName: "Neha Singh", 
    customerPhone: "+91 78901 23456", 
    providerName: "AC Experts Lko", 
    providerCompany: "Cool Air Services", 
    providerPhone: "+91 98390 11223", 
    amount: "₹2,500.00"
  ),
];