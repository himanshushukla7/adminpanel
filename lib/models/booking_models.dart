class BookingResponse {
  final List<BookingModel> content;
  final int totalPages;
  final int totalElements;

  BookingResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final contentList = result['content'] as List? ?? [];
    
    return BookingResponse(
      content: contentList.map((e) => BookingModel.fromJson(e)).toList(),
      totalPages: result['totalPages'] ?? 0,
      totalElements: result['totalElements'] ?? 0,
    );
  }
}

class BookingModel {
  final String id;
  final String bookingRef;
  final String bookingDate;
  final String bookingTime;
  final String creationTime;
  final String status;
  final String paymentStatus;
  final String paymentMode;
  final int bookingPin; // --- ADDED THIS FIELD ---
  final CustomerAddress? address;
  final ServiceProvider? provider;
  final CustomerDetails? customerDetails;
  final List<BookingService> services;

  BookingModel({
    required this.id,
    required this.bookingRef,
    required this.bookingDate,
    required this.bookingTime,
    required this.creationTime,
    required this.status,
    required this.paymentStatus,
    required this.paymentMode,
    required this.bookingPin, // --- ADDED TO CONSTRUCTOR ---
    this.address,
    this.provider,
    this.customerDetails,
    required this.services,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      bookingRef: json['bookingReferenceNumber']?.toString() ?? 'N/A',
      bookingDate: json['bookingDate']?.toString() ?? '',
      bookingTime: json['bookingTime']?.toString() ?? '',
      creationTime: json['creationTime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending', 
      paymentStatus: json['paymentStatus']?.toString() ?? 'UnPaid',
      paymentMode: json['paymentMode']?.toString() ?? 'N/A',
      
      // --- ADDED PARSING LOGIC ---
      bookingPin: (json['bookingPin'] as num?)?.toInt() ?? 0, 
      
      address: json['customerAddress'] != null 
          ? CustomerAddress.fromJson(json['customerAddress']) 
          : null,
      provider: json['serviceProvider'] != null 
          ? ServiceProvider.fromJson(json['serviceProvider']) 
          : null,
      customerDetails: json['customerDetails'] != null 
          ? CustomerDetails.fromJson(json['customerDetails']) 
          : null,
      
      services: (json['bookingService'] as List? ?? [])
          .map((e) => BookingService.fromJson(e))
          .toList(),
    );
  }

  // --- Getters for UI Compatibility ---
  double get totalAmount {
    if (services.isEmpty) return 0.0;
    return services.fold(0.0, (sum, item) => sum + item.price);
  }

  String get mainServiceName {
    if (services.isEmpty) return "Unknown Service";
    return services.first.serviceName;
  }

  String get customerName {
    if (customerDetails == null) return "Guest/Unknown";
    return "${customerDetails!.firstName} ${customerDetails!.lastName}";
  }

  String get customerPhone {
    return customerDetails?.mobileNo ?? "N/A";
  }
}

// --- Sub-Models ---

class CustomerDetails {
  final String firstName;
  final String lastName;
  final String mobileNo;

  CustomerDetails({required this.firstName, required this.lastName, required this.mobileNo});

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? '',
    );
  }
}

class CustomerAddress {
  final String city;
  final String addressLine1;

  CustomerAddress({required this.city, required this.addressLine1});

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      city: json['city']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? '',
    );
  }
}

class ServiceProvider {
  final String firstName;
  final String lastName;
  final String mobile;

  ServiceProvider({required this.firstName, required this.lastName, required this.mobile});

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobile: json['mobileNo']?.toString() ?? '',
    );
  }
}

class BookingService {
  final String serviceName;
  final double price;

  BookingService({required this.serviceName, required this.price});

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      serviceName: json['serviceIName']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}