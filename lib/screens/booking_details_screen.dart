import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

// --- IMPORTS ---
import '../models/booking_models.dart';
import '../repositories/booking_repository.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId; 
  final String bookingStatus; 
  final VoidCallback onBack;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    required this.bookingStatus,
    required this.onBack,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  // 1. STATE VARIABLES
  final BookingRepository _repo = BookingRepository();
  BookingModel? _booking;
  bool _isLoading = true;
  String _errorMessage = '';
  String _currentTab = "Details"; 

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  // 2. FETCH SPECIFIC BOOKING (Iterative Search)
  Future<void> _fetchBookingDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      BookingModel? foundBooking;
      int page = 0;
      bool hasNext = true;

      // Keep fetching pages until found or no more pages
      while (hasNext && foundBooking == null) {
        final response = await _repo.fetchBookings(page: page, size: 10); // Fetch bigger chunks
        
        try {
          foundBooking = response.content.firstWhere((b) => b.id == widget.bookingId);
        } catch (e) {
          // Not found on this page
        }

        if (foundBooking != null) break;

        // Prepare for next iteration
        if (response.content.isEmpty || page >= response.totalPages) {
          hasNext = false;
        } else {
          page++;
        }
      }

      if (!mounted) return;

      if (foundBooking != null) {
        setState(() {
          _booking = foundBooking;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Booking ID not found in database.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection error. Please try again.";
      });
      print("Error details: $e");
    }
  }

  // Helper: Status Color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'canceled': 
      case 'cancelled': return const Color(0xFFEF4444); // Red
      case 'completed': return const Color(0xFF10B981); // Green
      case 'ongoing': 
      case 'accepted': return const Color(0xFF2563EB); // Blue
      default: return const Color(0xFFEF7822); // Orange (Pending)
    }
  }

  // Helper: Date Format
  String _formatDate(String isoDate) {
    if (isoDate.isEmpty || isoDate == 'N/A') return "N/A";
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd-MMM-yyyy hh:mm a').format(dt);
    } catch (e) { return isoDate; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF7822)))
        : _errorMessage.isNotEmpty
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: widget.onBack, child: const Text("Go Back"))
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Booking Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("Booking # ${_booking!.bookingRef}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEF7822))),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_booking!.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(_booking!.status, style: TextStyle(color: _getStatusColor(_booking!.status), fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text("Booking Placed : ${_formatDate(_booking!.creationTime)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {}, 
                        icon: const Icon(Icons.description, size: 18),
                        label: const Text("Invoice"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // --- TABS ---
                  Row(
                    children: [
                      _buildTabButton("Details"),
                      const SizedBox(width: 20),
                      _buildTabButton("Status"),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 24),

                  // --- BODY ---
                  _currentTab == "Details" 
                    ? _buildDetailsView()
                    : _buildStatusView(),

                  // Back Button
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: widget.onBack, 
                      icon: const Icon(Icons.arrow_back), 
                      label: const Text("Back to List")
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildTabButton(String text) {
    bool isActive = _currentTab == text;
    return InkWell(
      onTap: () => setState(() => _currentTab = text),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: isActive ? const Border(bottom: BorderSide(color: Color(0xFFEF7822), width: 2)) : null,
        ),
        child: Text(text, style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: isActive ? const Color(0xFFEF7822) : Colors.grey,
          fontSize: 16
        )),
      ),
    );
  }

  // --- VIEW 1: DETAILS ---
  Widget _buildDetailsView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildLeftColumn()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildRightColumn()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildLeftColumn(),
              const SizedBox(height: 24),
              _buildRightColumn(),
            ],
          );
        }
      },
    );
  }

  // --- VIEW 2: STATUS TIMELINE ---
  Widget _buildStatusView() {
    int step = 1;
    String s = _booking!.status.toLowerCase();
    if (s.contains('accept') || s.contains('ongoing')) step = 2;
    if (s.contains('complet')) step = 3;
    bool isCanceled = s.contains('cancel');

    return _buildCard(
      title: "Booking Status",
      child: Column(
        children: [
          _buildTimelineItem(
            title: "Booking Placed",
            subtitle: "By ${_booking!.customerName}\n${_formatDate(_booking!.creationTime)}",
            isActive: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: isCanceled ? "Canceled" : "Accepted / Ongoing",
            subtitle: isCanceled ? "Booking was canceled" : "Provider Assigned",
            isActive: isCanceled || step >= 2,
            isLast: false,
            overrideColor: isCanceled ? Colors.red : null,
            overrideIcon: isCanceled ? Icons.close : null,
          ),
          _buildTimelineItem(
            title: "Completed",
            subtitle: "Service Done",
            isActive: !isCanceled && step >= 3,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title, required String subtitle, required bool isActive, required bool isLast,
    Color? overrideColor, IconData? overrideIcon
  }) {
    final color = overrideColor ?? (isActive ? const Color(0xFFEF7822) : Colors.grey[200]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isActive ? Icon(overrideIcon ?? Icons.check, size: 16, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2, height: 50,
                color: isActive ? (overrideColor ?? const Color(0xFFEF7822)).withOpacity(0.5) : Colors.grey[200],
              )
          ],
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isActive ? Colors.black : Colors.grey)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
            const SizedBox(height: 20),
          ],
        )
      ],
    );
  }

  // --- COLUMNS ---

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(_booking!.paymentMode, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text("Amount : ₹${_booking!.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text("Payment Status : ", style: TextStyle(color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _booking!.paymentStatus.toLowerCase() == 'paid' ? Colors.green[50] : Colors.red[50], 
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(
                          _booking!.paymentStatus, 
                          style: TextStyle(
                            color: _booking!.paymentStatus.toLowerCase() == 'paid' ? Colors.green : Colors.red, 
                            fontSize: 12, fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // --- DYNAMIC BOOKING OTP ---
                  // Note: Ensure your BookingModel has this field parsed. If not, modify model first.
                  // Assuming 'bookingPin' is the integer field from JSON.
                  Row(
                    children: [
                      const Text("Booking OTP : ", style: TextStyle(color: Colors.grey)),
                      // We will need to update the BookingModel to parse 'bookingPin'
                      // For now, I'll access the map if available or show placeholder
                      Text(
                        "${_booking!.bookingPin}", // Updated: Display Dynamic Pin
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Text("Schedule : ${_formatDate(_booking!.bookingDate)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // --- SERVICES SUMMARY ---
        _buildCard(
          title: "Booking Summary",
          child: Column(
            children: [
              _buildSummaryHeader(),
              const Divider(),
              if (_booking!.services.isEmpty)
                 const Padding(padding: EdgeInsets.all(8.0), child: Text("No services listed")),
              
              ..._booking!.services.map((s) => _buildSummaryRow(
                s.serviceName, 
                "Standard Service", 
                "₹${s.price}", 
                "1", 
                "₹0", 
                "₹0", 
                "₹${s.price}"
              )),
              
              const Divider(),
              _buildTotalRow("Grand Total", "₹${_booking!.totalAmount}", isBold: true, color: const Color(0xFF2563EB)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    // Determine color based on payment status
    final isPaid = _booking!.paymentStatus.toLowerCase() == 'paid';
    final statusColor = isPaid ? Colors.green : Colors.red;
    final statusBgColor = isPaid ? Colors.green[50] : Colors.red[50];

    return Column(
      children: [
        _buildCard(
          title: "Booking Setup",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payment Status", style: TextStyle(fontWeight: FontWeight.w500)),
                  
                  // --- CHANGED: Dynamic Text Container instead of Switch ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _booking!.paymentStatus, // Dynamic Value: "Paid" or "Unpaid"
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // ---------------------------------------------------------
                ],
              ),
              const SizedBox(height: 15),
              
              // Status Dropdown (Read Only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                child: Text(_booking!.status, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              
              // Date Field
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: _formatDate(_booking!.bookingDate),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
              )
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Location Card (Same as before)
        _buildCard(
          title: "Service Location",
          titleIcon: Icons.map,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFEAD1), borderRadius: BorderRadius.circular(8)),
                child: const Text("Provider has to go to the Customer Location to provide the service", 
                  style: TextStyle(color: Color(0xFFD97706), fontSize: 13, height: 1.4)),
              ),
              const SizedBox(height: 15),
              const Text("Address:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                "${_booking!.address?.addressLine1 ?? ''}, ${_booking!.address?.city ?? ''}",
                style: const TextStyle(color: Colors.grey, height: 1.4)
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Provider Info (Same as before)
        _buildCard(
          title: "Provider Information",
          titleIcon: Icons.engineering,
          child: _booking!.provider == null 
            ? const Text("No Provider Assigned", style: TextStyle(color: Colors.red))
            : Row(
                children: [
                  CircleAvatar(
                    radius: 24, 
                    backgroundColor: Colors.orange[100], 
                    child: Text(_booking!.provider!.firstName.isNotEmpty ? _booking!.provider!.firstName[0] : "P"),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${_booking!.provider!.firstName} ${_booking!.provider!.lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB))),
                      const SizedBox(height: 4),
                      Text(_booking!.provider!.mobile, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
        ),
        
        const SizedBox(height: 24),
        
        // Customer Info (Same as before)
        _buildCard(
          title: "Customer Information",
          titleIcon: Icons.person,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24, 
                backgroundColor: Colors.blue[100], 
                child: Text(_booking!.customerName.isNotEmpty ? _booking!.customerName[0] : "C"),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_booking!.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB))),
                  const SizedBox(height: 4),
                  Text(_booking!.customerPhone, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCard({String? title, IconData? titleIcon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (titleIcon != null) ...[Icon(titleIcon, size: 18), const SizedBox(width: 8)],
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("SERVICE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("PRICE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 1, child: Text("QTY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String name, String sub, String price, String qty, String disc, String vat, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),
          Expanded(flex: 2, child: Text(price)),
          Expanded(flex: 1, child: Text(qty)),
          Expanded(flex: 2, child: Text(total, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 13)),
          const SizedBox(width: 40),
          SizedBox(
            width: 100,
            child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color, fontSize: isBold ? 16 : 13)),
          ),
        ],
      ),
    );
  }
}