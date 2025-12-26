import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'dart:js_util' as js_util;
import '../models/location_model.dart';

class LocationController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var locationList = <LocationModel>[].obs;
  var filteredLocationList = <LocationModel>[].obs;

  // --- Form Inputs ---
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final areaNameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pinCodeCtrl = TextEditingController();
  
  // --- Search Controllers ---
  final searchCtrl = TextEditingController();
  final listSearchCtrl = TextEditingController();

  // --- Map & Polygon Logic ---
  var polygonPoints = <LatLng>[].obs;
  var mapMarkers = <Marker>{}.obs;
  GoogleMapController? _mapController;

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  @override
  void onClose() {
    areaNameCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pinCodeCtrl.dispose();
    searchCtrl.dispose();
    listSearchCtrl.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void fetchLocations() async {
    isLoading(true);
    locationList.value = await _apiService.getLocations();
    filteredLocationList.value = locationList;
    isLoading(false);
  }

  // Filter locations based on search text
  void filterLocations(String query) {
    if (query.isEmpty) {
      filteredLocationList.value = locationList;
    } else {
      filteredLocationList.value = locationList.where((loc) {
        return loc.areaName.toLowerCase().contains(query.toLowerCase()) ||
               (loc.city?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (loc.state?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (loc.postCode?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }
  }

  // Dynamic search using Google Maps Geocoding API from index.html
  Future<void> searchAndMoveCamera(String placeName) async {
    if (placeName.isEmpty) return;

    try {
      // Call the geocodeAddress function from index.html
      final result = await _callJavaScriptGeocoding(placeName);
      
      if (result != null && result['lat'] != null && result['lng'] != null) {
        final lat = result['lat'] as double;
        final lng = result['lng'] as double;
        
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(lat, lng),
              zoom: 14,
            ),
          ),
        );
        
        Get.snackbar(
          "Location Found",
          "Moved to $placeName",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "Not Found",
          "Could not find location: $placeName",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to search location: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

 Future<Map<String, dynamic>?> _callJavaScriptGeocoding(String address) async {
    try {
      // Small delay to ensure JS is ready
      await Future.delayed(const Duration(milliseconds: 500));

      // 1. Use js_util to access the global scope (window)
      // Check if the function exists
      if (!js_util.hasProperty(js_util.globalThis, 'geocodeAddress')) {
        print('JS function geocodeAddress not found');
        return null;
      }

      // 2. Call the function using js_util.callMethod
      // This returns a raw JS Promise, not a JsObject wrapper
      final promise = js_util.callMethod(js_util.globalThis, 'geocodeAddress', [address]);

      // 3. Convert the raw Promise to a Dart Future
      final result = await js_util.promiseToFuture(promise);

      // 4. Access properties using js_util.getProperty
      // This is safer than result['lat'] for web compilation
      if (result != null) {
        return {
          'lat': js_util.getProperty(result, 'lat'),
          'lng': js_util.getProperty(result, 'lng'),
        };
      }
      return null;
    } catch (e) {
      print('JS Geocoding error: $e');
      return null;
    }
  }
  // Map zoom controls
  void zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  // Called when user taps the map
  void addPolygonPoint(LatLng point) {
    polygonPoints.add(point);
    mapMarkers.add(
      Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  void undoLastPoint() {
    if (polygonPoints.isNotEmpty) {
      final lastPoint = polygonPoints.removeLast();
      mapMarkers.removeWhere((m) => m.position == lastPoint);
    }
  }

  void clearPolygon() {
    polygonPoints.clear();
    mapMarkers.clear();
  }

  // Convert polygon points to WKT (Well-Known Text) format
  String _convertToWKT(List<LatLng> points) {
    if (points.isEmpty) return '';
    
    // Ensure polygon is closed (first point = last point)
    List<LatLng> closedPoints = List.from(points);
    if (closedPoints.first.latitude != closedPoints.last.latitude ||
        closedPoints.first.longitude != closedPoints.last.longitude) {
      closedPoints.add(closedPoints.first);
    }
    
    // Format: POLYGON((lng lat, lng lat, ...))
    String coordinates = closedPoints
        .map((point) => '${point.longitude} ${point.latitude}')
        .join(',');
    
    return 'POLYGON(($coordinates))';
  }

  // Generate JSON payload showing all fields (null if not filled)
  String generateJsonPayload() {
    String? wktPolygon;
    
    if (polygonPoints.isNotEmpty) {
      wktPolygon = _convertToWKT(polygonPoints);
    }

    final payload = {
      "area_id": areaNameCtrl.text.isNotEmpty ? const Uuid().v4() : null,
      "area_name": areaNameCtrl.text.isNotEmpty ? areaNameCtrl.text : null,
      "city": cityCtrl.text.isNotEmpty ? cityCtrl.text : null,
      "state": stateCtrl.text.isNotEmpty ? stateCtrl.text : null,
      "post_code": pinCodeCtrl.text.isNotEmpty ? pinCodeCtrl.text : null,
      "geo_boundary": wktPolygon,
      "boundary_type": wktPolygon != null ? "POLYGON" : null,
    };

    // Pretty print JSON with indentation
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  // Copy payload to clipboard
  void copyPayloadToClipboard() {
    final payload = generateJsonPayload();
    Clipboard.setData(ClipboardData(text: payload));
  }

  Future<void> submitLocation() async {
    if (!formKey.currentState!.validate()) return;

    if (polygonPoints.length < 3) {
      Get.snackbar(
        "Error",
        "Please draw a valid area on the map (at least 3 points)",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading(true);

    // Convert to WKT format for API
    String wktPolygon = _convertToWKT(polygonPoints);

    final newLoc = LocationModel(
      areaId: const Uuid().v4(),
      areaName: areaNameCtrl.text,
      city: cityCtrl.text,
      state: stateCtrl.text,
      postCode: pinCodeCtrl.text,
      geoBoundary: wktPolygon,
    );

    bool success = await _apiService.addLocation(newLoc);

    if (success) {
      Get.snackbar(
        "Success",
        "Location Added Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchLocations();
      _clearForm();
    } else {
      Get.snackbar(
        "Error",
        "Failed to add location",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading(false);
  }

  void _clearForm() {
    areaNameCtrl.clear();
    cityCtrl.clear();
    stateCtrl.clear();
    pinCodeCtrl.clear();
    clearPolygon();
  }
}