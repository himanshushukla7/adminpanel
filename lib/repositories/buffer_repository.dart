import '../services/api_service.dart';

class BufferRepository {
  final ApiService _api = ApiService();

  Future<bool> saveBufferSettings({
    required int distanceFrom,
    required int distanceTo,
    required int bufferBefore,
    required int bufferAfter,
  }) async {
    try {
      // 1. Prepare the JSON body
      final Map<String, dynamic> body = {
        "distanceFrom": distanceFrom,
        "distanceTo": distanceTo,
        "bufferBefore": bufferBefore,
        "bufferAfter": bufferAfter,
      };

      // 2. Call the API Service
      final response = await _api.addBufferTime(body);

      // 3. Check for success 
      // (Adjust logic based on whether your API returns a specific status code or boolean)
      if (response != null) {
        return true;
      }
      return false;
      
    } catch (e) {
      print("Buffer Repo Error: $e");
      return false; // Return false so UI knows it failed
    }
  }
}