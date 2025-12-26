import 'package:get/get.dart';
import '../models/bank_model.dart';
import '../services/api_service.dart';

class BankingController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var bankList = <BankModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanks();
  }

  Future<void> fetchBanks() async {
    try {
      isLoading.value = true;
      final banks = await _apiService.getAllBanks();
      bankList.assignAll(banks);
    } catch (e) {
      print("❌ Failed to load banks: $e");
    } finally {
      isLoading.value = false;
    }
  }
}