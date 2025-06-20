import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/assessment_session.dart';

class AssessmentSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Membuat assessment session baru saat user memilih bank dan tanggal
  Future<String> createAssessmentSession({
    required String bankBranchId,
    required DateTime sessionDate,
  }) async {
    try {
      // Pastikan user sudah login
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User belum login');
      }

      // Buat dokumen baru
      final sessionRef = await _firestore
          .collection('assessment_sessions')
          .add({
            'userId': user.uid,
            'bankBranchId': bankBranchId,
            'sessionDate': Timestamp.fromDate(
              DateTime(sessionDate.year, sessionDate.month, sessionDate.day),
            ),
            'completedCategories': [],
            'isSessionCompleted': false,
            'categoryScores': {},
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return sessionRef.id;
    } catch (e) {
      print('Error creating assessment session: $e');
      throw Exception('Gagal membuat sesi penilaian: $e');
    }
  }

  // Update assessment session dengan data kategori yang sudah selesai
  Future<void> updateAssessmentSession({
    required String sessionId,
    required String categoryId,
    required double score,
    required List<Map<String, dynamic>> answers,
    Map<String, dynamic>? employeeData,
  }) async {
    try {
      final sessionDoc = _firestore
          .collection('assessment_sessions')
          .doc(sessionId);

      // Get current session data
      final sessionSnapshot = await sessionDoc.get();
      if (!sessionSnapshot.exists) {
        throw Exception('Sesi penilaian tidak ditemukan');
      }

      final sessionData = sessionSnapshot.data()!;
      List<String> completedCategories = List<String>.from(
        sessionData['completedCategories'] ?? [],
      );
      Map<String, dynamic> categoryScores = Map<String, dynamic>.from(
        sessionData['categoryScores'] ?? {},
      );

      // Update completed categories
      if (!completedCategories.contains(categoryId)) {
        completedCategories.add(categoryId);
      }

      // Update category score
      categoryScores[categoryId] = score;

      // Save answers in a subcollection
      final answersRef = sessionDoc
          .collection('category_answers')
          .doc(categoryId);
      await answersRef.set({
        'answers': answers,
        'score': score,
        'employeeData': employeeData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update session document
      await sessionDoc.update({
        'completedCategories': completedCategories,
        'categoryScores': categoryScores,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating assessment session: $e');
      throw Exception('Gagal memperbarui sesi penilaian: $e');
    }
  }

  // Cek apakah sudah ada assessment session untuk bank dan tanggal tertentu
  Future<bool> hasExistingSession(
    String bankBranchId,
    DateTime sessionDate,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User belum login');
      }

      final existingSessions =
          await _firestore
              .collection('assessment_sessions')
              .where('userId', isEqualTo: user.uid)
              .where('bankBranchId', isEqualTo: bankBranchId)
              .where(
                'sessionDate',
                isEqualTo: Timestamp.fromDate(
                  DateTime(
                    sessionDate.year,
                    sessionDate.month,
                    sessionDate.day,
                  ),
                ),
              )
              .get();

      return existingSessions.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing session: $e');
      return false;
    }
  }
}
