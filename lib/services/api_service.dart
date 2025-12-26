import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; 
import 'package:mime/mime.dart'; 
import '../models/location_model.dart';
import '../models/data_models.dart';
import 'dart:convert'; // Required for jsonEncode
import 'dart:io';
import '../models/document_type_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // To check web
import 'package:file_picker/file_picker.dart'; // Import this
import '../models/bank_model.dart';

class ApiService {
  // NO trailing slash
  static const String baseUrl = 'https://api.chayankaro.com'; 

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor to add Token to requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        print("API Error: ${e.response?.statusCode} | ${e.response?.data}");
        return handler.next(e);
      }
    ));
  }
Future<dio.MultipartFile> getMultipart(PlatformFile file) async {
    // Determine Mime Type (e.g., 'image/png')
    // Defaults to 'image/jpeg' if detection fails to ensure backend accepts it
    final mimeTypeStr = lookupMimeType(file.name) ?? 'image/jpeg';
    final mimeSplit = mimeTypeStr.split('/');
    final mediaType = MediaType(mimeSplit[0], mimeSplit[1]);

    if (kIsWeb) {
      return dio.MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
        contentType: mediaType, // Explicit Content-Type for Web
      );
    } else {
      return dio.MultipartFile.fromFile(
        file.path!,
        filename: file.name,
        contentType: mediaType, // Explicit Content-Type for Mobile
      );
    }
  }
  // --- HELPER ---
  Future<MultipartFile?> _prepareFile(Uint8List? fileBytes, String? fileName) async {
    if (fileBytes == null || fileName == null) return null;
    final mimeType = lookupMimeType(fileName);
    return MultipartFile.fromBytes(
      fileBytes,
      filename: fileName,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );
  }

  // --- 1. AUTH ---
  // Returns LoginResponseModel or throws error
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final response = await _dio.post('/admin/adminLogin', data: {
        "username": username,
        "password": password
      });

      if (response.statusCode == 200 && response.data['result'] != null) {
        // We pass the whole JSON, the Model handles the nested 'result'
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception("Invalid Response: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Login Failed: $e");
    }
  }

  // --- 2. CATEGORIES ---
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/admin/getCategory');
      if (response.data['result'] is List) {
        return (response.data['result'] as List).map((x) => CategoryModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> addCategory(String name, Uint8List? imageBytes, String? imageName) async {
    try {
      FormData formData = FormData.fromMap({
        "name": name,
        if (imageBytes != null) "image": await _prepareFile(imageBytes, imageName),
      });
      await _dio.post('/admin/addCategories', data: formData);
      return true;
    } catch (e) { return false; }
  }

  // --- 3. SERVICE CATEGORIES ---
  // --- 3. SERVICE CATEGORIES ---
  Future<List<ServiceCategoryModel>> getServiceCategories(String? parentId) async {
    try {
      // If parentId is null, we can't fetch specific services based on current API design
      if (parentId == null) return [];

      final response = await _dio.get('/admin/getServiceCategory', 
        queryParameters: {'categoryId': parentId});
      
      if (response.data['result'] is List) {
        return (response.data['result'] as List).map((x) => 
          // PASS THE parentId HERE so the model knows its parent
          ServiceCategoryModel.fromJson(x, linkCategoryId: parentId)
        ).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> addServiceCategory(String parentId, String name, Uint8List? imageBytes, String? imageName) async {
    try {
      FormData formData = FormData.fromMap({
        "categoryId": parentId,
        "name": name,
        if (imageBytes != null) "image": await _prepareFile(imageBytes, imageName),
      });
      await _dio.post('/admin/addServiceCategory', data: formData);
      return true;
    } catch (e) { return false; }
  }

  // --- 4. SERVICES ---
 // --- 4. SERVICES ---
  // UPDATE THIS METHOD IN YOUR API SERVICE
  Future<List<ServiceModel>> getServices({String? categoryId}) async {
    try {
      final response = await _dio.get(
        '/admin/getServices',
        // Pass the categoryId if it exists
        queryParameters: categoryId != null ? {'categoryId': categoryId} : {},
      );

      if (response.data['result'] is List) {
        return (response.data['result'] as List)
            .map((x) => ServiceModel.fromJson(x))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }



// Inside your ApiService class...

Future<bool> addService(Map<String, dynamic> serviceData, Uint8List? imageBytes, String? imageName) async {
  try {
    // 1. Create the Multipart Request
    // The API expects two specific parts: "request" (JSON) and "file" (Binary)
    
    final Map<String, dynamic> formDataMap = {
      // Wrap the service details into a JSON string for the 'request' part
      'request': MultipartFile.fromString(
        jsonEncode(serviceData),
        contentType: MediaType.parse('application/json'), 
      ),
    };

    // 2. Add the Image file (Key must be 'file' based on your schema)
    if (imageBytes != null) {
      formDataMap['file'] = MultipartFile.fromBytes(
        imageBytes,
        filename: imageName ?? 'service_img.jpg',
      );
    }

    FormData formData = FormData.fromMap(formDataMap);

    // 3. Send Request
    // Note: Ensure your _dio instance has the 'Authorization: Bearer <token>' header set!
    final response = await _dio.post(
      '/admin/addServices',
      data: formData,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("API Error: $e");
    // If e is DioException, print the response for debugging
    if (e is DioException) {
      print("Server Response: ${e.response?.data}");
    }
    return false;
  }
}
  // --- 5. LOCATIONS ---

  Future<List<LocationModel>> getLocations() async {
    try {
      final response = await _dio.get('/admin/getLocation');
      if (response.data['result'] is List) {
        return (response.data['result'] as List)
            .map((x) => LocationModel.fromJson(x))
            .toList();
      }
      return [];
    } catch (e) {
      print("Get Location Error: $e");
      return [];
    }
  }

  Future<bool> addLocation(LocationModel location) async {
    try {
      // We send the JSON body directly
      await _dio.post('/admin/addLocation', data: location.toJson());
      return true;
    } catch (e) {
      print("Add Location Error: $e");
      return false;
    }
  }
  // inside your ApiService class
Future<dynamic> getAllCustomers({required int page, required int size}) async {
  try {
    // Replace 'dio' with your http client instance
    final response = await _dio.get(
      '/admin/getAllCustomer',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
    return response.data;
  } catch (e) {
    rethrow;
  }
}
// --- BOOKINGS ---
  Future<dynamic> getBookings({required int page, required int size}) async {
    try {
      final response = await _dio.get(
        '/admin/getBookings',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  Future<dynamic> getAllServiceProviders() async {
    try {
      final response = await _dio.get('/admin/getAllServiceProvider');
      return response.data;
    } catch (e) {
      print("API Error (Get Providers): $e");
      rethrow; // Pass error to repo for handling
    }
  }
  // inside api_service.dart

  // --- BUFFER CONFIGURATION ---
  Future<dynamic> addBufferTime(Map<String, dynamic> configData) async {
    try {
      // POST request to the specific endpoint
      final response = await _dio.post('/admin/addBufferTime', data: configData);
      return response.data;
    } catch (e) {
      print("API Error (Add Buffer Time): $e");
      rethrow; // Pass error to repo
    }
  }
  // 1. Onboard Provider (Get SP ID)
 Future<String?> onboardServiceProvider(String mobileNo) async {
    try {
      final response = await _dio.post('/admin/onboardServiceProvider', data: {"mobileNo": mobileNo});
      final data = response.data;
      // Handle structure { "result": { "id": "..." } } or { "id": "..." }
      if (data['result'] != null && data['result'] is Map && data['result']['id'] != null) {
        return data['result']['id'];
      }
      return data['id']; // Fallback
    } catch (e) {
      throw Exception("Onboard Error: ${e.toString()}");
    }
  }

// In services/api_service.dart

Future<bool> addPersonalDetails(Map<String, dynamic> data) async {
  try {
    print("📤 Sending Personal Details: $data"); // Debug print
    
    final response = await _dio.post('/admin/addSpPersonalDetails', data: data);
    
    print("✅ API Response: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("❌ API ERROR:"); 
    if (e is dio.DioException) {
      print("Status: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}"); // This usually contains the specific validation error
    } else {
      print(e.toString());
    }
    return false; // Now you know why it returned false
  }
}

 Future<bool> addAddress(Map<String, dynamic> data) async {
  try {
    print("📤 Sending Address Data: $data"); // See exactly what you are sending
    
    final response = await _dio.post('/admin/addSpAddress', data: data);
    
    print("✅ Address API Success: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("❌ Address API Failed:");
    if (e is dio.DioException) {
      print("Status: ${e.response?.statusCode}");
      print("Response Body: ${e.response?.data}"); // This tells you WHY it failed (e.g. invalid pincode)
    } else {
      print("Error: $e");
    }
    return false;
  }
}
  // Add this to your api_service.dart
Future<bool> mapProviderLocation(Map<String, dynamic> data) async {
  try {
    // Replace '/admin/providerLocationMap' with your actual full endpoint path if needed
    final response = await _dio.post('/admin/providerLocationMap', data: data);
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("Error mapping location: $e");
    return false; // Or rethrow based on your error handling preference
  }
}

  Future<bool> mapProviderService(String spId, String catId, String srvId) async {
    try {
      await _dio.post('/admin/providerServiceMap', data: {
        "serviceProviderId": spId,
        "categoryId": catId,
        "serviceId": srvId
      });
      return true;
    } catch (e) { return false; }
  }

// ---------------------------------------------------------------------------
 Future<bool> addBankDetails({
    required String spId,
    required String bankId,
    required String accountHolderName,
    required String accountNo,
    required String ifscCode,
    required String upiId,
    required bool isPanAvailable,
    required String panNo,
    required dio.FormData formData,
  }) async {
    try {
      print("🚀 Sending Bank Details...");
      
      // Sanitize inputs (remove accidental newlines which appeared in your logs)
      final cleanHolderName = accountHolderName.trim().replaceAll('\n', ' ');

      final response = await _dio.post(
        '/admin/addBankDetails',
        data: formData,
        // CRITICAL FIX: Set Content-Type to null. 
        // This removes 'application/json' and lets Dio generate 
        // 'multipart/form-data; boundary=jhdfg78...' automatically.
        options: Options(
          headers: {
            "Content-Type": null, 
          },
        ),
        queryParameters: {
          "spId": spId,
          "bankId": bankId,
          "accountHolderName": cleanHolderName,
          "accountNo": accountNo.trim(),
          "ifscCode": ifscCode.trim(),
          "upiId": upiId.trim(),
          "isPanAvailable": isPanAvailable,
          "panNo": panNo.trim(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (e is dio.DioException) {
        print("❌ addBankDetails URL: ${e.requestOptions.uri}");
        print("❌ Headers Sent: ${e.requestOptions.headers}"); // Check if boundary exists
        print("❌ addBankDetails error: ${e.response?.data}");
      }
      return false;
    }
  }

  Future<bool> addSpDocument(FormData formData) async {
    try {
      await _dio.post('/admin/addSpDocument', data: formData);
      return true;
    } catch (e) { return false; }
  }

  // 1. Fetch All Document Types
Future<List<DocumentTypeModel>> getDocumentTypes() async {
  try {
    final response = await _dio.get('/admin/getDocumentType');
    if (response.statusCode == 200 && response.data['result'] != null) {
      List<dynamic> list = response.data['result'];
      return list.map((e) => DocumentTypeModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print("Error fetching doc types: $e");
    return [];
  }
}

// 2. Upload Single Document
Future<bool> uploadSpDocument({
    required String spId, 
    required String docTypeId, 
    required PlatformFile file 
  }) async {
    try {
      // 1. Prepare the File (Web vs Mobile)
      dio.MultipartFile multipartFile;

      if (kIsWeb) {
        // Web: Use Bytes
        multipartFile = dio.MultipartFile.fromBytes(
          file.bytes!, 
          filename: file.name
        );
      } else {
        // Mobile: Use Path
        multipartFile = await dio.MultipartFile.fromFile(
          file.path!,
          filename: file.name
        );
      }

      // 2. Body: File goes here (key: 'file')
      final formData = dio.FormData.fromMap({
        "file": multipartFile, 
      });

      // 3. URL: IDs go here
      final queryParams = {
        "documentTypeId": docTypeId,
        "spId": spId
      };

      print("📤 Uploading: $queryParams");

      final response = await _dio.post(
  '/admin/addSpDocument',
  data: formData,
  queryParameters: queryParams,
);

print("✅ Upload response: ${response.statusCode}");
print("📦 Response data: ${response.data}");

return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Upload Failed: $e");
      if (e is dio.DioException) {
         print("Server Response: ${e.response?.data}");
      }
      return false;
    }
  }
  Future<List<dynamic>> getServiceProviderDocuments(String spId) async {
  try {
    final response = await _dio.get(
      '/admin/getServiceProviderDocuments',
      queryParameters: {
        'serviceProviderId': spId,
      },
    );

    print("📄 Existing docs response: ${response.data}");
    return response.data['result'] ?? [];
  } catch (e) {
    print("❌ Fetch documents failed: $e");
    return [];
  }
}
Future<List<BankModel>> getAllBanks() async {
  try {
    // Replace with your actual Dio instance call
    final response = await _dio.get('/admin/getAllBank'); 
    
    if (response.statusCode == 200 && response.data['result'] != null) {
      final List<dynamic> list = response.data['result'];
      return list.map((e) => BankModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print("Error fetching banks: $e");
    return [];
  }
}

}