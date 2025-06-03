import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_category.dart';

class AssessmentCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'assessment_categories';

  // Get all active categories
  Future<List<AssessmentCategory>> getActiveCategories() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('order')
              .get();

      return querySnapshot.docs
          .map((doc) => AssessmentCategory.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Add new category
  Future<String> addCategory(AssessmentCategory category) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(category.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  // Update category
  Future<void> updateCategory(String id, AssessmentCategory category) async {
    try {
      await _firestore.collection(_collection).doc(id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category (soft delete)
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Get category by ID
  Future<AssessmentCategory?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (doc.exists && doc.data() != null) {
        return AssessmentCategory.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }
}
