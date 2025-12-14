import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'employee_role_setup_screen.dart';
import 'employee_role_list_screen.dart';
import 'add_employee_screen.dart';
// --- WIDGET IMPORTS ---
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_topbar.dart';
import 'keyword_analytics_screen.dart';
// --- SCREEN IMPORTS ---
import 'ongoing_booking_screen.dart';
import 'CategoryScreen.dart';
import 'ServiceCategoryScreen.dart';
import 'ServiceScreen.dart'; 
import 'login_screen.dart';
import 'canceled_booking_screen.dart';
import 'completed_booking_screen.dart';
import 'offline_payment_screen.dart';
import 'customized_booking_screen.dart';
import 'add_service_screen.dart';
import 'booking_details_screen.dart'; 
import 'customer_list.dart';
import 'customer_update_screen.dart';
import 'customer_overview_screen.dart';
import 'transaction_report_screen.dart';
import 'booking_report_screen.dart';
import 'provider_report_screen.dart';
import 'employee_list_screen.dart';
import 'role_update_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _collapsed = false;
  String _currentRoute = 'dashboard';
  
  Map<String, String>? _selectedBooking; 

  void _viewBookingDetails(String id, String status) {
    setState(() {
      _selectedBooking = {'id': id, 'status': status};
    });
  }

  void _closeBookingDetails() {
    setState(() {
      _selectedBooking = null;
    });
  }

  Widget _getBody() {
    if (_selectedBooking != null) {
      return BookingDetailsScreen(
        bookingId: _selectedBooking!['id']!,
        bookingStatus: _selectedBooking!['status']!,
        onBack: _closeBookingDetails,
      );
    }

    switch (_currentRoute) {
      case 'dashboard':
        return const DashboardHome();
      
      case 'booking/ongoing':
        return OngoingBookingScreen(
          onViewDetails: (id) => _viewBookingDetails(id, 'Accepted'),
        );

      case 'booking/canceled':
        return CanceledBookingScreen(
          onViewDetails: (id) => _viewBookingDetails(id, 'Canceled'),
        );  

      case 'booking/completed':
        return CompletedBookingScreen(
          onViewDetails: (id) => _viewBookingDetails(id, 'Completed'),
        );

      case 'booking/offline':
        return OfflinePaymentScreen(
          onViewDetails: (id, status) => _viewBookingDetails(id, 'Completed'),
        );
        
      case 'booking/customized':
        return const CustomizedBookingScreen();
        
      case 'service/categories':
        return const CategoryScreen();
        
      case 'service/subcategories':
        return const ServiceCategoryScreen();
        
      case 'service/list':
        return ServiceScreen(
          onAddService: () {
            setState(() {
              _currentRoute = 'service/add';
            });
          },
        );
        
      case 'service/add':     
        return AddServiceScreen(
          onCancel: () {
            setState(() {
              _currentRoute = 'service/list';
            });
          },
          onSave: (success) {
            if (success) {
              setState(() {
                _currentRoute = 'service/list';
              });
            }
          },
        );
      // --- UPDATED CUSTOMER SECTION ---
      case 'customer/list':
        return CustomerListScreen(
         onEditCustomer: () => setState(() => _currentRoute = 'customer/update'),
         onViewCustomer: () => setState(() => _currentRoute = 'customer/overview'), // Connect this!
            );

      case 'customer/overview':
         return CustomerOverviewScreen(
        onBack: () => setState(() => _currentRoute = 'customer/list'),
        onEdit: () => setState(() => _currentRoute = 'customer/update'),
         );

      case 'customer/update':
        return CustomerUpdateScreen(
          onBack: () {
            // Switch back to list
            setState(() {
              _currentRoute = 'customer/list';
            });
          },
        );
      case 'report/transaction':
        return TransactionReportScreen();
      case 'report/booking':
        return BookingReportScreen();
      case 'report/provider':
        return ProviderReportScreen();
      case 'analytics/keyword':
         return const KeywordAnalyticsScreen();   
      case 'employee/role-setup': 
        return EmployeeRoleListScreen(
          // Switch to Add Screen
          onAddRole: () => setState(() => _currentRoute = 'employee/role-add'),
          // Switch to Update Screen (NEW)
          onEditRole: () => setState(() => _currentRoute = 'employee/role-update'),
        );
      
      case 'employee/role-add':
        return EmployeeRoleSetupScreen(
           onBack: () => setState(() => _currentRoute = 'employee/role-setup'),
        );

      // NEW CASE FOR UPDATE SCREEN
      case 'employee/role-update':
        return const RoleUpdateScreen(); // Ensure you import RoleUpdateScreen
       case 'employee/list':
        return EmployeeListScreen(
          // 4. Pass the function to switch the route
          onAddEmployee: () {
            setState(() {
              _currentRoute = 'employee/add';
            });
          },
        );

      case 'employee/add':  
        return const AddEmployeeScreen();
      default:
        return const DashboardHome();
    }
  }

  void _handleNavigation(String route) {
    if (route == 'auth/login') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _currentRoute = route;
        _selectedBooking = null; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Row(
        children: [
          DashboardSidebar(
            collapsed: _collapsed,
            currentRoute: _currentRoute, 
            onNav: _handleNavigation,
          ),
          Expanded(
            child: Column(
              children: [
                DashboardTopBar(
                  onMenuTap: () => setState(() => _collapsed = !_collapsed),
                  onLogout: () => _handleNavigation('auth/login'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(0), 
                    child: _getBody(),
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

// -----------------------------------------------------------------------------
// DASHBOARD HOME CONTENT (UPDATED FOR INDIA/LUCKNOW)
// -----------------------------------------------------------------------------
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // KPI Band
          LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
            double width = (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;
            
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: width,
                  child: const PanelCard.gradient(
                    title: 'Total Revenue', 
                    // Updated to INR
                    value: '\u20B924,50,000',
                    gradient: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                    icon: Icons.currency_rupee, // Changed Icon
                  ),
                ),
                SizedBox(
                  width: width,
                  child: const PanelCard.gradient(
                    title: 'Total Bookings', 
                    value: '1,245',
                    gradient: [Color(0xFF10B981), Color(0xFF059669)],
                    icon: Icons.calendar_today,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: const PanelCard.gradient(
                    title: 'Active Services', 
                    value: '85',
                    gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    icon: Icons.cleaning_services,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: const PanelCard.solid(
                    title: 'Customers (Lko)', 
                    value: '3,402',
                    color: Color(0xFF1E3A8A),
                    icon: Icons.people,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // Earning Chart & Recent List
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 1000) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(flex: 2, child: EarningChart()),
                  SizedBox(width: 24),
                  // Updated Title
                  Expanded(child: RecentList(title: "Top Providers (Lucknow)")),
                ],
              );
            } else {
              return Column(
                children: const [
                  EarningChart(),
                  SizedBox(height: 24),
                  RecentList(title: "Top Providers (Lucknow)"),
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class PanelCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color>? gradient;
  final Color? color;

  const PanelCard.gradient({
    super.key, required this.title, required this.value, required this.icon, required this.gradient,
  }) : color = null;

  const PanelCard.solid({
    super.key, required this.title, required this.value, required this.icon, required this.color,
  }) : gradient = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: gradient != null ? LinearGradient(colors: gradient!) : null,
        color: color,
        boxShadow: [
          BoxShadow(color: (gradient?.first ?? color!).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              Icon(icon, color: Colors.white38, size: 24),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class EarningChart extends StatelessWidget {
  const EarningChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Revenue Trends (in Lakhs)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 1.2), FlSpot(1, 2.5), FlSpot(2, 2.0), FlSpot(3, 4.8), FlSpot(4, 3.5), FlSpot(5, 5.2)],
                    isCurved: true,
                    color: const Color(0xFF2563EB),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF2563EB).withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RECENT LIST (DATA CUSTOMIZED FOR LUCKNOW)
// -----------------------------------------------------------------------------
class RecentList extends StatelessWidget {
  final String title;
  const RecentList({super.key, required this.title});

  // Mock Data for Lucknow Providers
  static const List<Map<String, dynamic>> _providers = [
    {
      "name": "Amit Kumar",
      "specialty": "AC Repair (Gomti Nagar)",
      "rating": "4.9",
      "earnings": "24,000"
    },
    {
      "name": "Sneha Gupta",
      "specialty": "Bridal Makeup (Hazratganj)",
      "rating": "4.8",
      "earnings": "18,500"
    },
    {
      "name": "Ravi Verma",
      "specialty": "Electrician (Indira Nagar)",
      "rating": "4.7",
      "earnings": "15,200"
    },
    {
      "name": "Mohd. Ariz",
      "specialty": "Plumber (Aliganj)",
      "rating": "4.6",
      "earnings": "12,800"
    },
    {
      "name": "Priya Singh",
      "specialty": "Home Cleaning (Mahanagar)",
      "rating": "4.9",
      "earnings": "21,000"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _providers.length,
              separatorBuilder: (c, i) => const Divider(height: 24),
              itemBuilder: (c, i) {
                final provider = _providers[i];
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE0E7FF),
                      child: Text(
                        provider['name'][0], 
                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          "${provider['specialty']} • ${provider['rating']} ★", 
                          style: const TextStyle(fontSize: 12, color: Colors.grey)
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      "\u20B9${provider['earnings']}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}