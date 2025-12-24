import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_provider_controller.dart';

class AddProviderScreen extends StatelessWidget {
  final AddProviderController controller = Get.put(AddProviderController());

  // 1. Added parameters for Dashboard integration
  final dynamic data; 
  final VoidCallback? onBack;

  final Color primaryOrange = const Color(0xFFF97316);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color bgLight = const Color(0xFFF1F5F9);
  final Color borderGrey = const Color(0xFFE2E8F0);

  // 2. Updated Constructor
  AddProviderScreen({super.key, this.data, this.onBack}) {
    // Optional: Pre-fill logic if data is passed
    if (data != null) {
      // Example pre-fill
      controller.firstNameCtrl.text = data.name.split(" ")[0];
      controller.mobileCtrl.text = data.phone;
      controller.emailCtrl.text = data.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // 3. Show Back button if onBack is provided (Dashboard Mode)
        leading: onBack != null 
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textDark),
              onPressed: onBack,
            )
          : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add New Provider", style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Complete all steps to onboard a new service provider", style: TextStyle(color: textGrey, fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    side: BorderSide(color: borderGrey),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text("Save Draft"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text("Create Provider"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildCustomStepper(context), 
        ),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(8), 
            border: Border.all(color: borderGrey)
          ),
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            switch (controller.currentStep.value) {
              case 0: return _buildPersonalDetails();
              case 1: return _buildAddressLocation();
              case 2: return _buildProfessionalServices(context); 
              case 3: return _buildFinancials();
              case 4: return _buildDocuments();
              default: return _buildPersonalDetails();
            }
          }),
        ),
      ),
      
      // --- BOTTOM NAVIGATION ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: borderGrey))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Obx(() => controller.currentStep.value > 0 
               ? OutlinedButton(onPressed: controller.prevStep, child: const Text("Back"))
               : const SizedBox.shrink()),
             
             Obx(() => ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, foregroundColor: Colors.white),
               onPressed: controller.nextStep,
               child: Text(controller.currentStep.value == 4 ? "Finish" : "Next"),
             )),
          ],
        ),
      ),
    );
  }

  // --- STEPPER (FIXED CRASH HERE) ---
  Widget _buildCustomStepper(BuildContext context) {
    // Check width outside Obx to avoid null errors
    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryOrange, width: 2)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          _buildStepTab(0, "Personal Details", Icons.person_outline, isWideScreen),
          _buildStepTab(1, "Address", Icons.location_on_outlined, isWideScreen),
          _buildStepTab(2, "Services", Icons.work_outline, isWideScreen),
          _buildStepTab(3, "Financials", Icons.account_balance_wallet_outlined, isWideScreen),
          _buildStepTab(4, "Documents", Icons.description_outlined, isWideScreen),
        ],
      ),
    );
  }

  Widget _buildStepTab(int index, String label, IconData icon, bool isWideScreen) {
    return Expanded(
      child: Obx(() {
        bool isActive = controller.currentStep.value == index;
        return InkWell(
          onTap: () => controller.setStep(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: isActive 
                ? Border(bottom: BorderSide(color: primaryOrange, width: 3)) 
                : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: isActive ? primaryOrange : textGrey),
                const SizedBox(width: 8),
                // Only show text if active or screen is wide (Prevents overflow on small screens)
                if(isActive || isWideScreen) 
                Flexible(
                  child: Text(label, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? primaryOrange : textGrey,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13
                    )
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

// --- STEP 3: SERVICES (FINAL FIXED VERSION) ---
  Widget _buildProfessionalServices(BuildContext context) { 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Service Mapping"),
        const SizedBox(height: 16),
        
        // Use Obx to listen to changes
        Obx(() {
          // 1. Safety Check: Handle empty data
          if (controller.serviceCategories.isEmpty) {
             return Container(
               padding: const EdgeInsets.all(20),
               alignment: Alignment.center,
               child: const Text("No services available. Try restarting the app.", style: TextStyle(color: Colors.grey)),
             );
          }

          return Column(
            children: controller.serviceCategories.map((category) {
              // 2. Safe Data Extraction
              final String catName = category["category"]?.toString() ?? "Unknown";
              final List subCats = category["subCategories"] as List? ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: borderGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  // 3. FIX: Use 'context' passed from build, NOT Get.context!
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    iconColor: textGrey,
                    collapsedIconColor: textGrey,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    title: Text(
                      catName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 15),
                    ),
                    subtitle: Text("${subCats.length} Sub-categories", style: TextStyle(fontSize: 12, color: textGrey)),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: subCats.map((subCat) {
                            
                            // 4. FIX: Helper function to safely get RxBool (Defined below)
                            final RxBool isSubSelected = _getSafeRxBool(subCat["selected"]);
                            final List servicesList = subCat["services"] as List? ?? [];
                            final String subName = subCat["name"]?.toString() ?? "Unnamed";

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                const SizedBox(height: 8),
                                // --- Sub Category Checkbox ---
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24, width: 24,
                                      child: Obx(() => Checkbox(
                                        value: isSubSelected.value,
                                        activeColor: primaryOrange,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        onChanged: (val) {
                                           isSubSelected.value = val ?? false;
                                           // Auto-select children
                                           for (var s in servicesList) {
                                              _getSafeRxBool(s["selected"]).value = isSubSelected.value;
                                           }
                                        },
                                      )),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      subName,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // --- Services Wrap ---
                                Padding(
                                  padding: const EdgeInsets.only(left: 34.0),
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: servicesList.map((service) {
                                       
                                       final RxBool isSvcSelected = _getSafeRxBool(service["selected"]);
                                       final String svcName = service["name"]?.toString() ?? "Service";

                                       return Obx(() {
                                         bool isSelected = isSvcSelected.value;
                                         return InkWell(
                                           onTap: () {
                                             isSvcSelected.value = !isSelected;
                                             if (isSvcSelected.value) isSubSelected.value = true;
                                           },
                                           child: Container(
                                             width: 180,
                                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                             decoration: BoxDecoration(
                                               color: isSelected ? primaryOrange.withOpacity(0.04) : Colors.white,
                                               border: Border.all(
                                                 color: isSelected ? primaryOrange : borderGrey,
                                               ),
                                               borderRadius: BorderRadius.circular(6),
                                             ),
                                             child: Row(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 SizedBox(
                                                    height: 18, width: 18,
                                                    child: Checkbox(
                                                      value: isSelected,
                                                      activeColor: primaryOrange,
                                                      side: BorderSide(color: textGrey, width: 1.5),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                                      onChanged: (val) {
                                                         isSvcSelected.value = val ?? false;
                                                         if (val == true) isSubSelected.value = true;
                                                      },
                                                    ),
                                                 ),
                                                 const SizedBox(width: 10),
                                                 Flexible(
                                                   child: Text(
                                                     svcName,
                                                     overflow: TextOverflow.ellipsis,
                                                     style: TextStyle(
                                                       fontSize: 13,
                                                       color: isSelected ? textDark : textGrey,
                                                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
                                                     ),
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         );
                                       });
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // 5. HELPER: Prevents crashes if key is missing or not RxBool
  RxBool _getSafeRxBool(dynamic value) {
    if (value is RxBool) return value;
    return false.obs; // Return a dummy observable to prevent null crash
  }
  // --- (EXISTING HELPERS - NO CHANGES NEEDED BELOW THIS LINE, BUT INCLUDED FOR COMPLETENESS) ---
  Widget _buildPersonalDetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              DashedBorderContainer(
                color: borderGrey,
                child: Container(
                  height: 160, width: 160,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40, color: textGrey.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text("Upload Profile Image", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text("Allowed *.jpeg, *.jpg\nmax 3MB", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: textGrey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildTextField("First Name", controller.firstNameCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Middle Name", controller.middleNameCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Last Name", controller.lastNameCtrl)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField("Mobile Number", controller.mobileCtrl, prefix: "+91 ")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Email Address", controller.emailCtrl)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField("Date of Birth", controller.dobCtrl, icon: Icons.calendar_today)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdown("Gender", ["Male", "Female", "Other"], controller.selectedGender)),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAddressLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("PERMANENT ADDRESS"),
        const SizedBox(height: 16),
        _buildTextField("Care Of (C/O)", controller.careOfCtrl, hint: "Father/Husband Name"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField("Locality", controller.localityCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Landmark", controller.landmarkCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("City", controller.cityCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField("District", controller.districtCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("State", controller.stateCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Pincode", controller.pincodeCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: _buildTextField("Country", controller.countryCtrl, enabled: false)),
        const SizedBox(height: 32),
        _buildSectionHeader("SERVICEABLE LOCATIONS"),
        const SizedBox(height: 16),
        _buildDropdown("Select City", ["Lucknow", "Delhi", "Mumbai"], controller.selectedServiceCity),
      ],
    );
  }

  Widget _buildFinancials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("Banking Details"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
              child: const Text("SECURE", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown("Select Bank", ["HDFC Bank", "SBI", "ICICI Bank"], controller.selectedBank),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField("Account Holder Name", controller.accHolderCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Account Number", controller.accNumberCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField("IFSC Code", controller.ifscCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("UPI ID (Optional)", controller.upiCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel("Upload Passbook Image"),
        const SizedBox(height: 8),
        _buildFileUploadBox(),
        const SizedBox(height: 32),
        
        Obx(() => Row(
          children: [
            Checkbox(
              value: controller.isPanAvailable.value, 
              activeColor: primaryOrange,
              onChanged: (val) => controller.isPanAvailable.value = val!
            ),
            const Text("PAN Card Available", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField("PAN Number *", controller.panNumberCtrl)),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Upload PAN Image *"),
                const SizedBox(height: 6),
                _buildFileUploadBox(compact: true),
              ],
            )),
          ],
        )
      ],
    );
  }

  Widget _buildDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("EDUCATION DETAILS"),
             Row(
               children: [
                 Checkbox(value: true, onChanged: (v){}, activeColor: primaryOrange),
                 const Text("Education Details Required?", style: TextStyle(color: Colors.grey, fontSize: 13))
               ],
             )
          ],
        ),
        const SizedBox(height: 12),
        _buildDropdown("Highest Qualification *", ["High School", "Graduate", "Post Graduate"], controller.selectedQualification),
        const SizedBox(height: 16),
        _buildLabel("Upload Educational Documents *"),
        const SizedBox(height: 8),
        _buildFileUploadBox(),
        
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add New Document", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDropdown("Document Type", ["Aadhar Card", "Driving License", "Voter ID"], controller.selectedDocType),
                  const SizedBox(height: 12),
                  
                  DashedBorderContainer(
                    color: borderGrey,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      color: const Color(0xFFF8FAFC),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: textGrey, size: 30),
                          const SizedBox(height: 8),
                          Text("Click to upload", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark)),
                          Text("PDF, JPG, PNG (Max 5MB)", style: TextStyle(fontSize: 10, color: textGrey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Upload Document"),
                      onPressed: (){},
                      style: OutlinedButton.styleFrom(foregroundColor: textDark, side: BorderSide(color: borderGrey)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Uploaded Documents", style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade50),
                        child: const Text("0", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: bgLight, shape: BoxShape.circle),
                          child: Icon(Icons.description_outlined, color: textGrey.withOpacity(0.5), size: 30),
                        ),
                        const SizedBox(height: 12),
                        Text("No documents uploaded yet.", style: TextStyle(color: textGrey)),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 14, color: textDark),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark));
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {String? hint, IconData? icon, String? prefix, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            suffixIcon: icon != null ? Icon(icon, size: 18, color: textGrey) : null,
            filled: !enabled,
            fillColor: enabled ? Colors.white : bgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderGrey)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: primaryOrange)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, RxString selectedValue, {String hint = "Select..."}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: borderGrey),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hint, style: TextStyle(fontSize: 13, color: textGrey)),
              value: selectedValue.value.isEmpty ? null : selectedValue.value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => selectedValue.value = val!,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildFileUploadBox({bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFFF8FAFC),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text("Choose File", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text("No file chosen", style: TextStyle(color: textGrey, fontSize: 13))),
          if (!compact) Text("JPG, PNG, PDF (Max 5MB)", style: TextStyle(color: textGrey, fontSize: 11)),
        ],
      ),
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashRectPainter(color: color, strokeWidth: strokeWidth, gap: gap),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: child,
      ),
    );
  }
}

class _DashRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashRectPainter({required this.color, required this.strokeWidth, required this.gap});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    ));

    Path dashPath = Path();
    double dashWidth = 5.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}