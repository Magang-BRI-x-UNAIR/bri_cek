import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_category.dart';
import '../models/question_item.dart';
import '../models/bank_branch.dart';
import 'assessment_category_service.dart';

class DatabaseInitializer {
  final AssessmentCategoryService _categoryService =
      AssessmentCategoryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeDatabase() async {
    await _initializeCategories();
    await _initializeBankBranches();
    await _initializeSampleQuestions();
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

  Future<void> _initializeBankBranches() async {
    try {
      final existingBranches =
          await _firestore
              .collection('bank_branches')
              .where('isActive', isEqualTo: true)
              .get();

      if (existingBranches.docs.isNotEmpty) {
        print('Bank branches already initialized');
        return;
      }

      final branchesData = [
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

      final now = DateTime.now();
      for (final branchData in branchesData) {
        final branch = BankBranch(
          id: branchData['id'] as String,
          name: branchData['name'] as String,
          address: branchData['address'] as String,
          imageUrl: branchData['imageUrl'] as String,
          isLocalImage: branchData['isLocalImage'] as bool,
          city: branchData['city'] as String,
          phoneNumber: branchData['phoneNumber'] as String?,
          operationalHours: branchData['operationalHours'] as String?,
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('bank_branches')
            .doc(branch.id)
            .set(branch.toMap());
      }

      print('Bank branches initialized successfully');
    } catch (e) {
      print('Error initializing bank branches: $e');
    }
  }

  Future<void> _initializeSampleQuestions() async {
    try {
      final existingQuestions =
          await _firestore.collection('questions').limit(1).get();
      if (existingQuestions.docs.isNotEmpty) {
        print('Questions already initialized');
        return;
      }

      // Sample questions untuk Teller - Grooming
      final sampleQuestions = [
        Question(
          id: 'teller_grooming_wajah_1',
          question: 'Wajah bersih dan terlihat segar',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'wajah_badan',
          order: 1,
        ),
        Question(
          id: 'teller_grooming_rambut_1',
          question: 'Rambut rapi dan terawat',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'rambut',
          order: 2,
        ),
        Question(
          id: 'teller_grooming_pakaian_1',
          question: 'Pakaian bersih, rapi, dan sesuai standar',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'pakaian',
          order: 3,
        ),
        Question(
          id: 'teller_grooming_sepatu_1',
          question: 'Sepatu bersih dan sesuai dengan pakaian',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'sepatu',
          order: 4,
        ),
        Question(
          id: 'teller_grooming_aksesoris_1',
          question: 'Aksesoris tidak berlebihan dan sesuai dengan pakaian',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'aksesoris',
          order: 5,
        ),
        Question(
          id: 'teller_grooming_wajah_2',
          question: 'Wajah bersih dan terlihat segar',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'wajah_badan',
          order: 6,
        ),
        Question(
          id: 'teller_grooming_rambut_2',
          question: 'Rambut rapi dan terawat',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'rambut',
          order: 7,
        ),
        Question(
          id: 'teller_grooming_pakaian_2',
          question: 'Pakaian bersih, rapi, dan sesuai standar',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'pakaian',
          order: 8,
        ),
        Question(
          id: 'teller_grooming_sepatu_2',
          question: 'Sepatu bersih dan sesuai dengan pakaian',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'sepatu',
          order: 9,
        ),
        Question(
          id: 'teller_grooming_aksesoris_2',
          question: 'Aksesoris tidak berlebihan dan sesuai dengan pakaian',
          assessmentCategoryId: 'teller',
          questionCategoryId: 'grooming',
          questionSubcategoryId: 'aksesoris',
          order: 10,
        ),
      ];
      for (final question in sampleQuestions) {
        await _firestore.collection('questions').add(question.toMap());
      }

      print('Sample questions initialized successfully');
    } catch (e) {
      print('Error initializing questions: $e');
    }
  }
}
