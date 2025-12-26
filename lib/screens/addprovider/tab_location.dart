import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_provider_controller.dart';
import '../../models/location_model.dart';
import 'common_widgets.dart'; // Assuming you have your styles here

class TabLocationMap extends GetView<AddProviderController> {
  const TabLocationMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("MAP PROVIDER LOCATION"),
        const SizedBox(height: 8),
        const Text(
          "Select the operating area for this provider.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // --- Location Dropdown ---
        Obx(() {
          // Accessing the injected LocationController inside AddProviderController
          if (controller.locationController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return DropdownButtonFormField<LocationModel>(
            decoration: const InputDecoration(
              labelText: "Select Area",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map_outlined),
            ),
            value: controller.selectedLocation.value,
            hint: const Text("Choose an Area"),
            isExpanded: true,
            items: controller.locationController.locationList.map((loc) {
              return DropdownMenuItem<LocationModel>(
                value: loc,
                child: Text(
                  "${loc.areaName} ${loc.city != null ? '(${loc.city})' : ''}",
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (LocationModel? val) {
              controller.selectedLocation.value = val;
            },
          );
        }),
        const SizedBox(height: 10),
        
        // Optional: Show details of selected area
        Obx(() {
          if (controller.selectedLocation.value == null) return const SizedBox();
          final loc = controller.selectedLocation.value!;
          return Card(
            elevation: 0,
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Area ID: ${loc.areaId ?? 'N/A'}"),
                  Text("City: ${loc.city ?? 'N/A'}"),
                  Text("State: ${loc.state ?? 'N/A'}"),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}