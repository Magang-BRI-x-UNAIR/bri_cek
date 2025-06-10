import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_session.dart';
import '../models/question_item.dart';

class AssessmentSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSession({
    required String userId,
    required String bankBranchId,
    required DateTime sessionDate,
    required String assessmentCategoryId,
    Map<String, dynamic>? employeeData,
  }) async {
    try {
      final sessionRef = _firestore.collection('assessment_sessions').doc();

      final session = AssessmentSession(
        id: sessionRef.id,
        userId: userId,
        bankBranchId: bankBranchId,
        sessionDate: sessionDate,
        completedCategories: [],
        isSessionCompleted: false,
        categoryScores: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await sessionRef.set(session.toMap());

      // Create assessment record if employee data provided
      if (employeeData != null) {
        await _createAssessmentRecord(
          sessionRef.id,
          assessmentCategoryId,
          employeeData,
        );
      }

      return sessionRef.id;
    } catch (e) {
      print('Error creating session: $e');
      rethrow;
    }
  }

  Future<void> _createAssessmentRecord(
    String sessionId,
    String assessmentCategoryId,
    Map<String, dynamic> employeeData,
  ) async {
    try {
      final assessmentRef = _firestore
          .collection('assessment_sessions')
          .doc(sessionId)
          .collection('assessments')
          .doc(assessmentCategoryId);

      await assessmentRef.set({
        'assessmentCategoryId': assessmentCategoryId,
        'employeeData': employeeData,
        'answers': [],
        'score': null,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating assessment record: $e');
      rethrow;
    }
  }

  Future<void> saveAnswers({
    required String sessionId,
    required String assessmentCategoryId,
    required List<Question> questions,
  }) async {
    try {
      final answers =
          questions
              .map(
                (q) => {
                  'questionId': q.id,
                  'question': q.question,
                  'answerValue': q.answerValue,
                  'note': q.note,
                  'skipped': q.skipped ?? false,
                },
              )
              .toList();

      // Calculate score
      final answeredQuestions =
          questions.where((q) => q.answerValue != null).length;
      final positiveAnswers =
          questions.where((q) => q.answerValue == true).length;
      final score =
          answeredQuestions > 0
              ? (positiveAnswers / answeredQuestions) * 100
              : 0.0;

      await _firestore
          .collection('assessment_sessions')
          .doc(sessionId)
          .collection('assessments')
          .doc(assessmentCategoryId)
          .update({
            'answers': answers,
            'score': score,
            'isCompleted': true,
            'completedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update session with completed category
      await _updateSessionProgress(sessionId, assessmentCategoryId, score);
    } catch (e) {
      print('Error saving answers: $e');
      rethrow;
    }
  }

  Future<void> _updateSessionProgress(
    String sessionId,
    String assessmentCategoryId,
    double score,
  ) async {
    try {
      final sessionRef = _firestore
          .collection('assessment_sessions')
          .doc(sessionId);

      await _firestore.runTransaction((transaction) async {
        final sessionDoc = await transaction.get(sessionRef);

        if (sessionDoc.exists) {
          final data = sessionDoc.data()!;
          final completedCategories = List<String>.from(
            data['completedCategories'] ?? [],
          );
          final categoryScores = Map<String, double>.from(
            data['categoryScores'] ?? {},
          );

          if (!completedCategories.contains(assessmentCategoryId)) {
            completedCategories.add(assessmentCategoryId);
          }
          categoryScores[assessmentCategoryId] = score;

          transaction.update(sessionRef, {
            'completedCategories': completedCategories,
            'categoryScores': categoryScores,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error updating session progress: $e');
      rethrow;
    }
  }
}
