import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bank_branch.dart';

class BankBranchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bank_branches';

  Future<List<BankBranch>> getAllBranches() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .get();

      return querySnapshot.docs
          .map((doc) => BankBranch.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get branches: $e');
    }
  }

  Future<BankBranch?> getBranchById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return BankBranch.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get branch: $e');
    }
  }
}
