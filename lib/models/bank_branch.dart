class BankBranch {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final bool isLocalImage;
  final String city;
  final String? phoneNumber;
  final String? operationalHours;

  BankBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.isLocalImage = false,
    required this.city,
    this.phoneNumber,
    this.operationalHours,
  });

  factory BankBranch.fromJson(Map<String, dynamic> json) {
    return BankBranch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      imageUrl: json['imageUrl'],
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      operationalHours: json['operationalHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'city': city,
      'phoneNumber': phoneNumber,
      'operationalHours': operationalHours,
    };
  }
}
