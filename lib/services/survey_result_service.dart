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

        // Preserve or update userName if missing
        String userName = existingData['userName'] ?? '';
        if (userName.isEmpty) {
          try {
            final userDoc =
                await _firestore.collection('users').doc(user.uid).get();
            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              userName = userData['fullName'] ?? '';
            }
          } catch (e) {
            print('Error retrieving user name: $e');
          }
        }

        surveyData = {
          'categories': existingCategories,
          'statistics': combinedStats,
          'categoryStatistics': categoryStatistics,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
          'sessionId': sessionId, // Update session ID yang terakhir
          'isActive': true, // Pastikan isActive tetap true
          'userName': userName, // Ensure userName is included
        };
      } else {
        // Survey baru
        // Get user's full name
        String userName = '';
        try {
          final userDoc =
              await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            userName = userData['fullName'] ?? '';
          }
        } catch (e) {
          print('Error retrieving user name: $e');
        }

        surveyData = {
          'id': surveyResultId,
          'userId': user.uid,
          'userEmail': user.email ?? '',
          'userName': userName, // Add user's full name
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
      print(
        'Getting answers for surveyId: $surveyResultId, category: $category',
      );

      // Get all answers first, then filter by category client-side to avoid needing a composite index
      final snapshot =
          await _firestore
              .collection('survey_results')
              .doc(surveyResultId)
              .collection('answers')
              .get();

      print('Found ${snapshot.docs.length} total answers');

      // Process all docs once to avoid multiple iterations
      final allAnswersData =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      // Print all unique categories for debugging
      final allCategories =
          allAnswersData
              .map((doc) => doc['category']?.toString() ?? 'null')
              .toSet()
              .toList();
      print('Available categories in answers: $allCategories');

      // Normalize the search category
      final normalizedSearchCategory = _normalizeCategory(category);
      print('Normalized search category: "$normalizedSearchCategory"');

      // Enhanced matching algorithm with normalization
      List<Map<String, dynamic>> results = [];

      // 1. First try exact match
      results =
          allAnswersData.where((data) => data['category'] == category).toList();

      // 2. If no results, try normalized match
      if (results.isEmpty) {
        print('No exact matches, trying normalized match');
        results =
            allAnswersData
                .where(
                  (data) =>
                      data['category'] != null &&
                      _normalizeCategory(data['category'].toString()) ==
                          normalizedSearchCategory,
                )
                .toList();
      }

      // 3. If still no results, try substring match (for "Satpam" specifically)
      if (results.isEmpty &&
          (normalizedSearchCategory == 'satpam' ||
              category.toLowerCase().contains('satpam'))) {
        print('No normalized matches, trying substring match for Satpam');
        results =
            allAnswersData
                .where(
                  (data) =>
                      data['category'] != null &&
                      (data['category'].toString().toLowerCase().contains(
                            'satpam',
                          ) ||
                          (data['id'] != null &&
                              data['id'].toString().toLowerCase().contains(
                                'satpam',
                              ))),
                )
                .toList();
      }

      // 4. Special handling for specific categories with known variations
      if (results.isEmpty) {
        print('Trying special handling for common variations');
        Map<String, List<String>> knownVariations = {
          'satpam': ['satpam', 'security', 'sekuriti', 'scurity', 'keamanan'],
          'pramuniaga': [
            'pramuniaga',
            'penjaga toko',
            'spg',
            'sales',
            'sales promotion',
          ],
          'cs': ['cs', 'customer service', 'pelayanan', 'layanan'],
          'teller': ['teller', 'kasir'],
        };

        // Check if our category might match any of the known variations
        for (var key in knownVariations.keys) {
          if (knownVariations[key]!.any(
            (v) =>
                normalizedSearchCategory.contains(v) ||
                v.contains(normalizedSearchCategory),
          )) {
            // Try all variations of this category
            for (var variation in knownVariations[key]!) {
              final tempResults =
                  allAnswersData
                      .where(
                        (data) =>
                            data['category'] != null &&
                            data['category'].toString().toLowerCase().contains(
                              variation,
                            ),
                      )
                      .toList();

              if (tempResults.isNotEmpty) {
                results = tempResults;
                print('Found matches using variation: "$variation"');
                break;
              }
            }

            if (results.isNotEmpty) break;
          }
        }
      }

      // 5. If still no results, try partial match with any category
      if (results.isEmpty) {
        print('No specific matches found, trying partial match with any word');
        final searchWords = normalizedSearchCategory.split(' ');

        for (var word in searchWords) {
          if (word.length > 2) {
            // Only use words with 3+ characters
            results =
                allAnswersData
                    .where(
                      (data) =>
                          data['category'] != null &&
                          data['category'].toString().toLowerCase().contains(
                            word,
                          ),
                    )
                    .toList();

            if (results.isNotEmpty) {
              print('Found matches containing word: "$word"');
              break;
            }
          }
        }
      }

      print('Found ${results.length} answers for category "$category"');

      // Debug printout of all matched categories
      if (results.isNotEmpty) {
        final matchedCategories =
            results
                .map((doc) => doc['category']?.toString() ?? 'null')
                .toSet()
                .toList();
        print('Matched categories: $matchedCategories');
      }

      // Sort by order
      results.sort((a, b) {
        final orderA = a['order'] as num? ?? 0;
        final orderB = b['order'] as num? ?? 0;
        return orderA.compareTo(orderB);
      });

      return results;
    } catch (e) {
      print('Error in getSurveyAnswersByCategory: $e');
      throw Exception('Gagal mengambil detail jawaban: $e');
    }
  }

  /// Helper method to normalize category names for better matching
  String _normalizeCategory(String? category) {
    if (category == null) return '';

    // Convert to lowercase
    String normalized = category.toLowerCase();

    // Remove common punctuation and trim whitespace
    normalized =
        normalized
            .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
            .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with one
            .trim(); // Trim whitespace

    return normalized;
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

  /// Mendapatkan status kategori untuk tanggal dan bank tertentu
  Future<Map<String, String>> getCategoryStatusForDate({
    required String bankName,
    required DateTime selectedDate,
    required List<String> categories,
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

      print('Checking category status for survey ID: $surveyResultId');

      final doc =
          await _firestore
              .collection('survey_results')
              .doc(surveyResultId)
              .get();

      Map<String, String> categoryStatus = {};

      // Initialize all categories as 'default' (not started)
      for (String category in categories) {
        categoryStatus[category] = 'default';
      }

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final completedCategories = List<String>.from(data['categories'] ?? []);
        final categoryStatistics =
            data['categoryStatistics'] as Map<String, dynamic>? ?? {};

        print('Found completed categories: $completedCategories');
        print('Category statistics: $categoryStatistics');

        for (String category in categories) {
          if (completedCategories.contains(category)) {
            // Category has been attempted, check if it's complete
            final categoryStats =
                categoryStatistics[category] as Map<String, dynamic>?;

            if (categoryStats != null) {
              final totalQuestions =
                  categoryStats['totalQuestions'] as int? ?? 0;
              final answeredQuestions =
                  categoryStats['answeredQuestions'] as int? ?? 0;
              final skippedQuestions =
                  categoryStats['skippedQuestions'] as int? ?? 0;

              print(
                'Category $category: total=$totalQuestions, answered=$answeredQuestions, skipped=$skippedQuestions',
              );

              // Check if survey is complete (all questions answered or skipped)
              if (totalQuestions > 0 &&
                  (answeredQuestions + skippedQuestions) >= totalQuestions) {
                categoryStatus[category] = 'completed'; // Green
              } else if (answeredQuestions > 0) {
                categoryStatus[category] = 'partial'; // Yellow
              } else {
                categoryStatus[category] = 'default'; // Default color
              }
            } else {
              // Category exists but no stats, means partial
              categoryStatus[category] = 'partial';
            }
          }
        }
      }

      print('Final category status: $categoryStatus');
      return categoryStatus;
    } catch (e) {
      print('Error getting category status: $e');
      // Return default status for all categories on error
      Map<String, String> defaultStatus = {};
      for (String category in categories) {
        defaultStatus[category] = 'default';
      }
      return defaultStatus;
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
