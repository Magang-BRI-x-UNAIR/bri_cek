import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bank_branch.dart';

class BankBranchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BankBranch>> getActiveBranches() async {
    try {
      final snapshot =
          await _firestore
              .collection('bank_branches')
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .get();

      return snapshot.docs
          .map((doc) => BankBranch.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching branches: $e');
      return [];
    }
  }

  Future<BankBranch?> getBranchById(String id) async {
    try {
      final doc = await _firestore.collection('bank_branches').doc(id).get();

      if (doc.exists) {
        return BankBranch.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching branch: $e');
      return null;
    }
  }

  Future<List<BankBranch>> searchBranches(String query) async {
    try {
      final branches = await getActiveBranches();
      return branches
          .where(
            (branch) =>
                branch.name.toLowerCase().contains(query.toLowerCase()) ||
                branch.address.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching branches: $e');
      return [];
    }
  }
}
