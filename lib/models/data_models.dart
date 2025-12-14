class LoginResponseModel {
  final String message;
  final String token;

  LoginResponseModel({required this.message, required this.token});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Handling structure: { "result": { "message": "...", "result": "TOKEN" } }
    final innerResult = json['result']; 
    
    return LoginResponseModel(
      message: innerResult['message'] ?? 'Success',
      token: innerResult['result'] ?? '', // This grabs the actual token string
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? imgLink;
  final bool isActive;

  CategoryModel({required this.id, required this.name, this.imgLink, this.isActive = true});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      imgLink: json['imgLink'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class ServiceCategoryModel {
  final String id;
  final String name;
  final String? imgLink;
  final String categoryId;

  ServiceCategoryModel({required this.id, required this.name, this.imgLink, required this.categoryId});

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      imgLink: json['imgLink'],
      categoryId: json['categoryId']?.toString() ?? '',
    );
  }
}

class ServiceModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final int duration;
  final String? imgLink;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.duration,
    this.imgLink,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Service',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      description: json['description'],
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      imgLink: json['imgLink'],
    );
  }
}