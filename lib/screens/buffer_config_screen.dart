import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import '../repositories/buffer_repository.dart';

class BufferConfigScreen extends StatefulWidget {
  const BufferConfigScreen({super.key});

  @override
  State<BufferConfigScreen> createState() => _BufferConfigScreenState();
}

class _BufferConfigScreenState extends State<BufferConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final BufferRepository _bufferRepo = BufferRepository();
  
  // Controllers
  final TextEditingController _distFromController = TextEditingController();
  final TextEditingController _distToController = TextEditingController();
  final TextEditingController _bufferBeforeController = TextEditingController();
  final TextEditingController _bufferAfterController = TextEditingController();

  bool _isLoading = false;

  // --- API LOGIC ---
  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Safely parse inputs to integers
    final dFrom = int.tryParse(_distFromController.text) ?? 0;
    final dTo = int.tryParse(_distToController.text) ?? 0;
    final bBefore = int.tryParse(_bufferBeforeController.text) ?? 0;
    final bAfter = int.tryParse(_bufferAfterController.text) ?? 0;

    // Call Repository
    final success = await _bufferRepo.saveBufferSettings(
      distanceFrom: dFrom,
      distanceTo: dTo,
      bufferBefore: bBefore,
      bufferAfter: bAfter,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("Buffer time added successfully!", const Color(0xFF22C55E));
      // Optional: Clear fields or navigate back
      // Navigator.pop(context); 
      _clearFields();
    } else {
      _showSnackBar("Failed to add buffer time. Please try again.", const Color(0xFFEF4444));
    }
  }

  void _clearFields() {
    _distFromController.clear();
    _distToController.clear();
    _bufferBeforeController.clear();
    _bufferAfterController.clear();
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w500)), 
        backgroundColor: color, 
        behavior: SnackBarBehavior.floating
      ),
    );
  }

  @override
  void dispose() {
    _distFromController.dispose();
    _distToController.dispose();
    _bufferBeforeController.dispose();
    _bufferAfterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light Grey Bg
      appBar: AppBar(
        title: Text("Add Buffer Time", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Distance Configuration", Icons.map),
              const SizedBox(height: 12),
              
              // --- CARD 1: DISTANCE ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _distFromController,
                      label: "Distance From (km)",
                      hint: "e.g. 0",
                      icon: Icons.near_me_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _distToController,
                      label: "Distance To (km)",
                      hint: "e.g. 50",
                      icon: Icons.place_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader("Time Buffers", Icons.timer_outlined),
              const SizedBox(height: 12),

              // --- CARD 2: TIME ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _bufferBeforeController,
                      label: "Buffer Before (mins)",
                      hint: "e.g. 15",
                      icon: Icons.history,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _bufferAfterController,
                      label: "Buffer After (mins)",
                      hint: "e.g. 30",
                      icon: Icons.update,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveConfiguration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Save Settings", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF334155))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (int.tryParse(value) == null) return 'Must be a number';
            return null;
          },
        ),
      ],
    );
  }
}