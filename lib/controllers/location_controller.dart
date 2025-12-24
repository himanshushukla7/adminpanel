import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart'; // Add uuid package to generate IDs if needed
import '../services/api_service.dart';
import '../models/location_model.dart';

class LocationController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var locationList = <LocationModel>[].obs;

  // --- Form Inputs ---
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final areaNameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pinCodeCtrl = TextEditingController();

  // --- Map & Polygon Logic ---
  var polygonPoints = <LatLng>[].obs; // Stores points user tapped
  var mapMarkers = <Marker>{}.obs;    // Visual markers for taps

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  void fetchLocations() async {
    isLoading(true);
    locationList.value = await _apiService.getLocations();
    isLoading(false);
  }

  // Called when user taps the map
  void addPolygonPoint(LatLng point) {
    polygonPoints.add(point);
    
    // Add a visual marker so user knows where they tapped
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

  Future<void> submitLocation() async {
    if (!formKey.currentState!.validate()) return;
    
    if (polygonPoints.length < 3) {
      Get.snackbar("Error", "Please draw a valid area on the map (at least 3 points)", 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading(true);

    // Convert List<LatLng> to the string format your backend expects.
    // Assuming JSON string [[lat,lng], [lat,lng]] for now.
    // Adjust this formatting logic based on exact backend requirement.
    List<List<double>> rawPoints = polygonPoints.map((e) => [e.latitude, e.longitude]).toList();
    // Close the loop (repeat first point at end) if backend requires closed polygon
    if (rawPoints.first != rawPoints.last) {
      rawPoints.add(rawPoints.first);
    }
    String geoBoundaryString = jsonEncode(rawPoints);

    final newLoc = LocationModel(
      areaId: const Uuid().v4(), // Generate a unique ID
      areaName: areaNameCtrl.text,
      city: cityCtrl.text,
      state: stateCtrl.text,
      postCode: pinCodeCtrl.text,
      geoBoundary: geoBoundaryString,
    );

    bool success = await _apiService.addLocation(newLoc);

    if (success) {
      Get.back(); // Close dialog/screen
      Get.snackbar("Success", "Location Added Successfully", backgroundColor: Colors.green, colorText: Colors.white);
      fetchLocations(); // Refresh list
      _clearForm();
    } else {
      Get.snackbar("Error", "Failed to add location", backgroundColor: Colors.red, colorText: Colors.white);
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