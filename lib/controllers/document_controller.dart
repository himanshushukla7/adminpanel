import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../services/api_service.dart';
import '../models/document_type_model.dart';

class DocumentController extends GetxController {
  final ApiService _apiService = ApiService();

  // ----------------------------
  // Loading & master data
  // ----------------------------
  final isLoading = false.obs;
  final docTypes = <DocumentTypeModel>[].obs;

  // ----------------------------
  // Upload UI states
  // ----------------------------
  final uploadingDocIds = <String>{}.obs;
  final failedDocIds = <String>{}.obs;

  // ----------------------------
  // SERVER SOURCE OF TRUTH
  // docTypeId -> server document
  // ----------------------------
  final serverUploadedDocs = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocumentTypes();
  }

  // ----------------------------
  // Fetch document types
  // ----------------------------
  Future<void> fetchDocumentTypes() async {
    try {
      // Don't set global loading here to avoid blocking UI, 
      // just fetch in background if not critical
      final types = await _apiService.getDocumentTypes();
      if (types.isNotEmpty) {
        docTypes.value = types;
      }
    } catch (e) {
      debugPrint("❌ Failed to load document types: $e");
    }
  }

  // ----------------------------
  // FIX: Fetch already uploaded docs
  // ----------------------------
  Future<void> fetchUploadedDocuments(String spId) async {
    try {
      isLoading.value = true;

      // 1. CRITICAL: Ensure we have the master types before mapping!
      if (docTypes.isEmpty) {
        print("⏳ DocTypes empty, fetching master list first...");
        await fetchDocumentTypes();
      }

      final response = await _apiService.getServiceProviderDocuments(spId);
      
      // Clear old data
      serverUploadedDocs.clear();

      for (final doc in response) {
        final docTypeName = doc['docType']; // e.g., "Identity Document"

        if (docTypeName == null) continue;

        // 2. Match backend NAME with local docType
        final matchedType = docTypes.firstWhereOrNull(
          (e) => e.name.trim().toLowerCase() == docTypeName.toString().trim().toLowerCase(),
        );

        if (matchedType == null) {
          debugPrint("⚠️ No matching local docType found for API type: $docTypeName");
          // Check if your API naming matches your DB naming exactly (ignoring case)
          continue;
        }

        // 3. Store match
        serverUploadedDocs[matchedType.id] = Map<String, dynamic>.from(doc);
      }

      print("✅ Mapped ${serverUploadedDocs.length} documents for UI.");
      serverUploadedDocs.refresh(); // Force UI update

    } catch (e) {
      debugPrint("❌ Fetch uploaded documents failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------
  // Pick & upload document
  // ----------------------------
  // ----------------------------
  // Pick & upload document
  // ----------------------------
  Future<void> pickAndUpload({
    required String docTypeId,
    required String spId,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      if (kIsWeb && file.bytes == null) {
        _safeSnack("Error", "Browser could not read file data", error: true);
        return;
      }

      // 1. UPDATE UI: Clear previous error, show loading IMMEDIATELY
      failedDocIds.remove(docTypeId);
      uploadingDocIds.add(docTypeId);
      
      // Force UI to see the change
      failedDocIds.refresh(); 
      uploadingDocIds.refresh();

      // 2. Perform Request
      final success = await _apiService.uploadSpDocument(
        spId: spId,
        docTypeId: docTypeId,
        file: file,
      );

      // 3. Remove loading state
      uploadingDocIds.remove(docTypeId);
      uploadingDocIds.refresh(); 

      if (success) {
        _safeSnack("Success", "Document uploaded successfully");
        // Only fetch list on success to prevent "flashing" the page on error
        await fetchUploadedDocuments(spId); 
      } else {
        // 4. Handle logical failure (API returned false)
        failedDocIds.add(docTypeId);
        failedDocIds.refresh(); // 🔥 Forces the Red Box to appear instantly
        
        _safeSnack("Error", "Upload failed", error: true);
      }
    } catch (e) {
      // 5. Handle Exceptions (like the 404 you are seeing)
      uploadingDocIds.remove(docTypeId);
      failedDocIds.add(docTypeId);
      
      // 🔥 Forces the Red Box to appear instantly
      uploadingDocIds.refresh();
      failedDocIds.refresh(); 

      debugPrint("❌ Upload error: $e");

      // Specific error message for 404
      if (e.toString().contains("404")) {
        _safeSnack("API Error", "Server could not find this Provider (404).", error: true);
      } else {
        _safeSnack("Error", "Something went wrong", error: true);
      }
    }
  }
  // ----------------------------
  // UI helpers
  // ----------------------------
  bool isUploading(String docTypeId) => uploadingDocIds.contains(docTypeId);
  bool isFailed(String docTypeId) => failedDocIds.contains(docTypeId);
  bool isUploaded(String docTypeId) => serverUploadedDocs.containsKey(docTypeId);

  String uploadedFileName(String docTypeId) {
    final url = serverUploadedDocs[docTypeId]?['docUrl'];
    if (url == null) return 'File Uploaded';
    return url.toString().split('/').last;
  }

  String uploadedFileUrl(String docTypeId) =>
      serverUploadedDocs[docTypeId]?['docUrl'] ?? '';

  void _safeSnack(String title, String message, {bool error = false}) {
    if (Get.context == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: error ? Colors.red : Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }
}