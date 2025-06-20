import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bri_cek/models/checklist_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get questions for a category
  Future<List<ChecklistItem>> getQuestionsForCategory(String category) async {
    try {
      // Get the subcollection of questions for the category
      final QuerySnapshot snapshot =
          await _firestore
              .collection('categories')
              .doc(category.toLowerCase())
              .collection('questions')
              .orderBy('id')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChecklistItem(
          id: doc.id,
          question: data['text'] ?? '',
          category: category,
          // Add other properties as needed
        );
      }).toList();
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  // Add a question to a category
  Future<void> addQuestion(String category, String questionText) async {
    try {
      // Get the last question ID to determine the next one
      final QuerySnapshot snapshot =
          await _firestore
              .collection('categories')
              .doc(category.toLowerCase())
              .collection('questions')
              .orderBy('id', descending: true)
              .limit(1)
              .get();

      int nextId = 1; // Default if no questions exist
      if (snapshot.docs.isNotEmpty) {
        final lastId =
            (snapshot.docs.first.data() as Map<String, dynamic>)['id'] ?? 0;
        nextId = lastId + 1;
      }

      // Add the new question
      await _firestore
          .collection('categories')
          .doc(category.toLowerCase())
          .collection('questions')
          .add({
            'text': questionText,
            'id': nextId,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding question: $e');
      throw e;
    }
  }

  // Edit a question
  Future<void> editQuestion(
    String category,
    String questionId,
    String newText,
  ) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.toLowerCase())
          .collection('questions')
          .doc(questionId)
          .update({'text': newText, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error editing question: $e');
      throw e;
    }
  }

  // Delete a question
  Future<void> deleteQuestion(String category, String questionId) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.toLowerCase())
          .collection('questions')
          .doc(questionId)
          .delete();
    } catch (e) {
      print('Error deleting question: $e');
      throw e;
    }
  }
}
