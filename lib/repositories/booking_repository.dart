import 'dart:convert'; // Import for jsonEncode
import '../services/api_service.dart';
import '../models/booking_models.dart';

class BookingRepository {
  final ApiService _api = ApiService();

  Future<BookingResponse> fetchBookings({int page = 1, int size = 10}) async {
    try {
      print("--- REPO: Fetching Bookings (Page: $page, Size: $size) ---");
      
      final response = await _api.getBookings(page: page, size: size);
      
      // DEBUG: Print the raw response from API
      // We use jsonEncode to make the map readable in the console
      print("--- REPO: Raw Response ---");
      print(jsonEncode(response)); 
      print("--------------------------");

      return BookingResponse.fromJson(response);
    } catch (e) {
      print("Repo Error: $e");
      throw Exception("Failed to load bookings");
    }
  }
}