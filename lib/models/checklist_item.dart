class ChecklistItem {
  final String id;
  final String question;
  final List<String> options;
  final bool isRequired;
  final bool allowsNote;
  final String category; // Main category (e.g., "Grooming")
  final String subcategory; // Subcategory (e.g., "Rambut", "Jilbab")
  final String
  uniformType; // Type of uniform if applicable (e.g., "Korporat", "Batik", "Casual")
  final bool?
  forHijab; // true for hijab-specific items, false for non-hijab, null for both/not applicable

  // User answers
  bool? answerValue;
  String? note;

  ChecklistItem({
    required this.id,
    required this.question,
    this.options = const ['Ya', 'Tidak'],
    this.isRequired = true,
    this.allowsNote = true,
    this.category = '',
    this.subcategory = '',
    this.uniformType = '',
    this.forHijab,
    this.answerValue,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'isRequired': isRequired,
      'allowsNote': allowsNote,
      'category': category,
      'subcategory': subcategory,
      'uniformType': uniformType,
      'forHijab': forHijab,
      'answerValue': answerValue,
      'note': note,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'],
      question: map['question'],
      options: List<String>.from(map['options']),
      isRequired: map['isRequired'],
      allowsNote: map['allowsNote'],
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      uniformType: map['uniformType'] ?? '',
      forHijab: map['forHijab'],
      answerValue: map['answerValue'],
      note: map['note'],
    );
  }
}
