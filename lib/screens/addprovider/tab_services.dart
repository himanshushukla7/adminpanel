import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_provider_controller.dart';
import 'common_widgets.dart';

class TabServices extends GetView<AddProviderController> {
  const TabServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("Service Mapping"),
        const SizedBox(height: 16),
        
        Obx(() {
          if (controller.categories.isEmpty) {
            return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Loading services...")));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.categories.length,
            itemBuilder: (ctx, i) {
              final cat = controller.categories[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ExpansionTile(
                  shape: const Border(),
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                  children: [
                    Obx(() {
                      final services = controller.serviceMap[cat.id] ?? [];
                      if (services.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text("No services"));
                      
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 10, runSpacing: 10,
                          children: services.map((srv) {
                            final isSelected = controller.isServiceSelected(cat.id, srv.id);
                            return FilterChip(
                              label: Text(srv.name),
                              selected: isSelected,
                              onSelected: (val) => controller.toggleService(cat.id, srv.id),
                              selectedColor: primaryOrange.withOpacity(0.2),
                              checkmarkColor: primaryOrange,
                            );
                          }).toList(),
                        ),
                      );
                    })
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}