import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_session.dart';

class AssessmentSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'assessment_sessions';

  Future<String> createSession(AssessmentSession session) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(session.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  Future<List<AssessmentSession>> getUserSessions(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .orderBy('sessionDate', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => AssessmentSession.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user sessions: $e');
    }
  }

  Future<AssessmentSession?> getActiveSession(
    String userId,
    String bankId,
    DateTime date,
  ) async {
    try {
      // Check for session on the same date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('bankBranchId', isEqualTo: bankId)
              .where(
                'sessionDate',
                isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch,
              )
              .where('sessionDate', isLessThan: endOfDay.millisecondsSinceEpoch)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AssessmentSession.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get active session: $e');
    }
  }
}
