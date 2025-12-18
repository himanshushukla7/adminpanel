import 'dart:io'; // For File (mobile/desktop)
import 'dart:ui' as ui; // For PathMetric (Dashed Border)

import 'package:file_picker/file_picker.dart'; // Add this package
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';

class PromotionalBannersScreen extends StatelessWidget {
  const PromotionalBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Light grey background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Screen Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Promotional Banners',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.settings, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 1. Top Section: Setup Form ---
            const BannerSetupCard(),

            const SizedBox(height: 24),

            // --- 2. Bottom Section: List Table ---
            const BannerListCard(),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGET 1: BANNER SETUP CARD
// =============================================================================

class BannerSetupCard extends StatefulWidget {
  const BannerSetupCard({super.key});

  @override
  State<BannerSetupCard> createState() => _BannerSetupCardState();
}

class _BannerSetupCardState extends State<BannerSetupCard> {
  // File Picker State
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  void _clearFile() {
    setState(() {
      _pickedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promotional Banner Setup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 24),
          
          // Responsive Layout: Stacks on mobile, Row on Desktop
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 800;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLeftForm()),
                        const SizedBox(width: 40),
                        Expanded(child: _buildRightUpload()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildLeftForm(),
                        const SizedBox(height: 30),
                        _buildRightUpload(),
                      ],
                    );
            },
          ),
          
          const SizedBox(height: 30),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _clearFile, // Connected to clear logic
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Reset', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Submit Logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB5725), // Orange color
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeftForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Input
        _buildLabel('Title', isRequired: true),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter banner title',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.title, size: 20, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        const SizedBox(height: 20),

        // Select Category
        _buildLabel('Select Category', isRequired: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Category', style: TextStyle(fontSize: 14, color: Colors.grey)),
              items: const [
                 DropdownMenuItem(value: 'cat1', child: Text('Cleaning')),
                 DropdownMenuItem(value: 'cat2', child: Text('Repair')),
              ],
              onChanged: (val) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightUpload() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text('Upload cover image', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        ),
        const SizedBox(height: 12),
        
        // CLICKABLE UPLOAD ZONE
        GestureDetector(
          onTap: _pickFile,
          child: CustomPaint(
            painter: DashedRectPainter(color: Colors.grey.shade400, strokeWidth: 1.5, gap: 5.0),
            child: Container(
              height: 180,
              width: double.infinity,
              alignment: Alignment.center,
              child: _pickedFile != null
                ? Stack(
                    children: [
                      // Display Image
                      SizedBox.expand(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _getImageWidget(),
                        ),
                      ),
                      // Remove Button
                      Positioned(
                        top: 8, 
                        right: 8,
                        child: InkWell(
                          onTap: _clearFile,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.delete, color: Colors.red, size: 20),
                          ),
                        ),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Upload File', style: TextStyle(color: Color(0xFFEB5725), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Image format - png, jpg, jpeg, gif', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      Text('Image Size - Maximum size 2MB', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      Text('Image Ratio - 2:1', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getImageWidget() {
    if (kIsWeb) {
      // On Web, we must use bytes because path is fake/hidden
      if (_pickedFile!.bytes != null) {
        return Image.memory(_pickedFile!.bytes!, fit: BoxFit.cover);
      }
      return const Center(child: Text("Error loading web image"));
    } else {
      // On Mobile/Desktop, use file path
      if (_pickedFile!.path != null) {
        return Image.file(File(_pickedFile!.path!), fit: BoxFit.cover);
      }
      return const Center(child: Text("Error loading image path"));
    }
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        children: [
          if (isRequired)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGET 2: BANNER LIST CARD
// =============================================================================

class BannerListCard extends StatelessWidget {
  const BannerListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Simplified Header: Title + Count (Tabs Removed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text(
                   'Banner List', 
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))
                 ),
                 Row(
                   children: const [
                      Text('Total Banners: ', style: TextStyle(color: Colors.grey)),
                      Text('2', style: TextStyle(fontWeight: FontWeight.bold)),
                   ],
                 )
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          
          // Search & Action Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
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
                            ),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEB5725),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Search', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18, color: Colors.black87),
                  label: const Text('Download', style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                )
              ],
            ),
          ),

          // Table
          _buildTable(),

          // Pagination
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Showing 1 to 2 of 2 entries', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Previous', style: TextStyle(color: Colors.black54)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEB5725),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('1', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Next', style: TextStyle(color: Colors.black54)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              children: [
                _buildHeaderCell('SL', flex: 1),
                _buildHeaderCell('TITLE', flex: 4),
                _buildHeaderCell('TYPE', flex: 2),
                _buildHeaderCell('STATUS', flex: 2),
                _buildHeaderCell('ACTION', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Rows
          _buildRow('1', 'Laptop Repair service', 'category'),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildRow('2', 'House cleaning service', 'category'),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.bold, 
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRow(String sl, String title, String type) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(sl, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 4, child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Expanded(
            flex: 2, 
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.scale(
                scale: 0.7,
                alignment: Alignment.centerLeft,
                child: Switch(
                  value: true, 
                  activeColor: const Color(0xFFEB5725),
                  onChanged: (v) {},
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildActionIcon(Icons.edit, const Color(0xFFEB5725)),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.delete_outline, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

// =============================================================================
// HELPER: DASHED BORDER PAINTER
// =============================================================================

class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  DashedRectPainter({this.strokeWidth = 1.0, this.color = Colors.grey, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = 0;
    double y = 0;
    double w = size.width;
    double h = size.height;

    Path path = Path();
    path.moveTo(x + 10, y); // Top line start
    path.lineTo(w - 10, y);
    path.quadraticBezierTo(w, y, w, y + 10); // Top Right corner
    path.lineTo(w, h - 10);
    path.quadraticBezierTo(w, h, w - 10, h); // Bottom Right corner
    path.lineTo(x + 10, h);
    path.quadraticBezierTo(x, h, x, h - 10); // Bottom Left corner
    path.lineTo(x, y + 10);
    path.quadraticBezierTo(x, y, x + 10, y); // Top Left corner

    // Logic to draw dashes
    Path dashPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += (gap * 2); 
      }
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}