import 'package:bri_cek/models/checklist_item.dart';

class Question {
  final String id;
  final String question;
  final String assessmentCategoryId;
  final String questionCategoryId;
  final String? questionSubcategoryId;
  final QuestionConditions? conditions;
  final bool isRequired;
  final bool allowsNote;
  final int order;
  final bool isActive;

  // User answers (untuk sementara, nanti akan dipindah ke Answer model)
  bool? answerValue;
  String? note;
  bool? skipped;

  Question({
    required this.id,
    required this.question,
    required this.assessmentCategoryId,
    required this.questionCategoryId,
    this.questionSubcategoryId,
    this.conditions,
    this.isRequired = true,
    this.allowsNote = true,
    required this.order,
    this.isActive = true,
    this.answerValue,
    this.note,
    this.skipped = false,
  });

  // Convert from your existing ChecklistItem
  factory Question.fromChecklistItem(
    ChecklistItem item,
    String assessmentCategoryId,
  ) {
    return Question(
      id: item.id,
      question: item.question,
      assessmentCategoryId: assessmentCategoryId,
      questionCategoryId:
          item.category.isEmpty ? 'general' : item.category.toLowerCase(),
      questionSubcategoryId:
          item.subcategory.isEmpty ? null : item.subcategory.toLowerCase(),
      conditions: QuestionConditions(
        gender: item.gender, // No change needed here as it's already nullable
        uniformType:
            item.uniformType?.isEmpty == true ? null : item.uniformType,
        forHijab: item.forHijab,
      ),
      isRequired: item.isRequired,
      allowsNote: item.allowsNote,
      order: item.order, // Use item.order instead of hardcoded 0
      answerValue: item.answerValue,
      note: item.note,
      skipped: item.skipped,
    );
  }

  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    return Question(
      id: documentId,
      question: map['question'] ?? '',
      assessmentCategoryId: map['assessmentCategoryId'] ?? '',
      questionCategoryId: map['questionCategoryId'] ?? '',
      questionSubcategoryId: map['questionSubcategoryId'],
      conditions:
          map['conditions'] != null
              ? QuestionConditions.fromMap(map['conditions'])
              : null,
      isRequired: map['isRequired'] ?? true,
      allowsNote: map['allowsNote'] ?? true,
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'assessmentCategoryId': assessmentCategoryId,
      'questionCategoryId': questionCategoryId,
      'questionSubcategoryId': questionSubcategoryId,
      'conditions': conditions?.toMap(),
      'isRequired': isRequired,
      'allowsNote': allowsNote,
      'order': order,
      'isActive': isActive,
    };
  }
}

class QuestionConditions {
  final String? gender;
  final String? uniformType;
  final bool? forHijab;

  QuestionConditions({this.gender, this.uniformType, this.forHijab});

  factory QuestionConditions.fromMap(Map<String, dynamic> map) {
    return QuestionConditions(
      gender: map['gender'],
      uniformType: map['uniformType'],
      forHijab: map['forHijab'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'gender': gender, 'uniformType': uniformType, 'forHijab': forHijab};
  }
}
