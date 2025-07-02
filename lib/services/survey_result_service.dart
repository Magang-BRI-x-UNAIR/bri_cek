import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bri_cek/models/checklist_item.dart';

class SurveyResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Menyimpan hasil survey ke database
  /// Semua jawaban untuk tanggal yang sama akan digabungkan dalam satu dokumen survey
  Future<String> saveSurveyResult({
    required String selectedBank,
    required String selectedCategory,
    required DateTime selectedDate,
    required String bankBranchId,
    required String sessionId,
    required List<ChecklistItem> checklistItems,
    required double score,
    required int skippedCount,
    Map<String, dynamic>? employeeData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak login');
      }

      print(
        'Saving survey for bank: "$selectedBank", category: "$selectedCategory", date: $selectedDate',
      );

      // Buat ID yang konsisten berdasarkan user, bank, dan tanggal
      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final surveyResultId =
          '${user.uid}_${selectedBank.replaceAll(' ', '_')}_$dateStr';

      print('Survey ID: $surveyResultId');

      // Cek apakah survey untuk tanggal ini sudah ada
      final existingDoc =
          await _firestore
              .collection('survey_results')
              .doc(surveyResultId)
              .get();

      // Hitung statistik untuk kategori ini
      final totalQuestions = checklistItems.length;
      final answeredQuestions =
          checklistItems.where((item) => item.answerValue != null).length;
      final passedQuestions =
          checklistItems.where((item) => item.answerValue == true).length;
      final failedQuestions =
          checklistItems.where((item) => item.answerValue == false).length;

      final categoryStats = {
        'totalQuestions': totalQuestions,
        'answeredQuestions': answeredQuestions,
        'skippedQuestions': skippedCount,
        'passedQuestions': passedQuestions,
        'failedQuestions': failedQuestions,
        'score': score,
      };

      Map<String, dynamic> surveyData;
      Map<String, dynamic> existingStats = {};
      List<String> existingCategories = [];

      if (existingDoc.exists) {
        // Survey sudah ada, update dengan kategori baru
        final existingData = existingDoc.data() as Map<String, dynamic>;
        existingStats =
            existingData['statistics'] as Map<String, dynamic>? ?? {};
        existingCategories = List<String>.from(
          existingData['categories'] ?? [],
        );

        // Jika kategori belum ada, tambahkan
        if (!existingCategories.contains(selectedCategory)) {
          existingCategories.add(selectedCategory);
        }

        // Gabungkan statistik
        final combinedStats = {
          'totalQuestions':
              (existingStats['totalQuestions'] ?? 0) + totalQuestions,
          'answeredQuestions':
              (existingStats['answeredQuestions'] ?? 0) + answeredQuestions,
          'skippedQuestions':
              (existingStats['skippedQuestions'] ?? 0) + skippedCount,
          'passedQuestions':
              (existingStats['passedQuestions'] ?? 0) + passedQuestions,
          'failedQuestions':
              (existingStats['failedQuestions'] ?? 0) + failedQuestions,
        };

        // Hitung ulang skor keseluruhan
        final totalAnswered = combinedStats['answeredQuestions']!;
        final totalPassed = combinedStats['passedQuestions']!;
        final overallScore =
            totalAnswered > 0 ? (totalPassed / totalAnswered * 100) : 0.0;
        combinedStats['score'] = overallScore;

        // Statistik per kategori
        final categoryStatistics =
            existingData['categoryStatistics'] as Map<String, dynamic>? ?? {};
        categoryStatistics[selectedCategory] = categoryStats;

        surveyData = {
          'categories': existingCategories,
          'statistics': combinedStats,
          'categoryStatistics': categoryStatistics,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
          'sessionId': sessionId, // Update session ID yang terakhir
          'isActive': true, // Pastikan isActive tetap true
        };
      } else {
        // Survey baru
        surveyData = {
          'id': surveyResultId,
          'userId': user.uid,
          'userEmail': user.email ?? '',
          'selectedBank': selectedBank,
          'selectedDate': Timestamp.fromDate(selectedDate),
          'bankBranchId': bankBranchId,
          'sessionId': sessionId,
          'employeeData': employeeData ?? {},
          'categories': [selectedCategory],
          'statistics': categoryStats,
          'categoryStatistics': {selectedCategory: categoryStats},
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };
      }

      // Simpan/update data utama survey
      await _firestore
          .collection('survey_results')
          .doc(surveyResultId)
          .set(surveyData, SetOptions(merge: true));

      // Simpan detail jawaban untuk kategori ini
      final batch = _firestore.batch();

      for (int i = 0; i < checklistItems.length; i++) {
        final item = checklistItems[i];
        final answerData = {
          'surveyResultId': surveyResultId,
          'questionId': item.id,
          'question': item.question,
          'category': item.category,
          'subcategory': item.subcategory,
          'gender': item.gender,
          'section': item.section,
          'uniformType': item.uniformType,
          'forHijab': item.forHijab,
          'order': item.order,
          'answerValue': item.answerValue,
          'note': item.note,
          'skipped': item.skipped ?? false,
          'answeredAt': FieldValue.serverTimestamp(),
        };

        // Gunakan ID yang unik untuk setiap jawaban berdasarkan kategori dan order
        final answerId = '${selectedCategory}_${item.order}';
        final answerDoc = _firestore
            .collection('survey_results')
            .doc(surveyResultId)
            .collection('answers')
            .doc(answerId);

        batch.set(answerDoc, answerData);
      }

      // Commit batch untuk menyimpan semua jawaban
      await batch.commit();

      print('Survey saved successfully with ID: $surveyResultId');
      print('Bank name in saved data: "$selectedBank"');

      return surveyResultId;
    } catch (e) {
      throw Exception('Gagal menyimpan hasil survey: $e');
    }
  }

  /// Mendapatkan hasil survey berdasarkan user
  Future<List<Map<String, dynamic>>> getUserSurveyResults({
    String? userId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final user = _auth.currentUser;
      final targetUserId = userId ?? user?.uid;

      if (targetUserId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      print('Getting survey results for user: $targetUserId');

      // Dapatkan semua hasil survey untuk user ini
      // Kita akan filter lebih lanjut di client side untuk lebih fleksibel
      Query query = _firestore
          .collection('survey_results')
          .where('userId', isEqualTo: targetUserId);

      // Limit hasil jika ada
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      print('Found ${snapshot.docs.length} raw survey results');

      final results =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

      // Filter di sisi client untuk lebih fleksibel
      var filteredResults =
          results.where((result) {
            // Filter isActive
            final isActive = result['isActive'];
            if (isActive != null && isActive == false) {
              return false;
            }

            // Filter kategori jika ada
            if (category != null) {
              final categories = result['categories'];
              if (categories == null) return false;

              try {
                final categoryList = List<String>.from(categories);
                if (!categoryList.contains(category)) return false;
              } catch (e) {
                print('Error parsing categories: $e');
                return false;
              }
            }

            // Filter berdasarkan tanggal
            if (startDate != null || endDate != null) {
              final selectedDate = result['selectedDate'];
              if (selectedDate == null) return false;

              DateTime date;
              try {
                date = selectedDate.toDate();
              } catch (e) {
                print('Error converting date: $e');
                return false;
              }

              if (startDate != null && date.isBefore(startDate)) return false;
              if (endDate != null && date.isAfter(endDate)) return false;
            }

            return true;
          }).toList();

      print('After filtering: ${filteredResults.length} survey results');

      // Filter isActive di sisi client dan sort by selectedDate descending
      final activeResults =
          filteredResults.where((result) {
            final isActive = result['isActive'];
            return isActive == null || isActive == true;
          }).toList();

      // Sort by selectedDate descending
      activeResults.sort((a, b) {
        final dateA = a['selectedDate'] as Timestamp?;
        final dateB = b['selectedDate'] as Timestamp?;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

      return activeResults;
    } catch (e) {
      throw Exception('Gagal mengambil hasil survey: $e');
    }
  }

  /// Mendapatkan survey result untuk tanggal dan bank tertentu
  Future<Map<String, dynamic>?> getSurveyByDate({
    required String bankName,
    required DateTime selectedDate,
    String? userId,
  }) async {
    try {
      final user = _auth.currentUser;
      final targetUserId = userId ?? user?.uid;

      if (targetUserId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      // Buat ID yang konsisten
      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final surveyResultId =
          '${targetUserId}_${bankName.replaceAll(' ', '_')}_$dateStr';

      final doc =
          await _firestore
              .collection('survey_results')
              .doc(surveyResultId)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }

      return null;
    } catch (e) {
      throw Exception('Gagal mengambil survey: $e');
    }
  }

  /// Mendapatkan detail jawaban untuk survey tertentu
  Future<List<Map<String, dynamic>>> getSurveyAnswers(
    String surveyResultId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('survey_results')
              .doc(surveyResultId)
              .collection('answers')
              .orderBy('order')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil detail jawaban: $e');
    }
  }

  /// Mendapatkan detail jawaban untuk survey tertentu berdasarkan kategori
  Future<List<Map<String, dynamic>>> getSurveyAnswersByCategory(
    String surveyResultId,
    String category,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('survey_results')
              .doc(surveyResultId)
              .collection('answers')
              .where('category', isEqualTo: category)
              .orderBy('order')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil detail jawaban: $e');
    }
  }

  /// Mendapatkan statistik survey untuk dashboard
  Future<Map<String, dynamic>> getSurveyStatistics({
    String? userId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      final targetUserId = userId ?? user?.uid;

      if (targetUserId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      Query query = _firestore
          .collection('survey_results')
          .where('userId', isEqualTo: targetUserId)
          .where('isActive', isEqualTo: true);

      // Filter berdasarkan kategori jika ada
      if (category != null) {
        query = query.where('categories', arrayContains: category);
      }

      // Filter berdasarkan tanggal jika ada
      if (startDate != null) {
        query = query.where(
          'selectedDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'selectedDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalSurveys': 0,
          'averageScore': 0.0,
          'totalQuestions': 0,
          'totalAnswered': 0,
          'totalSkipped': 0,
          'totalPassed': 0,
          'totalFailed': 0,
        };
      }

      // Hitung statistik
      int totalSurveys = snapshot.docs.length;
      double totalScore = 0;
      int totalQuestions = 0;
      int totalAnswered = 0;
      int totalSkipped = 0;
      int totalPassed = 0;
      int totalFailed = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final stats = data['statistics'] as Map<String, dynamic>? ?? {};

        totalScore += (stats['score'] as num?)?.toDouble() ?? 0;
        totalQuestions += (stats['totalQuestions'] as num?)?.toInt() ?? 0;
        totalAnswered += (stats['answeredQuestions'] as num?)?.toInt() ?? 0;
        totalSkipped += (stats['skippedQuestions'] as num?)?.toInt() ?? 0;
        totalPassed += (stats['passedQuestions'] as num?)?.toInt() ?? 0;
        totalFailed += (stats['failedQuestions'] as num?)?.toInt() ?? 0;
      }

      return {
        'totalSurveys': totalSurveys,
        'averageScore': totalScore / totalSurveys,
        'totalQuestions': totalQuestions,
        'totalAnswered': totalAnswered,
        'totalSkipped': totalSkipped,
        'totalPassed': totalPassed,
        'totalFailed': totalFailed,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik survey: $e');
    }
  }

  /// Menghapus hasil survey (soft delete)
  Future<void> deleteSurveyResult(String surveyResultId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak login');
      }

      await _firestore.collection('survey_results').doc(surveyResultId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': user.uid,
      });
    } catch (e) {
      throw Exception('Gagal menghapus hasil survey: $e');
    }
  }
}
