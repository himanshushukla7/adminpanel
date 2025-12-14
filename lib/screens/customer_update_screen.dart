import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// If you have a separate models file, keep this import.
// import '../models/customer_models.dart';

class CustomerUpdateScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CustomerUpdateScreen({super.key, this.onBack});

  @override
  State<CustomerUpdateScreen> createState() => _CustomerUpdateScreenState();
}

class _CustomerUpdateScreenState extends State<CustomerUpdateScreen> {
  // --- State Variables ---
  bool _isUploading = false;
  String? _pickedFileName;
  bool _isSubmitting = false;
  int _selectedAddressIndex = 0; // 0 for Home, 1 for Office

  // --- Actions ---
  
  // Simulating an Image Pick
  void _pickImage() async {
    if (_pickedFileName != null) return; // Already picked

    setState(() => _isUploading = true);
    
    // Simulate network/file delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isUploading = false;
        _pickedFileName = "new_profile_photo.jpg"; // Mock file name
      });
    }
  }

  void _removeImage() {
    setState(() {
      _pickedFileName = null;
    });
  }

  void _submitForm() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    if (mounted) {
      setState(() => _isSubmitting = false);
      // Show success or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
      );
      if (widget.onBack != null) widget.onBack!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header (Settings Icon Removed) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Customer Update', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextDark)),
                    SizedBox(height: 6),
                    Text('Update customer details and manage addresses', style: TextStyle(color: kTextLight, fontSize: 14)),
                  ],
                ),
                // Settings Icon removed as requested
              ],
            ),
            const SizedBox(height: 24),

            // --- Main Card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // Rounded corners
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT SIDE: FORM
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
                              const SizedBox(height: 24),
                              
                              _buildLabel('First Name *'),
                              _buildTextField('Anika', icon: Icons.person_outline),
                              const SizedBox(height: 20),
                              
                              _buildLabel('Last Name *'),
                              _buildTextField('Enter last name', icon: Icons.person_outline),
                              const SizedBox(height: 20),

                              _buildLabel('Email *'),
                              _buildTextField('Enter email address', icon: Icons.email_outlined),
                              const SizedBox(height: 20),

                              _buildLabel('Phone *'),
                              _buildPhoneField('1788223323'), // Flag removed inside this widget
                              const SizedBox(height: 32),

                              // Saved Addresses
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Saved Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
                                  TextButton.icon(
                                    onPressed: (){}, 
                                    icon: const Icon(Icons.add, size: 16, color: kPrimaryOrange),
                                    label: const Text('Add New', style: TextStyle(color: kPrimaryOrange, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildAddressCard(0, Icons.home, 'HOME', 'Flat 402, Lotus Apartments, MG Road,\nBangalore, Karnataka - 560001'),
                              const SizedBox(height: 12),
                              _buildAddressCard(1, Icons.work, 'OFFICE', 'Tech Park, Building 3, Sector 5,\nGurugram, Haryana - 122002'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 40),
                        // Vertical Divider
                        Container(width: 1, height: 600, color: const Color(0xFFF1F5F9)), 
                        const SizedBox(width: 40),

                        // RIGHT SIDE: PROFILE IMAGE
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              const Text('Profile Image', style: TextStyle(color: kTextLight, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 24),
                              
                              // Profile Avatar
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 65,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    backgroundImage: _pickedFileName != null 
                                      ? const NetworkImage('https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg') // Simulating new image
                                      : const NetworkImage('https://img.freepik.com/free-vector/mysterious-mafia-man-smoking-cigarette_52683-34828.jpg'), 
                                  ),
                                  Positioned(
                                    bottom: 0, right: 0,
                                    child: InkWell(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: kPrimaryOrange, 
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [BoxShadow(color: kPrimaryOrange.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text('Allowed format: png, jpg, jpeg', style: TextStyle(fontSize: 12, color: kTextLight)),
                              const Text('Max size: 2MB', style: TextStyle(fontSize: 12, color: kTextLight)),
                              
                              const SizedBox(height: 32),
                              
                              // Interactive File Upload Box
                              GestureDetector(
                                onTap: _isUploading ? null : _pickImage,
                                child: CustomPaint(
                                  painter: _DashedBorderPainter(color: _pickedFileName != null ? Colors.green : kPrimaryOrange),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                                    color: _pickedFileName != null ? Colors.green.withOpacity(0.05) : kPrimaryOrange.withOpacity(0.02),
                                    child: _isUploading 
                                      ? Column(
                                          children: const [
                                            SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryOrange)),
                                            SizedBox(height: 12),
                                            Text('Uploading...', style: TextStyle(color: kTextLight, fontSize: 12))
                                          ],
                                        )
                                      : _pickedFileName != null 
                                        ? Column(
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.green, size: 32),
                                              const SizedBox(height: 8),
                                              Text(_pickedFileName!, style: const TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: _removeImage,
                                                child: const Text('Remove', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
                                              )
                                            ],
                                          )
                                        : Column(
                                            children: const [
                                              Icon(Icons.cloud_upload_outlined, color: kPrimaryOrange, size: 32),
                                              SizedBox(height: 12),
                                              Text('Click to upload', style: TextStyle(color: kPrimaryOrange, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1, color: kBorderColor),
                  
                  // Footer Actions
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                         ElevatedButton(
                          onPressed: () {
                             // Reset Logic
                             setState(() {
                               _pickedFileName = null;
                             });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9), 
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Reset', style: TextStyle(color: kTextDark)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryOrange, 
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                            shadowColor: kPrimaryOrange.withOpacity(0.4),
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2),
      child: RichText(
        text: TextSpan(
          text: text.replaceAll('*', ''),
          style: const TextStyle(fontSize: 13, color: kTextLight, fontWeight: FontWeight.w600),
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: Colors.red))
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String initialValue, {IconData? icon}) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: kTextLight, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimaryOrange, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildPhoneField(String number) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorderColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                 // Flag Removed Here
                 Text('+91', style: TextStyle(fontWeight: FontWeight.bold, color: kTextDark, fontSize: 15)),
                 SizedBox(width: 4),
                 Icon(Icons.keyboard_arrow_down_rounded, color: kTextLight, size: 18)
              ],
            ),
          ),
          Container(width: 1, height: 24, color: kBorderColor), // Shorter divider
          Expanded(
            child: TextFormField(
              initialValue: number,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: "Phone Number"
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddressCard(int index, IconData icon, String title, String address) {
    final isSelected = _selectedAddressIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedAddressIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryOrange.withOpacity(0.04) : Colors.white,
          border: Border.all(color: isSelected ? kPrimaryOrange : kBorderColor, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? kPrimaryOrange : kTextLight, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? kPrimaryOrange : kTextLight)),
                  const SizedBox(height: 6),
                  Text(address, style: const TextStyle(fontSize: 13, color: kTextDark, height: 1.5)),
                ],
              ),
            ),
            if (isSelected) 
              const Icon(Icons.check_circle, color: kPrimaryOrange, size: 18)
          ],
        ),
      ),
    );
  }
}

// --- Custom Painter for Dotted Border ---
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    
    // Top
    double startX = 0;
    while (startX < size.width) {
      path.moveTo(startX, 0);
      path.lineTo(startX + dashWidth, 0);
      startX += dashWidth + dashSpace;
    }
    // Bottom
    startX = 0;
    while (startX < size.width) {
      path.moveTo(startX, size.height);
      path.lineTo(startX + dashWidth, size.height);
      startX += dashWidth + dashSpace;
    }
    // Left
    double startY = 0;
    while (startY < size.height) {
      path.moveTo(0, startY);
      path.lineTo(0, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }
    // Right
    startY = 0;
    while (startY < size.height) {
      path.moveTo(size.width, startY);
      path.lineTo(size.width, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }

    // Add rounded corners visually by clipping (simplified for this specific rect shape)
    // For perfect rounded dotted borders, path metrics are usually needed, but this suffices for the box look.
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// =============================================================================
// CONSTANTS
// =============================================================================
const Color kPrimaryOrange = Color(0xFFFF6B00); 
const Color kTextDark = Color(0xFF1E293B);
const Color kTextLight = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kBgColor = Color(0xFFF1F5F9);