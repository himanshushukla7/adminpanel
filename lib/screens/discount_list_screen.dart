import 'package:flutter/material.dart';

class DiscountListScreen extends StatefulWidget {
  const DiscountListScreen({super.key});

  @override
  State<DiscountListScreen> createState() => _DiscountListScreenState();
}

class _DiscountListScreenState extends State<DiscountListScreen> {
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
            // --- 1. Screen Title ---
            const Text(
              'Discounts',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
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
                  // --- Header: Tabs & Total Count ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tabs
                        Row(
                          children: [
                            _buildTab('All'),
                            const SizedBox(width: 24),
                            _buildTab('Service Wise'),
                            const SizedBox(width: 24),
                            _buildTab('Category Wise'),
                          ],
                        ),
                        // Count
                        Row(
                          children: const [
                            Text('Total Discount: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text('3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Matches height approx
                            elevation: 0,
                          ),
                          child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        
                        const Spacer(), // Pushes Download button to the right
                        
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
                        _buildHeaderCell('DISCOUNT TYPE', flex: 3),
                        _buildHeaderCell('STATUS', flex: 2),
                        _buildHeaderCell('ACTION', flex: 2, alignRight: true),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // --- Table Rows (Hardcoded Data from Image) ---
                  _buildRow(
                    sl: '1',
                    title: 'FLAT 10% OFF ON CAR SHIFTING',
                    type: 'Category',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _buildRow(
                    sl: '2',
                    title: '15% OFF ON HOUSE SHIFTING',
                    type: 'Service',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _buildRow(
                    sl: '3',
                    title: '10% OFF ON AC REPAIRING',
                    type: 'Mixed',
                    isActive: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // --- Pagination ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Showing 1 to 3 of 3 results', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        Row(
                          children: [
                            _buildPaginationBtn(Icons.chevron_left),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEB5725).withOpacity(0.1),
                                border: Border.all(color: const Color(0xFFEB5725)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('1', style: TextStyle(color: Color(0xFFEB5725), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            _buildPaginationBtn(Icons.chevron_right),
                          ],
                        ),
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
        padding: const EdgeInsets.only(bottom: 8),
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
  Widget _buildHeaderCell(String text, {int flex = 1, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 11,
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
    required String type,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(sl, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(flex: 4, child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87))),
          Expanded(flex: 3, child: Text(type, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.scale(
                scale: 0.7,
                alignment: Alignment.centerLeft,
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
                _buildActionIcon(Icons.delete_outline, const Color(0xFFEF4444)), // Red color for delete
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

  // --- Helper Widget: Pagination Button ---
  Widget _buildPaginationBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: Colors.grey),
    );
  }
}