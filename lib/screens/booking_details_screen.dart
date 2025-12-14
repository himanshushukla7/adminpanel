import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String bookingStatus; // "Canceled", "Completed", "Accepted", "Ongoing"
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
  // State for Tab Switching
  String _currentTab = "Details"; 

  // Helper to get color based on status
  Color _getStatusColor() {
    switch (widget.bookingStatus.toLowerCase()) {
      case 'canceled': return const Color(0xFFEF4444); // Red
      case 'completed': return const Color(0xFF10B981); // Green
      case 'ongoing': return const Color(0xFFEF7822); // Orange
      case 'accepted': return const Color(0xFF2563EB); // Blue
      default: return const Color(0xFFEF7822);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        // 1. ADDED PADDING FROM ALL SIDES
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
                        Text("Booking # ${widget.bookingId}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEF7822))),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(widget.bookingStatus, style: TextStyle(color: _getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text("Booking Placed : 23-Jan-2025 02:32am", style: TextStyle(color: Colors.grey, fontSize: 12)),
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

            // --- 2. DYNAMIC TABS ---
            Row(
              children: [
                _buildTabButton("Details"),
                const SizedBox(width: 20),
                _buildTabButton("Status"),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 24),

            // --- 3. DYNAMIC CONTENT BODY ---
            // If "Details" -> Show Grid/Details
            // If "Status" -> Show Timeline
            _currentTab == "Details" 
              ? _buildDetailsView()
              : _buildStatusView(), // This is the new timeline view from image 546e92.png

            // Back Button at bottom
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

  // --- TAB BUTTON HELPER ---
  Widget _buildTabButton(String text) {
    bool isActive = _currentTab == text;
    return InkWell(
      onTap: () {
        setState(() => _currentTab = text);
      },
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

  // --- VIEW 1: DETAILS (Existing Layout) ---
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

  // --- VIEW 2: STATUS TIMELINE (New from Image) ---
  Widget _buildStatusView() {
    // Determine active steps based on bookingStatus
    int currentStep = 1; 
    if (widget.bookingStatus == 'Accepted') currentStep = 2;
    if (widget.bookingStatus == 'Ongoing') currentStep = 2;
    if (widget.bookingStatus == 'Completed') currentStep = 3;
    if (widget.bookingStatus == 'Canceled') currentStep = 1; // Or handle as special case

    return _buildCard(
      title: "Booking Status",
      child: Column(
        children: [
          _buildTimelineItem(
            title: "Booking Placed",
            subtitle: "By Customer\n23-Jan-2025 02:32am",
            isActive: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Accepted",
            subtitle: "By Provider\n23-Jan-2025 09:15am",
            isActive: currentStep >= 2,
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Completed",
            subtitle: widget.bookingStatus == 'Completed' ? "Service Done" : "Pending",
            isActive: currentStep >= 3,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // --- TIMELINE ITEM HELPER ---
  Widget _buildTimelineItem({required String title, required String subtitle, required bool isActive, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEF7822) : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: isActive ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isActive ? const Color(0xFFEF7822).withOpacity(0.5) : Colors.grey[200],
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

  // --- EXISTING DETAIL WIDGETS ---

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text("Cash After Service", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text("Amount : ₹26,520.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
                        child: const Text("Unpaid", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Booking Otp :", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text("Schedule Date : 22-Jan-2025 10:32pm", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: "Booking Summary",
          child: Column(
            children: [
              _buildSummaryHeader(),
              const Divider(),
              _buildSummaryRow("Sofa Cleaning", "7-Seat-Sofa-Cleaning", "₹1,800.00", "2", "₹100.00", "₹340.00", "₹3,840.00"),
              _buildSummaryRow("Deep Cleaning", "5-Seat-Sofa-Cleaning", "₹1,400.00", "5", "₹100.00", "₹650.00", "₹7,550.00"),
              const Divider(),
              _buildTotalRow("Grand Total", "₹26,520.00", isBold: true, color: const Color(0xFF2563EB)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
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
                  Switch(value: false, onChanged: (v){}), 
                ],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: widget.bookingStatus, 
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                items: [widget.bookingStatus].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: null, 
              ),
              const SizedBox(height: 15),
              TextField(
                enabled: false,
                decoration: const InputDecoration(
                  hintText: "22-01-2025 22:32",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
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
              const Text("Service Location:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Sector 18, Indira Nagar,\nLucknow, Uttar Pradesh 226016", style: TextStyle(color: Colors.grey, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // --- PROVIDER INFORMATION CARD ---
        _buildCard(
          title: "Provider Information",
          titleIcon: Icons.engineering, // Contextually relevant icon
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=60")), // Using placeholder image
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Amit Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB))),
                  SizedBox(height: 4),
                  Text("+91 91234 56789", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("Gomti Nagar, Lucknow", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: "Customer Information",
          titleIcon: Icons.person,
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11")),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Rohan Sharma", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB))),
                  SizedBox(height: 4),
                  Text("+91 98765 43210", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("Lucknow, UP, India", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // --- BASIC CARD HELPER ---
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

  // --- SUMMARY ROW HELPERS ---
  Widget _buildSummaryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("SERVICE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("PRICE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 1, child: Text("QTY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("DISCOUNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text("VAT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
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
          Expanded(flex: 2, child: Text(disc)),
          Expanded(flex: 2, child: Text(vat)),
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