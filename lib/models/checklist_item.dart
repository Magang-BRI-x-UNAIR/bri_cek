import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItem {
  final String id;
  final String question;
  final List<String> options;
  final bool isRequired;
  final bool allowsNote;

  // Hierarchical category structure
  final String category;
  final String subcategory;
  final String? gender;
  final String? section;
  final String? uniformType;
  final bool? forHijab;

  // User answers
  bool? answerValue;
  String? note;
  bool? skipped;

  // Order for displaying questions
  final int order;

  // Admin fields
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  ChecklistItem({
    required this.id,
    required this.question,
    this.options = const ['Ya', 'Tidak'],
    this.isRequired = true,
    this.allowsNote = true,
    this.category = '',
    this.subcategory = '',
    this.gender,
    this.section,
    this.uniformType,
    this.forHijab,
    this.answerValue,
    this.note,
    this.skipped = false,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': question,
      'options': options,
      'isRequired': isRequired,
      'allowsNote': allowsNote,
      'category': category,
      'subcategory': subcategory,
      'gender': gender,
      'section': section,
      'uniformType': uniformType,
      'forHijab': forHijab,
      'order': order,
      'isActive': isActive,
      'createdAt':
          createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  ChecklistItem copyWith({bool? answerValue, String? note, bool? skipped}) {
    return ChecklistItem(
      id: this.id,
      question: this.question,
      options: this.options,
      isRequired: this.isRequired,
      allowsNote: this.allowsNote,
      category: this.category,
      subcategory: this.subcategory,
      gender: this.gender,
      section: this.section,
      uniformType: this.uniformType,
      forHijab: this.forHijab,
      answerValue: answerValue ?? this.answerValue,
      note: note ?? this.note,
      skipped: skipped ?? this.skipped,
      order: this.order,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      isActive: this.isActive,
    );
  }

  factory ChecklistItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ChecklistItem(
      id: doc.id,
      question: data['text'] ?? '',
      options:
          data['options'] != null
              ? List<String>.from(data['options'])
              : ['Ya', 'Tidak'],
      isRequired: data['isRequired'] ?? true,
      allowsNote: data['allowsNote'] ?? true,
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      gender: data['gender'],
      section: data['section'],
      uniformType: data['uniformType'],
      forHijab: data['forHijab'],
      order: data['order'] ?? 0,
      createdAt:
          data['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
              : null,
      isActive: data['isActive'] ?? true,
    );
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map, String docId) {
    return ChecklistItem(
      id: docId,
      question: map['text'] ?? '',
      options:
          map['options'] != null
              ? List<String>.from(map['options'])
              : ['Ya', 'Tidak'],
      isRequired: map['isRequired'] ?? true,
      allowsNote: map['allowsNote'] ?? true,
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      gender: map['gender'],
      section: map['section'],
      uniformType: map['uniformType'],
      forHijab: map['forHijab'],
      order: map['order'] ?? 0,
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : null,
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
              : null,
      isActive: map['isActive'] ?? true,
    );
  }
}
