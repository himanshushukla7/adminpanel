import 'dart:math';
import 'package:flutter/material.dart';

class TransactionReportScreen extends StatelessWidget {
  const TransactionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Main Background Color
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate-100
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER SECTION
            const _HeaderSection(),
            const SizedBox(height: 24),

            // 2. CHARTS SECTION
            const _ChartsSection(),
            const SizedBox(height: 24),

            // 3. FILTERS SECTION
            const _FiltersSection(),
            const SizedBox(height: 24),

            // 4. DATA TABLE SECTION
            const _DataTableSection(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. HEADER SECTION
// -----------------------------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Transaction List & Report',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage financial movements and view Lucknow region insights.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Orange-50
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Color(0xFFF97316)), // Orange-500
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TOTAL TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '352',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. CHARTS SECTION
// -----------------------------------------------------------------------------
class _ChartsSection extends StatelessWidget {
  const _ChartsSection();

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to stack vertically on small screens if needed
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(flex: isWide ? 4 : 0, child: const _BarChartCard()),
            SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 24),
            Expanded(flex: isWide ? 6 : 0, child: const _LineChartCard()),
          ],
        );
      },
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Transaction Types',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Distribution across Lucknow region',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 18, color: Color(0xFFF97316)),
              )
            ],
          ),
          const Expanded(child: _CustomBarChart()),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Volume Trends',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Last 7 Days (Lucknow HQ)',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.show_chart_rounded,
                    size: 18, color: Color(0xFFF97316)),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Expanded(child: _CustomSmoothLineChart()),
        ],
      ),
    );
  }
}

// --- Custom Bar Chart Painter ---
class _CustomBarChart extends StatelessWidget {
  const _CustomBarChart();

  @override
  Widget build(BuildContext context) {
    final data = [
      {'label': 'UPI', 'value': 0.7},
      {'label': 'Cash', 'value': 0.45},
      {'label': 'Card', 'value': 0.3},
      {'label': 'RTGS', 'value': 0.6},
      {'label': 'Chq', 'value': 0.2},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: item['value'] as double,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['label'] as String,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B)),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// --- Custom Smooth Line Chart Painter ---
class _CustomSmoothLineChart extends StatelessWidget {
  const _CustomSmoothLineChart();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _SmoothLinePainter(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _DateLabel('19 AUG'),
            _DateLabel('20 AUG'),
            _DateLabel('21 AUG'),
            _DateLabel('22 AUG'),
            _DateLabel('23 AUG'),
            _DateLabel('24 AUG'),
            _DateLabel('25 AUG'),
          ],
        )
      ],
    );
  }
}

class _DateLabel extends StatelessWidget {
  final String text;
  const _DateLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)));
  }
}

class _SmoothLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Hardcoded points to match the wave in the image
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.16, size.height * 0.75),
      Offset(size.width * 0.32, size.height * 0.5),
      Offset(size.width * 0.48, size.height * 0.7),
      Offset(size.width * 0.64, size.height * 0.2), // Peak
      Offset(size.width * 0.80, size.height * 0.5),
      Offset(size.width, size.height * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
          controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(path, paint);

    // Draw Circles at points
    final circlePaint = Paint()..color = Colors.white;
    final circleBorder = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var p in points) {
      canvas.drawCircle(p, 5, circlePaint);
      canvas.drawCircle(p, 5, circleBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// 3. FILTERS SECTION
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// 3. FILTERS SECTION (UPDATED)
// -----------------------------------------------------------------------------
class _FiltersSection extends StatelessWidget {
  const _FiltersSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.filter_alt_outlined,
                  size: 20, color: Color(0xFFF97316)),
              SizedBox(width: 8),
              Text('Transaction Report Filters',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid for inputs
              final width = constraints.maxWidth;
              final isSmall = width < 800;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end, // Helps alignment
                children: [
                  _FilterInput(
                      label: 'Start Date',
                      hint: 'mm/dd/yyyy',
                      width: isSmall ? width : 180,
                      icon: Icons.calendar_today_outlined),
                  _FilterInput(
                      label: 'End Date',
                      hint: 'mm/dd/yyyy',
                      width: isSmall ? width : 180,
                      icon: Icons.calendar_today_outlined),
                  _FilterInput(
                      label: 'Sort By',
                      hint: 'Newest First',
                      width: isSmall ? width : 200,
                      isDropdown: true),
                  _FilterInput(
                      label: 'Choose First',
                      hint: '10 Records',
                      width: isSmall ? width : 150,
                      isDropdown: true),
                  
                  // --- FIXED BUTTON SECTION ---
                  SizedBox(
                    width: isSmall ? width : 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Invisible Label to match the height of other labels
                        const Text(
                          '', 
                          style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        // 2. Exact same spacing as _FilterInput
                        const SizedBox(height: 6),
                        // 3. Button with exact same height as Input fields (46)
                        SizedBox(
                          width: double.infinity,
                          height: 46, 
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Apply Filter',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ----------------------------
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
class _FilterInput extends StatelessWidget {
  final String label;
  final String hint;
  final double width;
  final IconData? icon;
  final bool isDropdown;

  const _FilterInput({
    required this.label,
    required this.hint,
    required this.width,
    this.icon,
    this.isDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(hint,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                Icon(
                  isDropdown
                      ? Icons.keyboard_arrow_down_rounded
                      : (icon ?? Icons.calendar_month),
                  size: 18,
                  color: const Color(0xFF94A3B8),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. DATA TABLE SECTION
// -----------------------------------------------------------------------------
class _DataTableSection extends StatelessWidget {
  const _DataTableSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search,
                            size: 20, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Search by Trx ID, Name...',
                              style: TextStyle(color: Color(0xFF94A3B8))),
                        ),
                        Container(
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Search',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Download CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFFFF7ED),
            child: Row(
              children: const [
                SizedBox(width: 40, child: _Th('SL')),
                Expanded(flex: 2, child: _Th('TRANSACTION ID')),
                Expanded(flex: 2, child: _Th('TRANSACTION DATE')),
                Expanded(flex: 3, child: _Th('TRANSACTION FROM')),
                Expanded(flex: 3, child: _Th('TRANSACTION TO')),
                Expanded(flex: 2, child: _Th('TRANSACTION TYPE')),
                Expanded(flex: 2, child: _Th('PAYMENT AMOUNT', alignRight: true)),
                Expanded(flex: 2, child: _Th('BALANCE', alignRight: true)),
              ],
            ),
          ),

          // Table Rows
          const _Tr(
            sl: '01',
            id: '704d55ec-fcec',
            date: '25-08-2025',
            time: '11:30 AM',
            from: 'Ellison Trading',
            fromSub: 'Account payable',
            to: 'Ellison Cardenas',
            type: 'Extra Fee',
            typeColor: Color(0xFFDBEAFE),
            typeTextColor: Color(0xFF1E40AF),
            amount: '- ₹10.00',
            amountColor: Color(0xFFDC2626),
            balance: '₹17,909.89',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const _Tr(
            sl: '02',
            id: '703de3b3-9170',
            date: '25-08-2025',
            time: '11:30 AM',
            from: 'Ellison Cardenas',
            fromSub: 'Account receivable',
            to: 'John Roy',
            type: 'Received Fee',
            typeColor: Color(0xFFDCFCE7),
            typeTextColor: Color(0xFF166534),
            amount: '+ ₹10.00',
            amountColor: Color(0xFF16A34A),
            balance: '₹21,839.69',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const _Tr(
            sl: '03',
            id: '11dade7c-4100',
            date: '25-08-2025',
            time: '11:30 AM',
            from: 'John Roy',
            fromSub: 'Account receivable',
            to: 'Ellison Cardenas',
            type: 'Commission',
            typeColor: Color(0xFFF3E8FF),
            typeTextColor: Color(0xFF6B21A8),
            amount: '+ ₹792.00',
            amountColor: Color(0xFF16A34A),
            balance: '₹21,829.69',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const _Tr(
            sl: '04',
            id: '7fee601b-5b92',
            date: '24-08-2025',
            time: '09:15 AM',
            from: 'Ellison Cardenas',
            fromSub: '',
            to: 'Ellison Cardenas',
            type: 'Transfer',
            typeColor: Color(0xFFF1F5F9),
            typeTextColor: Color(0xFF475569),
            amount: '₹0.00',
            amountColor: Color(0xFF64748B),
            balance: '₹72,010.15',
          ),

          // Pagination
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    children: [
                      TextSpan(text: 'Showing '),
                      TextSpan(
                          text: '1 to 4',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      TextSpan(text: ' of '),
                      TextSpan(
                          text: '352',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      TextSpan(text: ' Entries'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Prev',
                          style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Next',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String text;
  final bool alignRight;
  const _Th(this.text, {this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF7C2D12), // Dark Brown/Orange
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Tr extends StatelessWidget {
  final String sl;
  final String id;
  final String date;
  final String time;
  final String from;
  final String fromSub;
  final String to;
  final String type;
  final Color typeColor;
  final Color typeTextColor;
  final String amount;
  final Color amountColor;
  final String balance;

  const _Tr({
    required this.sl,
    required this.id,
    required this.date,
    required this.time,
    required this.from,
    required this.fromSub,
    required this.to,
    required this.type,
    required this.typeColor,
    required this.typeTextColor,
    required this.amount,
    required this.amountColor,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
              width: 40,
              child: Text(sl,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(id,
                    style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569))),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(date,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500)),
                ]),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(time,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8))),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(from,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B))),
                if (fromSub.isNotEmpty)
                  Text(fromSub,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(to,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B))),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(type,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: typeTextColor)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(amount,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: amountColor)),
          ),
          Expanded(
            flex: 2,
            child: Text(balance,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }
}