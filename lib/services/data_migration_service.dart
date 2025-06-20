import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bank_branch.dart';

class DataMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Migrate bank branches to Firebase
  Future<void> migrateBankBranches() async {
    try {
      // Cek apakah sudah ada data di Firebase
      final existingBranches =
          await _firestore
              .collection('bank_branches')
              .where('isActive', isEqualTo: true)
              .get();

      if (existingBranches.docs.isNotEmpty) {
        print('Bank branches already migrated');
        return;
      }

      // Data branches (pindahkan dari bank_branch_data.dart)
      final List<Map<String, dynamic>> branchesData = [
        {
          'id': 'kk_genteng_kali',
          'name': 'KK Genteng Kali Surabaya',
          'address': 'Jl. Genteng Besar No.26, Surabaya, Jawa Timur',
          'imageUrl': 'assets/images/genteng_kali.jpg',
          'isLocalImage': true,
          'city': 'Surabaya',
          'phoneNumber': '(031) 5345678',
          'operationalHours': 'Senin-Jumat: 08.00-15.00',
        },
        {
          'id': 'kk_gubeng',
          'name': 'KK Gubeng Surabaya',
          'address': 'Jl. Raya Gubeng No.8, Gubeng, Surabaya, Jawa Timur 60281',
          'imageUrl': 'assets/images/gubeng.jpg',
          'isLocalImage': true,
          'city': 'Surabaya',
          'phoneNumber': '(031) 5033214',
          'operationalHours': 'Senin-Jumat: 08.00-15.00, Sabtu: 08.00-12.00',
        },
        {
          'id': 'kk_bulog',
          'name': 'KK Bulog Surabaya',
          'address':
              'Jl. Ahmad Yani No.146-148, Gayungan, Kec. Gayungan, Surabaya, Jawa Timur',
          'imageUrl': 'assets/images/bulog.jpg',
          'isLocalImage': true,
          'city': 'Surabaya',
          'phoneNumber': '(031) 8290123',
          'operationalHours': 'Senin-Jumat: 08.00-15.00',
        },
        {
          'id': 'kk_kodam',
          'name': 'KK Kodam Surabaya',
          'address': 'Jl. Raya Kodam V Brawijaya, Surabaya, Jawa Timur',
          'imageUrl': 'assets/images/kodam.jpg',
          'isLocalImage': true,
          'city': 'Surabaya',
          'phoneNumber': '(031) 8432678',
          'operationalHours': 'Senin-Jumat: 08.00-15.00',
        },
      ];

      // Tambahkan ke Firestore
      final now = DateTime.now();
      for (final branchData in branchesData) {
        final branch = BankBranch(
          id: branchData['id'],
          name: branchData['name'],
          address: branchData['address'],
          imageUrl: branchData['imageUrl'],
          isLocalImage: branchData['isLocalImage'],
          city: branchData['city'],
          phoneNumber: branchData['phoneNumber'],
          operationalHours: branchData['operationalHours'],
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('bank_branches')
            .doc(branch.id)
            .set(branch.toMap());
      }

      print('Bank branches migrated successfully');
    } catch (e) {
      print('Error migrating bank branches: $e');
    }
  }
}
