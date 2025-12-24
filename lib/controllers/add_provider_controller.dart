import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProviderController extends GetxController {
  @override
void onInit() {
  super.onInit();
  
  if (Get.arguments != null && Get.arguments['isDashboardMode'] == true) {
    var data = Get.arguments['requestData'];
    
    // PRE-FILL FORM
    firstNameCtrl.text = data.name.split(" ")[0]; // Just an example
    mobileCtrl.text = data.phone;
    emailCtrl.text = data.email;
    
    // If you want to disable editing for View Only mode
    // You can add an Observable bool `isReadOnly` to your controller
  }
}
  var currentStep = 0.obs;

  // --- 1. PERSONAL DETAILS ---
  final firstNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  var selectedGender = "Male".obs;

  // --- 2. ADDRESS & LOCATION ---
  final careOfCtrl = TextEditingController();
  final localityCtrl = TextEditingController();
  final landmarkCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final countryCtrl = TextEditingController(text: "India");
  var selectedServiceCity = "".obs;

  // --- 3. SERVICES (The Fix: Use this Nested Structure) ---
  // Note: We use 'final' and '.obs' on the list.
  // We use '.obs' on the 'selected' keys to make them reactive.
  final serviceCategories = <Map<String, dynamic>>[
    {
      "category": "Home Maintenance",
      "subCategories": [
        {
          "name": "Plumbing",
          "selected": false.obs, // RxBool
          "services": [
            {"name": "Tap Repair", "selected": false.obs}, // RxBool
            {"name": "Pipe Fitting", "selected": false.obs},
            {"name": "Basin Installation", "selected": false.obs},
            {"name": "Blockage Removal", "selected": false.obs},
          ]
        },
        {
          "name": "Electrical",
          "selected": false.obs,
          "services": [
            {"name": "Wiring", "selected": false.obs},
            {"name": "Fan Repair", "selected": false.obs},
            {"name": "Switchboard Installation", "selected": false.obs},
          ]
        },
        {
          "name": "Cleaning",
          "selected": false.obs,
          "services": [
            {"name": "Deep Cleaning", "selected": false.obs},
            {"name": "Sofa Cleaning", "selected": false.obs},
          ]
        },
        {
          "name": "AC Repair",
          "selected": false.obs,
          "services": [
            {"name": "AC Service", "selected": false.obs},
            {"name": "Gas Refill", "selected": false.obs},
          ]
        },
      ]
    }
  ].obs;

  // --- 4. FINANCIALS ---
  var selectedBank = "".obs;
  final accHolderCtrl = TextEditingController();
  final accNumberCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final upiCtrl = TextEditingController();
  var isPanAvailable = true.obs;
  final panNumberCtrl = TextEditingController();

  // --- 5. DOCUMENTS ---
  var selectedQualification = "".obs;
  var selectedDocType = "".obs;

  // --- NAVIGATION ---
  void nextStep() {
    if (currentStep.value < 4) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void setStep(int step) {
    currentStep.value = step;
  }
}