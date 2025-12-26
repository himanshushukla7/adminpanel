class DocumentTypeModel {
  final String id;
  final String name;
  final bool isActive;

  DocumentTypeModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "Unknown Doc",
      isActive: json['isActive'] ?? false,
    );
  }
}