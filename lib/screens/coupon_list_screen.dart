import 'package:flutter/material.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  // State for the active tab
  String _selectedTab = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Light grey background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Screen Title & Total Count ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Coupons',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Row(
                  children: const [
                    Text('Total Coupons: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text('5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEB5725))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 2. Main List Card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // --- Header: Tabs ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    child: Row(
                      children: [
                        _buildTab('All'),
                        const SizedBox(width: 30),
                        _buildTab('Service Wise'),
                        const SizedBox(width: 30),
                        _buildTab('Category Wise'),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),

                  // --- Search & Action Bar ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(Icons.search, color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search here',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Search Button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEB5725),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            elevation: 0,
                          ),
                          child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        
                        const Spacer(),
                        
                        // Download Dropdown Button
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 16, color: Colors.black87),
                          label: const Row(
                            children: [
                              Text('Download', style: TextStyle(color: Colors.black87, fontSize: 13)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, size: 16, color: Colors.black87)
                            ],
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        )
                      ],
                    ),
                  ),

                  // --- Table Header ---
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    child: Row(
                      children: [
                        _buildHeaderCell('SL', flex: 1),
                        _buildHeaderCell('TITLE', flex: 4),
                        _buildHeaderCell('COUPON TYPE', flex: 3),
                        _buildHeaderCell('COUPON CODE', flex: 3),
                        _buildHeaderCell('DISCOUNT TYPE', flex: 3),
                        _buildHeaderCell('LIMIT PER USER', flex: 3, alignCenter: true),
                        _buildHeaderCell('STATUS', flex: 2, alignCenter: true),
                        _buildHeaderCell('ACTION', flex: 2, alignRight: true),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // --- Table Rows (Hardcoded Data from Image) ---
                  _buildRow(
                    sl: '1',
                    title: 'Discount for premium customers',
                    couponType: 'Customer Wise',
                    code: 'ptest@2op622',
                    discountType: 'Service',
                    limit: '15',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  
                  _buildRow(
                    sl: '2',
                    title: 'Surprise discount for new user',
                    couponType: 'First Booking',
                    code: 'F334#C\$0@',
                    discountType: 'Category',
                    limit: '1',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  _buildRow(
                    sl: '3',
                    title: 'Happy service',
                    couponType: 'Default',
                    code: 'Hs64',
                    discountType: 'Mixed',
                    limit: '0',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  _buildRow(
                    sl: '4',
                    title: 'Repair55',
                    couponType: 'Default',
                    code: 'Repair55',
                    discountType: 'Service',
                    limit: '0',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  _buildRow(
                    sl: '5',
                    title: '20% Off',
                    couponType: 'Default',
                    code: 'c123',
                    discountType: 'Category',
                    limit: '0',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // --- Pagination ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Showing 1 to 5 of 5 results', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        // This exact styling from image has no page numbers visible, just prev/next? 
                        // Actually I can't see the bottom clearly but standard logic applies.
                        // I will keep standard logic.
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Tab ---
  Widget _buildTab(String title) {
    bool isActive = _selectedTab == title;
    return InkWell(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(bottom: BorderSide(color: Color(0xFFEB5725), width: 2))
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFFEB5725) : const Color(0xFF64748B),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Table Header Cell ---
  Widget _buildHeaderCell(String text, {int flex = 1, bool alignRight = false, bool alignCenter = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : (alignCenter ? TextAlign.center : TextAlign.left),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // --- Helper Widget: Table Row ---
  Widget _buildRow({
    required String sl,
    required String title,
    required String couponType,
    required String code,
    required String discountType,
    required String limit,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(sl, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(flex: 4, child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))),
          Expanded(flex: 3, child: Text(couponType, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
          Expanded(flex: 3, child: Text(code, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
          Expanded(flex: 3, child: Text(discountType, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
          Expanded(
            flex: 3, 
            child: Text(
              limit, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black87)
            )
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isActive,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFFEB5725),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  onChanged: (v) {},
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionIcon(Icons.edit_outlined, const Color(0xFFEB5725)),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.delete_outline, const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Action Icons ---
  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}