class AssessmentCategory {
  final String id;
  final String name;
  final String icon;
  final bool isPersonBased; // apakah perlu data karyawan
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssessmentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.isPersonBased,
    required this.order,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore
  factory AssessmentCategory.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AssessmentCategory(
      id: documentId,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'check_box',
      isPersonBased: map['isPersonBased'] ?? false,
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'isPersonBased': isPersonBased,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  AssessmentCategory copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isPersonBased,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssessmentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isPersonBased: isPersonBased ?? this.isPersonBased,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
