import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; 
import 'package:mime/mime.dart'; 

import '../models/data_models.dart';

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

  Future<bool> addService(Map<String, dynamic> data, Uint8List? imageBytes, String? imageName) async {
    try {
      final mapData = <String, dynamic>{...data};
      if (imageBytes != null) mapData['image'] = await _prepareFile(imageBytes, imageName);
      
      FormData formData = FormData.fromMap(mapData);
      await _dio.post('/admin/addServices', data: formData);
      return true;
    } catch (e) { return false; }
  }
}