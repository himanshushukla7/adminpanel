import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import '../repositories/provider_repository.dart';

class ProviderController extends GetxController {
  final ProviderRepository _repo = ProviderRepository();

  // State
  var isLoading = true.obs;
  var allProviders = <ProviderModel>[].obs; // Original Data
  var providerList = <ProviderModel>[].obs; // Displayed Data (Filtered)
  
  // Filters
  var searchText = ''.obs;
  var selectedTab = 'All'.obs; // "All", "Active", "Inactive"

  @override
  void onInit() {
    super.onInit();
    fetchProviders();

    // Listen to changes to re-filter automatically
    debounce(searchText, (_) => _applyFilters(), time: const Duration(milliseconds: 500));
    ever(selectedTab, (_) => _applyFilters());
  }

  void fetchProviders() async {
    isLoading.value = true;
    var fetched = await _repo.getAllProviders();
    allProviders.assignAll(fetched);
    _applyFilters(); // Initial filter apply
    isLoading.value = false;
  }

  void _applyFilters() {
    List<ProviderModel> temp = List.from(allProviders);

    // 1. Filter by Tab (Active/Inactive based on Aadhar Verification for now)
    if (selectedTab.value == 'Active') {
      temp = temp.where((p) => p.isAadharVerified).toList();
    } else if (selectedTab.value == 'Inactive') {
      temp = temp.where((p) => !p.isAadharVerified).toList();
    }

    // 2. Filter by Search Text
    if (searchText.value.isNotEmpty) {
      String query = searchText.value.toLowerCase();
      temp = temp.where((p) {
        return p.fullName.toLowerCase().contains(query) ||
               p.mobileNo.contains(query) ||
               (p.emailId ?? '').toLowerCase().contains(query);
      }).toList();
    }

    providerList.assignAll(temp);
  }

  // Placeholder for toggling status (API integration needed here usually)
  void toggleStatus(int index, bool val) {
    // In real app, call API to update status, then refresh
    // For now, we assume visual toggle isn't persistent without API
    print("Toggle status for ${providerList[index].fullName} to $val");
  }
}