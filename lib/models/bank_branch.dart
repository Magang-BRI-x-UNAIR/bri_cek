class BankBranch {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final bool isLocalImage;
  final String city;
  final String? phoneNumber;
  final String? operationalHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.isLocalImage = false,
    required this.city,
    this.phoneNumber,
    this.operationalHours,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Keep your existing methods
  factory BankBranch.fromJson(Map<String, dynamic> json) {
    return BankBranch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      imageUrl: json['imageUrl'],
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      operationalHours: json['operationalHours'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // Add Firestore conversion
  factory BankBranch.fromMap(Map<String, dynamic> map, String documentId) {
    return BankBranch(
      id: documentId,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isLocalImage: map['isLocalImage'] ?? false,
      city: map['city'] ?? '',
      phoneNumber: map['phoneNumber'],
      operationalHours: map['operationalHours'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'isLocalImage': isLocalImage,
      'city': city,
      'phoneNumber': phoneNumber,
      'operationalHours': operationalHours,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Keep existing toJson for backward compatibility
  Map<String, dynamic> toJson() => toMap();
}
