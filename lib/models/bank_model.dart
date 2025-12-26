class BankModel {
  final String id;
  final String name;
  final String imgLink;
  final bool isActive;

  BankModel({
    required this.id,
    required this.name,
    required this.imgLink,
    required this.isActive,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imgLink: json['imgLink'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}