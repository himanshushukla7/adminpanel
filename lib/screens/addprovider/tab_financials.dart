import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_provider_controller.dart';
import 'common_widgets.dart'; 

class TabFinancials extends GetView<AddProviderController> {
  const TabFinancials({super.key});

  @override
  Widget build(BuildContext context) {
    final bankingCtrl = controller.bankingController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("Banking Details"),
        const SizedBox(height: 16),
        
        // Bank Dropdown
        Obx(() {
          if (bankingCtrl.isLoading.value) {
            return const Center(child: LinearProgressIndicator());
          }
          return DropdownButtonFormField<String>(
            value: controller.selectedBankId.value,
            decoration: InputDecoration(
              labelText: "Select Bank",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: bankingCtrl.bankList.map((bank) {
              return DropdownMenuItem<String>(
                value: bank.id,
                child: Text(bank.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) => controller.selectedBankId.value = val,
            hint: const Text("Choose a bank"),
          );
        }),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextField(label: "Account Holder Name", controller: controller.accHolderCtrl)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: "Account Number", controller: controller.accNumberCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextField(label: "IFSC Code", controller: controller.ifscCtrl)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: "UPI ID", controller: controller.upiCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        
        const CustomLabel("Upload Passbook Image *"),
        const SizedBox(height: 8),

        // ✅ CLEANER: No Obx needed here because FileUploadBox handles it internally now
        FileUploadBox(
          file: controller.passbookFile, 
          type: 'passbook', 
          onPick: controller.pickFile
        ),
        
        const SizedBox(height: 32),
        Obx(() => CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("PAN Card Available", style: TextStyle(fontWeight: FontWeight.bold)),
          value: controller.isPanAvailable.value, 
          activeColor: Colors.orange, 
          onChanged: (val) => controller.isPanAvailable.value = val!
        )),
        
        Obx(() => controller.isPanAvailable.value ? Row(
          children: [
            Expanded(child: CustomTextField(label: "PAN Number", controller: controller.panNumberCtrl)),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomLabel("Upload PAN Image"),
                const SizedBox(height: 6),
                
                // ✅ CLEANER: No Obx needed here
                FileUploadBox(
                  compact: true, 
                  file: controller.panCardFile, 
                  type: 'pan', 
                  onPick: controller.pickFile
                ),
              ],
            )),
          ],
        ) : const SizedBox()),
      ],
    );
  }
}