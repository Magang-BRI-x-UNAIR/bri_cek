class ChecklistItem {
  final String id;
  final String question;
  final String standard;
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
  bool? skipped; // New field to mark skipped questions

  ChecklistItem({
    required this.id,
    required this.question,
    this.standard = 'Standar sesuai ketentuan yang berlaku',
    this.options = const ['Ya', 'Tidak'],
    this.isRequired = true,
    this.allowsNote = true,
    this.category = '',
    this.subcategory = '',
    this.uniformType = '',
    this.forHijab,
    this.answerValue,
    this.note,
    this.skipped = false,
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
      'skipped': skipped,
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
      skipped: map['skipped'],
    );
  }
}
