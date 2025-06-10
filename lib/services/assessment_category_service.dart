import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_category.dart';

class AssessmentCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AssessmentCategory>> getActiveCategories() async {
    try {
      final snapshot =
          await _firestore
              .collection('assessment_categories')
              .where('isActive', isEqualTo: true)
              .orderBy('order')
              .get();

      return snapshot.docs
          .map((doc) => AssessmentCategory.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<AssessmentCategory?> getCategoryById(String id) async {
    try {
      final doc =
          await _firestore.collection('assessment_categories').doc(id).get();

      if (doc.exists) {
        return AssessmentCategory.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }
}
