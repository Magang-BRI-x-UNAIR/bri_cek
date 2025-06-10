import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_item.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Question>> getQuestionsForCategory(
    String assessmentCategoryId, {
    String? gender,
    String? uniformType,
    bool? hasHijab,
  }) async {
    try {
      Query query = _firestore
          .collection('questions')
          .where('assessmentCategoryId', isEqualTo: assessmentCategoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('order');

      final snapshot = await query.get();
      List<Question> questions =
          snapshot.docs
              .map(
                (doc) => Question.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      // Filter questions based on conditions
      return questions.where((question) {
        // Check gender condition
        if (question.conditions?.gender != null &&
            question.conditions!.gender != gender) {
          return false;
        }

        // Check uniform type condition
        if (question.conditions?.uniformType != null &&
            question.conditions!.uniformType != uniformType) {
          return false;
        }

        // Check hijab condition
        if (question.conditions?.forHijab != null &&
            question.conditions!.forHijab != hasHijab) {
          return false;
        }

        return true;
      }).toList();
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Future<Map<String, Map<String, List<Question>>>> getGroupedQuestions(
    String assessmentCategoryId, {
    String? gender,
    String? uniformType,
    bool? hasHijab,
  }) async {
    final questions = await getQuestionsForCategory(
      assessmentCategoryId,
      gender: gender,
      uniformType: uniformType,
      hasHijab: hasHijab,
    );

    Map<String, Map<String, List<Question>>> grouped = {};

    for (final question in questions) {
      final category = question.questionCategoryId ?? 'Uncategorized';
      final subcategory = question.questionSubcategoryId ?? 'General';

      if (!grouped.containsKey(category)) {
        grouped[category] = {};
      }

      if (!grouped[category]!.containsKey(subcategory)) {
        grouped[category]![subcategory] = [];
      }

      grouped[category]![subcategory]!.add(question);
    }

    return grouped;
  }
}
