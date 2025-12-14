import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Constants ---
const Color kPrimaryOrange = Color(0xFFFF6B00);
const Color kTextDark = Color(0xFF1E293B);
const Color kTextLight = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kBgColor = Color(0xFFF1F5F9);

class CustomerOverviewScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onEdit; // Triggers navigation to Update Screen

  const CustomerOverviewScreen({super.key, this.onBack, this.onEdit});

  @override
  State<CustomerOverviewScreen> createState() => _CustomerOverviewScreenState();
}

class _CustomerOverviewScreenState extends State<CustomerOverviewScreen> {
  int _currentTab = 0; // 0: Overview, 1: Bookings, 2: Reviews

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.onBack != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: kTextDark),
                              onPressed: widget.onBack,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        const Text('Customer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextDark)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Joined on 23-Jan-25 18:10PM', style: TextStyle(color: kTextLight)),
                  ],
                ),
                // Share Icon (from image)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kBorderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.share_outlined, color: kPrimaryOrange, size: 20),
                )
              ],
            ),
            const SizedBox(height: 24),

            // --- Custom Tabs ---
            Row(
              children: [
                _buildTabItem(0, "Overview"),
                const SizedBox(width: 12),
                _buildTabItem(1, "Bookings"),
                const SizedBox(width: 12),
                _buildTabItem(2, "Reviews"),
              ],
            ),
            const SizedBox(height: 24),

            // --- Tab Content ---
            IndexedStack(
              index: _currentTab,
              children: [
                _OverviewTab(onEdit: widget.onEdit), // Pass the edit callback
                const _BookingsTab(),
                const _ReviewsTab(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final bool isActive = _currentTab == index;
    return InkWell(
      onTap: () => setState(() => _currentTab = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : kTextLight,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TAB 1: OVERVIEW (Matches image_bd1998.jpg)
// =============================================================================
class _OverviewTab extends StatelessWidget {
  final VoidCallback? onEdit;
  const _OverviewTab({this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Stats Cards & Chart ---
        // Using LayoutBuilder to handle responsiveness if needed, but assuming row for dashboard
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Total Booking Placed
            Expanded(
              child: _buildStatCard(
                value: "12",
                label: "Total Booking Placed",
                valueColor: kPrimaryOrange,
                bgColor: const Color(0xFFFFF7ED), // Light Orange
              ),
            ),
            const SizedBox(width: 20),
            // Card 2: Total Booking Amount
            Expanded(
              child: _buildStatCard(
                value: "\u20B924,500",
                label: "Total Booking Amount",
                valueColor: const Color(0xFF10B981), // Green
                bgColor: const Color(0xFFECFDF5), // Light Green
              ),
            ),
            const SizedBox(width: 20),
            // Card 3: Booking Overview Chart
            Expanded(
              flex: 1, // Give chart slightly more width if needed, or equal
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderColor),
                ),
                child: Row(
                  children: [
                    // Donut Chart
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 35,
                              sections: [
                                PieChartSectionData(color: kPrimaryOrange, value: 30, title: '', radius: 12),
                                PieChartSectionData(color: const Color(0xFF10B981), value: 70, title: '', radius: 12),
                              ],
                            ),
                          ),
                          const Center(
                            child: Text(
                              "12\nBookings",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.2),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Booking Overview", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextLight)),
                          SizedBox(height: 8),
                          _ChartLegend(color: kPrimaryOrange, label: "Pending"),
                          SizedBox(height: 4),
                          _ChartLegend(color: Color(0xFF10B981), label: "Accepted"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // --- Personal Details ---
        const Text("Personal Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFFFE4B5),
                child: Icon(Icons.person, size: 40, color: Color(0xFFE65100)),
              ),
              const SizedBox(width: 24),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Rajesh Kumar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone_android, "+91 98765 43210"),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.email_outlined, "rajesh.kumar@example.com"),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.location_on_outlined, "Lucknow, UP"),
                  ],
                ),
              ),
              // Edit Button
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                label: const Text("Edit", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryOrange,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String value, required String label, required Color valueColor, required Color bgColor}) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: kTextLight)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kTextLight),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: kTextDark, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: kTextDark)),
      ],
    );
  }
}

// =============================================================================
// TAB 2: BOOKINGS (Matches image_bd1995.png)
// =============================================================================
class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search & Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Booking ID or Service...',
                    prefixIcon: const Icon(Icons.search, color: kTextLight),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorderColor)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Search", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18, color: kTextDark),
                label: const Text("Filter", style: TextStyle(color: kTextDark)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  side: const BorderSide(color: kBorderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // Table Header
          const _BookingTableHeader(),
          const Divider(height: 1, color: kBorderColor),
          
          // Table Rows (Mock Data)
          _buildRow("#BK-9021", "AC Repair & Service", "25 Jan, 2025", "Rajesh Kumar", "\u20B9499.00", "Completed", Colors.green, Icons.ac_unit, const Color(0xFFFFF3E0)),
          const Divider(height: 1, color: kBorderColor),
          _buildRow("#BK-9020", "Bathroom Cleaning", "22 Jan, 2025", "Suresh Verma", "\u20B9899.00", "Pending", const Color(0xFFEAB308), Icons.cleaning_services, const Color(0xFFE0F2FE)),
          const Divider(height: 1, color: kBorderColor),
          _buildRow("#BK-9018", "Fan Installation", "18 Jan, 2025", "Amit Singh", "\u20B9250.00", "Cancelled", Colors.red, Icons.wind_power, const Color(0xFFF3E8FF)),
          const Divider(height: 1, color: kBorderColor),
          _buildRow("#BK-8945", "Pest Control", "10 Jan, 2025", "Vikram Malhotra", "\u20B91,200.00", "Completed", Colors.green, Icons.bug_report, const Color(0xFFDCFCE7)),
          
          const SizedBox(height: 20),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Showing 1 to 4 of 12 entries", style: TextStyle(color: kTextLight, fontSize: 13)),
              Row(
                children: [
                  _PaginationBtn("<"),
                  const SizedBox(width: 8),
                  _PaginationBtn("1", active: true),
                  const SizedBox(width: 8),
                  _PaginationBtn("2"),
                  const SizedBox(width: 8),
                  _PaginationBtn("3"),
                  const SizedBox(width: 8),
                  _PaginationBtn(">"),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRow(String id, String service, String date, String provider, String amount, String status, Color statusColor, IconData icon, Color iconBg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle), child: Icon(icon, size: 14, color: kTextDark)),
              const SizedBox(width: 8),
              Text(service, style: const TextStyle(fontSize: 13)),
            ],
          )),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(provider, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 1, child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          )),
          const Expanded(flex: 1, child: Icon(Icons.remove_red_eye_outlined, size: 18, color: kTextLight)),
        ],
      ),
    );
  }
}

class _BookingTableHeader extends StatelessWidget {
  const _BookingTableHeader();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: const [
          Expanded(flex: 1, child: Text("BOOKING ID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
          Expanded(flex: 2, child: Text("SERVICE NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
          Expanded(flex: 2, child: Text("BOOKING DATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
          Expanded(flex: 2, child: Text("PROVIDER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
          Expanded(flex: 1, child: Text("AMOUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
          Expanded(flex: 1, child: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
          Expanded(flex: 1, child: Text("ACTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 3: REVIEWS (Matches image_bd197d.png)
// =============================================================================
class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search here',
                    prefixIcon: const Icon(Icons.search, color: kTextLight),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorderColor)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Search", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Header
           Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text("BOOKING ID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
                Expanded(flex: 2, child: Text("BOOKING DATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
                Expanded(flex: 2, child: Text("RATINGS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
                Expanded(flex: 4, child: Text("REVIEWS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextLight))),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorderColor),

          // Rows
          _buildReviewRow("#LKO-2401-892", "22 Jan, 2025", 4.0, "Excellent service by the team. The cleaning was thorough and timely. Highly recommended for Lucknow residents!"),
          const Divider(height: 1, color: kBorderColor),
          _buildReviewRow("#LKO-2312-455", "15 Dec, 2024", 5.0, "Very professional staff. Arrived exactly on time in Gomti Nagar. Will book again."),
          const Divider(height: 1, color: kBorderColor),
          _buildReviewRow("#LKO-2311-102", "02 Nov, 2024", 3.0, "Service was okay, but they forgot some cleaning supplies. Good behavior though."),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String id, String date, double rating, String review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Row(
            children: [
              ...List.generate(5, (index) => Icon(
                Icons.star, 
                size: 14, 
                color: index < rating ? Colors.amber : Colors.grey.shade300
              )),
              const SizedBox(width: 8),
              Text("$rating", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
            ],
          )),
          Expanded(flex: 4, child: Text(review, style: const TextStyle(fontSize: 13, color: kTextLight, height: 1.4))),
        ],
      ),
    );
  }
}

class _PaginationBtn extends StatelessWidget {
  final String label;
  final bool active;
  const _PaginationBtn(this.label, {this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? kPrimaryOrange : Colors.white,
        border: Border.all(color: active ? kPrimaryOrange : kBorderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : kTextLight, fontSize: 12)),
    );
  }
}