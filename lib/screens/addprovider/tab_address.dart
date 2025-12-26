import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_provider_controller.dart';
import 'common_widgets.dart';

class TabAddress extends GetView<AddProviderController> {
  const TabAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("PERMANENT ADDRESS"),
        const SizedBox(height: 16),
        
        // --- CRITICAL FIX ---
        // API requires 'addressLine1'. Previously labeled 'Care Of', confusing users.
        // Renamed to 'House No / Building' so users don't leave it blank.
        CustomTextField(
          label: "House No / Building / Flat No *", 
          controller: controller.careOfCtrl, // This controller maps to addressLine1
          hint: "e.g. Flat 101, Galaxy Apartments"
        ),
        
        const SizedBox(height: 16),
        Row(
          children: [
            // Locality
            Expanded(
              child: CustomTextField(
                label: "Locality", 
                controller: controller.localityCtrl
              )
            ),
            const SizedBox(width: 16),
            // Landmark (addressLine2)
            Expanded(
              child: CustomTextField(
                label: "Landmark", 
                controller: controller.landmarkCtrl
              )
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        Row(
          children: [
            // City (Required)
            Expanded(
              child: CustomTextField(
                label: "City *", 
                controller: controller.cityCtrl
              )
            ),
            const SizedBox(width: 16),
            // District
            Expanded(
              child: CustomTextField(
                label: "District", 
                controller: controller.districtCtrl
              )
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        Row(
          children: [
            // State (Required)
            Expanded(
              child: CustomTextField(
                label: "State *", 
                controller: controller.stateCtrl
              )
            ),
            const SizedBox(width: 16),
            // Pincode (Required)
            Expanded(
              child: CustomTextField(
                label: "Pincode *", 
                controller: controller.pincodeCtrl,
                // Optional: Force number keyboard for pincode
                // keyboardType: TextInputType.number, 
              )
            ),
          ],
        ),
      ],
    );
  }
}