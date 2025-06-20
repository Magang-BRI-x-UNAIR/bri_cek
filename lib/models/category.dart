class Category {
  final String id;
  final String name;
  final int order;

  Category({required this.id, required this.name, this.order = 0});

  Map<String, dynamic> toMap() {
    return {'name': name, 'order': order};
  }

  factory Category.fromMap(Map<String, dynamic> map, String docId) {
    return Category(
      id: docId,
      name: map['name'] ?? docId,
      order: map['order'] ?? 0,
    );
  }
}
