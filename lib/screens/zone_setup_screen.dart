import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/location_controller.dart';

class LocationManagementScreen extends StatelessWidget {
  // Use Get.find if you initialized it in bindings, or Get.put to inject it here
  final LocationController controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    // Basic colors extracted from the image
    const Color primaryOrange = Color(0xFFF97316); 
    const Color bgGrey = Color(0xFFF3F4F6);
    const Color textGrey = Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: Colors.white, 
      // We assume the Dashboard sidebar is handled by a parent widget
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Location Management",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Manage service areas, geofences, and delivery zones.",
                      style: TextStyle(color: textGrey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () { /* Export logic */ },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text("Export Data"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    foregroundColor: primaryOrange,
                    elevation: 0,
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // --- 2. EDITOR SECTION (Map + Form) ---
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              height: 550, // Fixed height for the editor area
              child: Row(
                children: [
                  // LEFT: MAP (65% width)
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        Obx(() {
                          Set<Polygon> polygons = {};
                          if (controller.polygonPoints.isNotEmpty) {
                            polygons.add(Polygon(
                              polygonId: const PolygonId("new_zone"),
                              points: controller.polygonPoints,
                              fillColor: primaryOrange.withOpacity(0.3),
                              strokeColor: primaryOrange,
                              strokeWidth: 2,
                            ));
                          }
                          return GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(26.8467, 80.9462), // Lucknow
                              zoom: 13,
                            ),
                            mapType: MapType.normal,
                            polygons: polygons,
                            markers: controller.mapMarkers.toSet(),
                            onTap: controller.addPolygonPoint,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false, // Custom button looks better
                          );
                        }),
                        
                        // Floating Search Bar
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 80, // Leave space for map tools
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 10)
                              ],
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Search Area by Name (e.g. Gomti Nagar)",
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (val) { /* Implement Search Camera Move */ },
                            ),
                          ),
                        ),

                        // "Mode: Drawing" Badge
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: const Text(
                              "Mode: Drawing Polygon",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RIGHT: FORM (35% width)
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      color: Colors.white,
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Define New Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text(
                              "Use the map tools to draw a service area, then fill in the details below.",
                              style: TextStyle(color: textGrey, fontSize: 13),
                            ),
                            const SizedBox(height: 24),

                            _buildLabel("AREA NAME"),
                            _buildStyledField(controller.areaNameCtrl, "e.g. Gomti Nagar Ext."),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("CITY"),
                                      _buildStyledField(controller.cityCtrl, "Lucknow"),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("STATE"),
                                      _buildStyledField(controller.stateCtrl, "Uttar Pradesh"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildLabel("POST CODE"),
                            _buildStyledField(controller.pinCodeCtrl, "226010"),
                            const SizedBox(height: 16),

                            // Info Box
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Ensure the polygon aligns with actual delivery capabilities.",
                                      style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Actions
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text("Save Location"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: controller.submitLocation,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: OutlinedButton(
                                onPressed: controller.clearPolygon,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("Clear Map", style: TextStyle(color: Colors.black87)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 3. LIST SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Existing Locations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                
                // Search & Filter
                Row(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search locations...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: (){}, 
                      icon: const Icon(Icons.filter_list, size: 18), 
                      label: const Text("Filter"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DATA TABLE
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() {
                 if (controller.isLoading.value) {
                   return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
                 }
                 return DataTable(
                  headingRowColor: MaterialStateProperty.all(bgGrey),
                  columns: const [
                    DataColumn(label: Text("SL", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("AREA NAME", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("POST CODE", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("CITY", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("STATE", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(controller.locationList.length, (index) {
                    final loc = controller.locationList[index];
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}".padLeft(2, '0'))),
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(loc.areaName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Text("Geofence: Polygon", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      )),
                      DataCell(Text(loc.postCode ?? '-')),
                      DataCell(Text(loc.city ?? 'Lucknow')),
                      DataCell(Text(loc.state ?? 'Uttar Pradesh')),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.orange), onPressed: (){}),
                          IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent), onPressed: (){}),
                        ],
                      )),
                    ]);
                  }),
                );
              }),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Helper for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
      ),
    );
  }

  // Helper for Input Fields (Grey Background style)
  Widget _buildStyledField(TextEditingController ctrl, String hint) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB), // Very light grey
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }
}