import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for web check
import 'package:dio/dio.dart' as dio; 
import '../services/api_service.dart';
import '../models/data_models.dart';
import '../models/location_model.dart'; 
import '../controllers/provider_controller.dart'; 
import '../controllers/location_controller.dart'; // Import LocationController
import 'document_controller.dart';
import 'banking_controller.dart'; // Import the new controller
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // To lookup mime type


class AddProviderController extends GetxController {
  final ApiService _apiService = ApiService();
  
  // Dependency Injection
  late final ProviderController providerListController;
  late final LocationController locationController; // NEW: Injected
  late final DocumentController documentController; // NEW
  late final BankingController bankingController; // NEW

  // --- CALLBACKS ---
  Function? onProviderAdded; 

  // --- STATE ---
  var currentStep = 0.obs;
  var isLoading = false.obs;
  String? currentSpId;

  var isPersonalDetailsCompleted = false.obs; 
  var selectedProviderId = RxnString(); 

  // --- STEP 0: PERSONAL ---
  final firstNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController(); 
  final aadharCtrl = TextEditingController();
  var selectedGender = "".obs;

  // --- STEP 1: ADDRESS (Manual) ---
  final careOfCtrl = TextEditingController();
  final localityCtrl = TextEditingController();
  final landmarkCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  // --- STEP 2: LOCATION MAP (New Separate Step) ---
  var selectedLocation = Rxn<LocationModel>(); 
  
  // --- STEP 3: SERVICES ---
  var categories = <CategoryModel>[].obs;
  var serviceMap = <String, List<ServiceModel>>{}.obs; 
  var selectedServicesMap = <String, Set<String>>{}.obs;

  // --- STEP 4: FINANCIALS ---
  var selectedBankId = RxnString(); 
  final accHolderCtrl = TextEditingController();
  final accNumberCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final upiCtrl = TextEditingController();
  final panNumberCtrl = TextEditingController();
  var isPanAvailable = true.obs;
  Rx<PlatformFile?> passbookFile = Rx<PlatformFile?>(null);
  Rx<PlatformFile?> panCardFile = Rx<PlatformFile?>(null);

  // --- STEP 5: DOCUMENTS ---
  var selectedDocType = "".obs; 
  Rx<PlatformFile?> idProofFile = Rx<PlatformFile?>(null);

  @override
  void onInit() {
    super.onInit();
    // 1. Initialize Provider Controller
    if (Get.isRegistered<ProviderController>()) {
      providerListController = Get.find<ProviderController>();
    } else {
      providerListController = Get.put(ProviderController());
    }

    // 2. Initialize Location Controller
    if (Get.isRegistered<LocationController>()) {
      locationController = Get.find<LocationController>();
    } else {
      locationController = Get.put(LocationController());
    }
if (Get.isRegistered<DocumentController>()) {
      documentController = Get.find<DocumentController>();
    } else {
      documentController = Get.put(DocumentController());
    }

    if (Get.isRegistered<BankingController>()) {
      bankingController = Get.find<BankingController>();
    } else {
      bankingController = Get.put(BankingController());
    }
    loadInitialData();
  }

  void loadInitialData() async {
    isLoading.value = true;
    try {
      // Fetch locations so dropdown is populated
      locationController.fetchLocations();
      // Ensure banks are loaded
      if (bankingController.bankList.isEmpty) {
        bankingController.fetchBanks();
      }

      if (providerListController.allProviders.isEmpty) {
        providerListController.fetchProviders();
      }

      final cats = await _apiService.getCategories();
      categories.value = cats;

      List<Future<List<ServiceModel>>> futures = [];
      for (var cat in cats) {
        futures.add(_apiService.getServices(categoryId: cat.id));
      }
      final results = await Future.wait(futures);

      Map<String, List<ServiceModel>> tempMap = {};
      for (int i = 0; i < cats.length; i++) {
        tempMap[cats[i].id] = results[i];
      }
      serviceMap.value = tempMap;

    } catch (e) {
      print("Error loading initial data: $e");
    } finally {
      isLoading.value = false;
    }
  }
  // --- LOGIC: HANDLE LOCATION SELECTION ---
  void onLocationSelected(LocationModel? loc) {
    selectedLocation.value = loc;
    if (loc != null) {
      // Auto-fill address fields based on selected location
      cityCtrl.text = loc.city ?? "";
      stateCtrl.text = loc.state ?? "";
      pincodeCtrl.text = loc.postCode ?? "";
      // Optional: fill locality if areaName is treated as locality
      localityCtrl.text = loc.areaName ?? ""; 
    }
  }

  void safeSnackbar(String title, String message, {bool isError = false}) {
  if (Get.context == null) {
    debugPrint("⚠️ Snackbar skipped (no context): $title - $message");
    return;
  }

  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? Colors.red : Colors.green,
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 3),
  );
}


  // --- IMMEDIATE ONBOARDING LOGIC ---
  Future<void> quickOnboardProvider(String mobileNumber) async {
    if (mobileNumber.length != 10) {
      Get.snackbar("Error", "Please enter a valid 10-digit mobile number");
      return;
    }

    try {
      isLoading.value = true;
      String? newId = await _apiService.onboardServiceProvider(mobileNumber);
      
      if (newId != null) {
        print("API Success: New Provider ID: $newId");
        await providerListController.fetchProviders();
        
        var provider = providerListController.allProviders.firstWhereOrNull((p) => p.id == newId);
        
        if (provider == null) {
          await Future.delayed(const Duration(milliseconds: 1500));
          await providerListController.fetchProviders(); 
          provider = providerListController.allProviders.firstWhereOrNull((p) => p.id == newId);
        }

        if (provider == null) {
          throw Exception("New provider ID returned by API, but not found in the list. Please try again.");
        }

        onSelectExistingProvider(newId);

        if (mobileCtrl.text.isEmpty) {
          mobileCtrl.text = mobileNumber;
        }
        
        Get.snackbar(
          "Success", 
          "Provider onboarded! Please complete details.", 
          backgroundColor: Colors.green, 
          colorText: Colors.white
        );

      } else {
        throw Exception("API returned null ID");
      }

    } catch (e) {
      String userMessage = "Something went wrong";

      if (e is dio.DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final data = e.response?.data;
          if (data['result'] != null) {
            userMessage = data['result'].toString(); 
          } else {
             userMessage = e.message ?? "Server Error";
          }
        } else if (e.response?.statusCode == 412) {
          userMessage = "This provider is already registered.";
        } else {
          userMessage = e.message ?? "Connection Error";
        }
      } else {
        userMessage = e.toString().replaceAll("Exception:", "").trim();
      }

      print("Final Error Message: $userMessage");

      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(userMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating, 
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
      
    } finally {
      isLoading.value = false;
    }
  }

  // --- SELECTION LOGIC ---
  void onSelectExistingProvider(String? spId) {
    print("🔻 Dropdown Selected Raw Value: $spId");
    selectedProviderId.value = spId;
    
    if (spId == null) {
      resetForms();
      print("ℹ️ Selection cleared");
    } else {
      final provider = providerListController.allProviders.firstWhereOrNull((p) => p.id == spId);
      
      if (provider != null) {
        currentSpId = provider.id;
        
        // --- UPDATE: Mark Step 0 as completed since we loaded an existing user ---
        isPersonalDetailsCompleted.value = true; 
        
        print("✅ currentSpId successfully set to: $currentSpId");

        mobileCtrl.text = provider.mobileNo; 
        firstNameCtrl.text = provider.firstName ?? "";
        middleNameCtrl.text = provider.middleName ?? "";
        lastNameCtrl.text = provider.lastName ?? "";
        aadharCtrl.text = provider.aadharNo ?? "";
        
        careOfCtrl.text = provider.addressLine1 ?? "";
        landmarkCtrl.text = provider.addressLine2 ?? "";
        localityCtrl.text = provider.locality ?? "";
        cityCtrl.text = provider.city ?? "";
        stateCtrl.text = provider.state ?? "";
        pincodeCtrl.text = provider.zipCode ?? "";

        documentController.fetchUploadedDocuments(currentSpId!);
      } else {
        print("❌ CRITICAL ERROR: ID $spId was selected but not found in the provider list! The list might be stale.");
      }
    }
  }

  // --- NAVIGATION & LOGIC ---
  Future<void> nextStep() async {
    print("👉 Attempting Next Step. CurrentSpId: $currentSpId | Step: ${currentStep.value}");

    if (isLoading.value) return;
    
    if (currentSpId == null) {
      Get.snackbar("Error", "Please select a provider or onboard a new number first.");
      return;
    }
    
    bool success = false;
    isLoading.value = true;

    try {
      switch (currentStep.value) {
        case 0: 
          success = await _handlePersonalDetails(); 
          // --- UPDATE: If Step 0 success, unlock tabs ---
          if(success) isPersonalDetailsCompleted.value = true; 
          break;
        case 1: success = await _handleAddress(); break;
        case 2: success = await _handleLocationMapping(); break;
        case 3: success = await _handleServices(); break;
        case 4: success = await _handleFinancials(); break;
        case 5: success = await _handleDocuments(); break;
      }

      if (success) {
        if (currentStep.value < 4) {
          currentStep.value++;
        } else {
          await _finishOnboardingProcess();
        }
      }
    } catch (e) {
      String userMessage = "Something went wrong";
      
      if (e is dio.DioException) {
        final data = e.response?.data;
        if (data is Map && data['result'] != null) {
           userMessage = data['result'].toString(); 
        } else {
           userMessage = e.message ?? "Server Error";
        }
        print("❌ API Error: ${e.response?.statusCode} | ${e.response?.data}");
      } else {
        userMessage = e.toString().replaceAll("Exception:", "").trim();
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(userMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
            ),
          );
        }
      });
      
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _finishOnboardingProcess() async {
    if (onProviderAdded != null) onProviderAdded!();
    providerListController.fetchProviders();
    
    Get.defaultDialog(
      title: "Success",
      middleText: "Provider process completed!",
      confirm: ElevatedButton(
        onPressed: () { Get.back(); resetForms(); selectedProviderId.value = null; },
        child: const Text("Okay"),
      ),
      barrierDismissible: false,
    );
  }

  void resetForms() {
    currentSpId = null;
    isPersonalDetailsCompleted.value = false;
    
    firstNameCtrl.clear(); middleNameCtrl.clear(); lastNameCtrl.clear();
    mobileCtrl.clear(); emailCtrl.clear(); aadharCtrl.clear();
    careOfCtrl.clear(); localityCtrl.clear(); landmarkCtrl.clear();
    cityCtrl.clear(); districtCtrl.clear(); stateCtrl.clear(); pincodeCtrl.clear();
    
    // Reset Financials
    accHolderCtrl.clear(); accNumberCtrl.clear(); ifscCtrl.clear(); upiCtrl.clear();
    panNumberCtrl.clear();
    selectedBankId.value = null; // Reset Bank ID
    passbookFile.value = null;
    panCardFile.value = null;
    
    selectedGender.value = "";
    selectedServicesMap.clear();
    idProofFile.value = null;
    currentStep.value = 0;
  }
  
  void prevStep() { if (currentStep.value > 0) currentStep.value--; }

  // --- UPDATED: Navigation Logic ---
  void setStep(int step) { 
    // If Step 0 is completed, user can tap ANY step
    if (isPersonalDetailsCompleted.value) {
      currentStep.value = step;
    } 
    // If Step 0 is NOT completed, revert to standard locking (can only go back)
    else if (step < currentStep.value) { 
      currentStep.value = step; 
    } 
  }

  // --- SERVICE TOGGLE ---
  void toggleService(String catId, String serviceId) {
    if (!selectedServicesMap.containsKey(catId)) selectedServicesMap[catId] = <String>{};
    final set = selectedServicesMap[catId]!;
    if (set.contains(serviceId)) set.remove(serviceId);
    else set.add(serviceId);
    selectedServicesMap.refresh();
  }
  bool isServiceSelected(String catId, String serviceId) => selectedServicesMap[catId]?.contains(serviceId) ?? false;

  // In AddProviderController
Future<void> pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, 
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
        withData: true // 🔥 CRITICAL for Web: Loads bytes into memory
      );

      if (result != null) {
        // We directly store the PlatformFile. 
        // It contains .bytes (for web) and .path (for mobile/desktop)
        PlatformFile file = result.files.first;

        if (type == 'passbook') passbookFile.value = file;
        else if (type == 'pan') panCardFile.value = file;
        else if (type == 'idproof') idProofFile.value = file;
        
        // Force UI update
        update(); 
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  // --- API CALLS ---
  Future<bool> _handlePersonalDetails() async {
    // 1. Validation
    if (currentSpId == null) {
      Get.snackbar("Error", "No Service Provider Selected");
      return false;
    }
    if (firstNameCtrl.text.isEmpty || lastNameCtrl.text.isEmpty) {
      Get.snackbar("Required", "First Name and Last Name are mandatory");
      return false;
    }

    // 2. Prepare Payload
    final payload = {
      "spId": currentSpId,
      "firstName": firstNameCtrl.text.trim(),
      "middleName": middleNameCtrl.text.trim(),
      "lastName": lastNameCtrl.text.trim(),
      "gender": selectedGender.value,
      "aadharNo": aadharCtrl.text.trim(),
      "isAadharVerified": 0
    };

    // 3. Call API
    bool success = await _apiService.addPersonalDetails(payload);

    // 4. Real-Time Update Logic
    if (success) {
      print("✅ Personal details saved successfully.");
      
      // Refresh the global provider list immediately so the dropdowns 
      // and other screens show the new name/details instantly.
      await providerListController.fetchProviders();
      
      // Optional: If you need to keep the selection active after refresh
      // You might need to re-find the object in the new list, 
      // but usually the ID check in the UI handles this.
    } 

    return success;
  }
  
Future<bool> _handleAddress() async {
  // 1. Validation: Prevent null errors
  if (currentSpId == null) {
    Get.snackbar("Error", "No Service Provider Selected");
    return false;
  }

  // 2. CRITICAL VALIDATION FIX:
  // The API previously failed because addressLine1 was empty. 
  // We MUST check careOfCtrl here.
  if (careOfCtrl.text.trim().isEmpty) {
    safeSnackbar(
      "Required", 
      "House No / Building Name is required", 
    );
    return false;
  }

  // 3. Validation: Other key fields
  if (cityCtrl.text.isEmpty || stateCtrl.text.isEmpty || pincodeCtrl.text.isEmpty) {
    safeSnackbar("Required", "City, State, and Pincode are required");
    return false;
  }

  // 4. Prepare Payload
  final payload = {
    "spId": currentSpId,
    "addressLine1": careOfCtrl.text.trim(), // Validated above, safe to send
    "addressLine2": landmarkCtrl.text.trim(),
    "locality": localityCtrl.text.trim(),
    "city": cityCtrl.text.trim(),
    "state": stateCtrl.text.trim(),
    "postCode": pincodeCtrl.text.trim()
  };

  // 5. Call API
  bool success = await _apiService.addAddress(payload);

  // 6. Success Logic
  if (success) {
    print("✅ Address saved. Refreshing provider list...");
    
    // Refresh the list immediately so the UI reflects the new address
    await providerListController.fetchProviders(); 
    
    safeSnackbar("Success", "Address saved successfully!", isError: false);
  } else {
    // If it failed, check the debug console for the specific error
    safeSnackbar(
      "Error", 
      "Failed to save address. Check console for details.",
    );
  }

  return success;
}

  Future<bool> _handleServices() async {
    List<Future> tasks = [];
    bool anySelected = false;
    selectedServicesMap.forEach((catId, serviceIds) {
      for (var srvId in serviceIds) {
        anySelected = true;
        tasks.add(_apiService.mapProviderService(currentSpId!, catId, srvId));
      }
    });
    if (!anySelected) throw Exception("Please select at least one service");
    await Future.wait(tasks);
    return true;
  }
Future<dio.MultipartFile> getMultipart(PlatformFile file) async {
  // 1. Determine Mime Type (e.g., "image/jpeg")
  // If you don't have mime package, default to image/jpeg or verify file extension
  final mimeType = lookupMimeType(file.name) ?? 'image/jpeg'; 
  final typeData = mimeType.split('/'); 
  
  if (kIsWeb) {
    return dio.MultipartFile.fromBytes(
      file.bytes!,
      filename: file.name,
      contentType: MediaType(typeData[0], typeData[1]), // <--- FIX HERE
    );
  } else {
    return dio.MultipartFile.fromFile(
      file.path!,
      filename: file.name,
      contentType: MediaType(typeData[0], typeData[1]), // <--- FIX HERE
    );
  }
}
  // --- UPDATED: Handle Financials (Step 4) ---
// --- UPDATED: HANDLE FINANCIALS (WEB SAFE) ---
Future<bool> _handleFinancials() async {
  if (selectedBankId.value == null) {
    safeSnackbar("Error", "Please select a Bank", isError: true);
    return false;
  }

  if (passbookFile.value == null) {
    safeSnackbar("Error", "Passbook image required", isError: true);
    return false;
  }

  if (isPanAvailable.value && panCardFile.value == null) {
    safeSnackbar("Error", "PAN card image required", isError: true);
    return false;
  }

  try {
    // Prepare FormData for Dio
   final formData = dio.FormData.fromMap({
  "passBookFile": await getMultipart(passbookFile.value!),
  if (panCardFile.value != null)
    "panCardFile": await getMultipart(panCardFile.value!),
});


    // Call API with formData
    return await _apiService.addBankDetails(
      spId: currentSpId!,
      bankId: selectedBankId.value!,
      accountHolderName: accHolderCtrl.text.trim(),
      accountNo: accNumberCtrl.text.trim(),
      ifscCode: ifscCtrl.text.trim(),
      upiId: upiCtrl.text.trim(),
      isPanAvailable: isPanAvailable.value,
      panNo: panNumberCtrl.text.trim(),
      formData: formData,
    );
  } catch (e) {
    debugPrint("❌ Error adding financial details: $e");
    safeSnackbar(
      "Error",
      "Failed to save bank details",
      isError: true,
    );
    return false;
  }
}



// --- NEW: Handle Mapping Logic (Step 2) ---
  Future<bool> _handleLocationMapping() async {
    if (selectedLocation.value == null) {
      safeSnackbar("Error", "Please select a location area from the dropdown.");
      return false;
    }

    final loc = selectedLocation.value!;
    
    // Construct Payload
    final payload = {
      "serviceProviderId": currentSpId,
      "locationId": loc.id,    // Assuming 'id' is the location ID
      "areaId": loc.areaId     // Sending areaId as requested
    };

    print("📍 Sending Map Payload: $payload");

    return await _apiService.mapProviderLocation(payload);
  }

Future<bool> _handleDocuments() async {
  // 1. Ensure Service Provider ID exists
  if (currentSpId == null) {
    safeSnackbar("Error", "Service Provider not selected.", isError: true);
    return false;
  }

  final docCtrl = documentController;

  // 2. Ensure document types are loaded
  if (docCtrl.docTypes.isEmpty) {
    safeSnackbar("Error", "No document types available.", isError: true);
    return false;
  }

  // 3. Validate required documents
  // (Assuming ALL document types are mandatory – adjust if needed)
  final missingDocs = docCtrl.docTypes.where((docType) {
    return !docCtrl.isUploaded(docType.id);
  }).toList();

  if (missingDocs.isNotEmpty) {
    safeSnackbar(
      "Error",
      "Please upload all required documents before continuing.",
      isError: true,
    );
    return false;
  }

  // 4. Ensure no uploads are still in progress
  if (docCtrl.uploadingDocIds.isNotEmpty) {
    safeSnackbar(
      "Please wait",
      "Documents are still uploading.",
      isError: true,
    );
    return false;
  }

  // 5. Final server sync (safety)
  await docCtrl.fetchUploadedDocuments(currentSpId!);

  // 6. Final confirmation
  safeSnackbar("Success", "All documents verified successfully!");
  return true;
}

}