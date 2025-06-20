import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_category.dart';
import 'assessment_category_service.dart';
import 'data_migration_service.dart';

class DatabaseInitializer {
  final AssessmentCategoryService _categoryService =
      AssessmentCategoryService();
  final DataMigrationService _migrationService = DataMigrationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize database with default data
  Future<void> initializeDatabase() async {
    await _initializeCategories();
    await _migrationService.migrateBankBranches();
    // Nanti kita akan tambahkan inisialisasi lainnya
  }

  Future<void> _initializeCategories() async {
    try {
      // Cek apakah sudah ada data
      final existingCategories = await _categoryService.getActiveCategories();
      if (existingCategories.isNotEmpty) {
        print('Categories already initialized');
        return;
      }

      // Data kategori default
      final defaultCategories = [
        AssessmentCategory(
          id: 'satpam',
          name: 'Satpam',
          icon: 'security',
          isPersonBased: true,
          order: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AssessmentCategory(
          id: 'teller',
          name: 'Teller',
          icon: 'person',
          isPersonBased: true,
          order: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AssessmentCategory(
          id: 'customer_service',
          name: 'Customer Service',
          icon: 'support_agent',
          isPersonBased: true,
          order: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AssessmentCategory(
          id: 'banking_hall',
          name: 'Banking Hall',
          icon: 'business',
          isPersonBased: false,
          order: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AssessmentCategory(
          id: 'gallery_echannel',
          name: 'Gallery e-Channel',
          icon: 'devices',
          isPersonBased: false,
          order: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AssessmentCategory(
          id: 'fasad_gedung',
          name: 'Fasad Gedung',
          icon: 'apartment',
          isPersonBased: false,
          order: 6,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AssessmentCategory(
          id: 'ruang_brimen',
          name: 'Ruang BRIMEN',
          icon: 'meeting_room',
          isPersonBased: false,
          order: 7,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AssessmentCategory(
          id: 'toilet',
          name: 'Toilet',
          icon: 'wc',
          isPersonBased: false,
          order: 8,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Tambahkan ke Firestore
      for (final category in defaultCategories) {
        await _firestore
            .collection('assessment_categories')
            .doc(category.id)
            .set(category.toMap());
      }

      print('Default categories initialized successfully');
    } catch (e) {
      print('Error initializing categories: $e');
    }
  }
}
