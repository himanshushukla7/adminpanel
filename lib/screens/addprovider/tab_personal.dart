import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_provider_controller.dart';
import 'common_widgets.dart';

class TabPersonalDetails extends GetView<AddProviderController> {
  const TabPersonalDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. SELECTION CARD ---
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Start Application", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ElevatedButton.icon(
                    onPressed: () => _showOnboardDialog(context),
                    icon: const Icon(Icons.add_call, size: 18),
                    label: const Text("Start New Application"),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, foregroundColor: Colors.white, elevation: 0),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("OR Resume Existing Application:", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              Obx(() {
                 if (controller.providerListController.isLoading.value) return const LinearProgressIndicator();
                 return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderGrey)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderGrey)),
                  ),
                  hint: const Text("Select provider from list..."),
                  value: controller.selectedProviderId.value,
                  isExpanded: true,
                  items: controller.providerListController.allProviders.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.id,
                      child: Text("${p.firstName ?? 'No Name'} (${p.mobileNo})", overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => controller.onSelectExistingProvider(val),
                );
              }),
            ],
          ),
        ),

        // --- 2. FORM FIELDS ---
        Obx(() => controller.selectedProviderId.value == null 
          ? Container(
              height: 200, 
              alignment: Alignment.center, 
              child: const Text("Please select a provider above or start a new application.", style: TextStyle(color: textGrey))
            )
          : Column(
            children: [
               Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 140, 
                      decoration: BoxDecoration(
                        border: Border.all(color: borderGrey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 40, color: textGrey.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          const Text("Profile", style: TextStyle(color: textGrey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: CustomTextField(label: "First Name *", controller: controller.firstNameCtrl)),
                            const SizedBox(width: 16),
                            Expanded(child: CustomTextField(label: "Last Name *", controller: controller.lastNameCtrl)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(label: "Middle Name", controller: controller.middleNameCtrl),
                        const SizedBox(height: 16),
                        CustomTextField(label: "Mobile Number", controller: controller.mobileCtrl, prefix: "+91 ", enabled: false),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: "Email Address", controller: controller.emailCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(label: "Aadhar Number *", controller: controller.aadharCtrl)),
                ],
              ),
              const SizedBox(height: 16),
              CustomDropdown(label: "Gender *", items: const ["Male", "Female", "Other"], selectedValue: controller.selectedGender),
            ],
          )
        ),
      ],
    );
  }

  void _showOnboardDialog(BuildContext context) {
    final TextEditingController mobileInput = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          title: const Text("Onboard New Provider"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the mobile number to register immediately."),
              const SizedBox(height: 16),
              TextField(
                controller: mobileInput,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(labelText: "Mobile Number", prefixText: "+91 ", border: OutlineInputBorder(), counterText: ""),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                controller.quickOnboardProvider(mobileInput.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, foregroundColor: Colors.white),
              child: const Text("Onboard Now"),
            )
          ],
        );
      }
    );
  }
}