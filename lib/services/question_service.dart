import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/models/category.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metode untuk reset database dan membuat struktur lengkap
  Future<void> resetAndFixDatabase() async {
    try {
      print("Resetting and fixing database structure...");

      // Hapus koleksi yang ada
      await _clearCollection('assessment_categories');

      // Daftar kategori dan subkategori mereka
      final Map<String, Map<String, dynamic>> categories = {
        'satpam': {
          'name': 'Satpam',
          'order': 1,
          'icon': 'security',
          'isActive': true,
          'isPersonBased': true,
          'subcategories': [
            {'name': 'Grooming', 'order': 1},
            {'name': 'Sigap', 'order': 2},
            {'name': 'Mudah', 'order': 3},
            {'name': 'Akurat', 'order': 4},
            {'name': 'Ramah', 'order': 5},
            {'name': 'Terampil', 'order': 6},
          ],
        },
        'teller': {
          'name': 'Teller',
          'order': 2,
          'icon': 'person',
          'isActive': true,
          'isPersonBased': true,
          'subcategories': [
            {'name': 'Grooming', 'order': 1},
            {'name': 'Sigap', 'order': 2},
            {'name': 'Mudah', 'order': 3},
            {'name': 'Akurat', 'order': 4},
            {'name': 'Ramah', 'order': 5},
            {'name': 'Terampil', 'order': 6},
          ],
        },
        'customer_service': {
          'name': 'Customer Service',
          'order': 3,
          'icon': 'support_agent',
          'isActive': true,
          'isPersonBased': true,
          'subcategories': [
            {'name': 'Grooming', 'order': 1},
            {'name': 'Sigap', 'order': 2},
            {'name': 'Mudah', 'order': 3},
            {'name': 'Akurat', 'order': 4},
            {'name': 'Ramah', 'order': 5},
            {'name': 'Terampil', 'order': 6},
          ],
        },
        'banking_hall': {
          'name': 'Banking Hall',
          'order': 4,
          'icon': 'business',
          'isActive': true,
          'isPersonBased': false,
          'subcategories': [
            {'name': 'Area Dalam', 'order': 1},
            {'name': 'Area Teller', 'order': 2},
            {'name': 'Area CS', 'order': 3},
            {'name': 'Area Supervisor', 'order': 4},
          ],
        },
        'gallery_echannel': {
          'name': 'Gallery eChannel',
          'order': 5,
          'icon': 'devices',
          'isActive': true,
          'isPersonBased': false,
          'subcategories': [
            {'name': 'Pintu Masuk', 'order': 1},
            {'name': 'Ruang ATM', 'order': 2},
            {'name': 'ATM dan CRM', 'order': 3},
          ],
        },
        'fasad_gedung': {
          'name': 'Fasad Gedung',
          'order': 6,
          'icon': 'apartment',
          'isActive': true,
          'isPersonBased': false,
          'subcategories': [
            {'name': 'Area Luar', 'order': 1},
          ],
        },
        'ruang_brimen': {
          'name': 'Ruang Brimen',
          'order': 7,
          'icon': 'meeting_room',
          'isActive': true,
          'isPersonBased': false,
          'subcategories': [
            {'name': 'BRIMEN', 'order': 1},
            {'name': 'Ruang Kerja', 'order': 2},
            {'name': 'Pantry', 'order': 3},
            {'name': 'Ruang Server', 'order': 4},
            {'name': 'Gudang', 'order': 5},
          ],
        },
        'toilet': {
          'name': 'Toilet',
          'order': 8,
          'icon': 'wc',
          'isActive': true,
          'isPersonBased': false,
          'subcategories': [
            {'name': 'Toilet', 'order': 1},
          ],
        },
      };

      // Timestamp untuk konsistensi
      final now = Timestamp.now();

      // Buat kategori dan subkategorinya
      for (String categoryId in categories.keys) {
        final categoryData = categories[categoryId]!;
        final subcategories = categoryData['subcategories'] as List;

        // Hapus subcategories dari data kategori
        final Map<String, dynamic> categoryDoc = Map.from(categoryData);
        categoryDoc.remove('subcategories');
        categoryDoc['createdAt'] = now;
        categoryDoc['updatedAt'] = now;

        // Buat dokumen kategori
        await _firestore
            .collection('assessment_categories')
            .doc(categoryId)
            .set(categoryDoc);

        // Tambahkan subkategori
        for (Map<String, dynamic> subcat in subcategories) {
          final subcatData = {
            'name': subcat['name'],
            'order': subcat['order'],
            'isActive': true,
            'createdAt': now,
            'updatedAt': now,
          };

          // Buat ID dari nama subkategori (lowercase dan ganti spasi dengan underscore)
          String subcatId = subcat['name']
              .toString()
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll('&', 'dan');

          await _firestore
              .collection('assessment_categories')
              .doc(categoryId)
              .collection('subcategories')
              .doc(subcatId)
              .set(subcatData);

          print(
            "Added subcategory ${subcat['name']} to category ${categoryData['name']}",
          );
        }
      }

      print(
        "Database structure has been reset and fixed with all categories and subcategories!",
      );
    } catch (e) {
      print("Error in resetAndFixDatabase: $e");
      throw e;
    }
  }

  // Helper method untuk menghapus koleksi
  Future<void> _clearCollection(String collectionPath) async {
    try {
      final snapshot = await _firestore.collection(collectionPath).get();

      if (snapshot.docs.isEmpty) {
        print("Collection $collectionPath is already empty");
        return;
      }

      print("Deleting ${snapshot.docs.length} documents from $collectionPath");

      // Untuk koleksi kecil, kita bisa menggunakan batch
      if (snapshot.docs.length <= 500) {
        final batch = _firestore.batch();

        for (var doc in snapshot.docs) {
          // Hapus juga subkategori
          final subcatsSnapshot =
              await _firestore
                  .collection(collectionPath)
                  .doc(doc.id)
                  .collection('subcategories')
                  .get();

          for (var subcatDoc in subcatsSnapshot.docs) {
            batch.delete(subcatDoc.reference);
          }

          batch.delete(doc.reference);
        }

        await batch.commit();
      }
      // Untuk koleksi besar, hapus satu per satu
      else {
        for (var doc in snapshot.docs) {
          // Hapus subkategori terlebih dahulu
          final subcatsSnapshot =
              await _firestore
                  .collection(collectionPath)
                  .doc(doc.id)
                  .collection('subcategories')
                  .get();

          for (var subcatDoc in subcatsSnapshot.docs) {
            await subcatDoc.reference.delete();
          }

          await doc.reference.delete();
        }
      }

      print("Collection $collectionPath has been cleared");
    } catch (e) {
      print("Error clearing collection $collectionPath: $e");
      throw e;
    }
  }

  // Inisialisasi database dengan struktur hierarkis
  Future<void> initializeDatabase() async {
    try {
      print("Initializing database structure...");

      // Check if database already has categories
      final snapshot = await _firestore.collection('categories').get();
      if (snapshot.docs.isNotEmpty) {
        print(
          "Database already initialized. Found ${snapshot.docs.length} categories.",
        );
        return;
      }

      // Main categories
      await _initSatpamCategory();
      await _initTellerCategory();
      await _initCustomerServiceCategory();

      print("Database initialization complete!");
    } catch (e) {
      print("Error initializing database: $e");
      throw e;
    }
  }

  // Inisialisasi kategori Satpam
  Future<void> _initSatpamCategory() async {
    // Buat kategori utama: Satpam
    await _firestore.collection('categories').doc('satpam').set({
      'name': 'Satpam',
      'order': 1,
    });

    // Inisialisasi subkategori Grooming
    await _initGroomingSubcategory('satpam');

    // Inisialisasi subkategori lainnya untuk Satpam
    await _firestore
        .collection('categories')
        .doc('satpam')
        .collection('subcategories')
        .doc('sigap')
        .set({'name': 'Sigap', 'order': 2});

    await _firestore
        .collection('categories')
        .doc('satpam')
        .collection('subcategories')
        .doc('mudah')
        .set({'name': 'Mudah', 'order': 3});

    await _firestore
        .collection('categories')
        .doc('satpam')
        .collection('subcategories')
        .doc('akurat')
        .set({'name': 'Akurat', 'order': 4});

    await _firestore
        .collection('categories')
        .doc('satpam')
        .collection('subcategories')
        .doc('ramah')
        .set({'name': 'Ramah', 'order': 5});

    await _firestore
        .collection('categories')
        .doc('satpam')
        .collection('subcategories')
        .doc('terampil')
        .set({'name': 'Terampil', 'order': 6});

    // Tambahkan pertanyaan untuk subkategori non-grooming
    await _addSimpleQuestion(
      'satpam',
      'sigap',
      'Sigap dalam menyambut nasabah',
      1,
    );
    await _addSimpleQuestion(
      'satpam',
      'sigap',
      'Posisi berdiri tegak dan siap',
      2,
    );

    await _addSimpleQuestion(
      'satpam',
      'mudah',
      'Memberikan arahan yang jelas kepada nasabah',
      1,
    );
    await _addSimpleQuestion(
      'satpam',
      'mudah',
      'Menggunakan bahasa yang mudah dipahami',
      2,
    );

    await _addSimpleQuestion(
      'satpam',
      'akurat',
      'Memberikan informasi yang tepat',
      1,
    );
    await _addSimpleQuestion(
      'satpam',
      'akurat',
      'Mengarahkan nasabah ke bagian yang sesuai',
      2,
    );

    await _addSimpleQuestion('satpam', 'ramah', 'Menyapa dengan senyuman', 1);
    await _addSimpleQuestion(
      'satpam',
      'ramah',
      'Menggunakan nada suara yang ramah',
      2,
    );

    await _addSimpleQuestion(
      'satpam',
      'terampil',
      'Terampil dalam membantu nasabah',
      1,
    );
    await _addSimpleQuestion(
      'satpam',
      'terampil',
      'Dapat mengatasi situasi dengan tepat',
      2,
    );
  }

  // Helper untuk menambahkan pertanyaan sederhana
  Future<void> _addSimpleQuestion(
    String mainCategory,
    String subcategory,
    String questionText,
    int order,
  ) async {
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('questions')
        .add({
          'text': questionText,
          'order': order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Inisialisasi kategori Teller
  Future<void> _initTellerCategory() async {
    await _firestore.collection('categories').doc('teller').set({
      'name': 'Teller',
      'order': 2,
    });

    // Tambahkan subkategori untuk Teller
    await _firestore
        .collection('categories')
        .doc('teller')
        .collection('subcategories')
        .doc('grooming')
        .set({'name': 'Grooming', 'order': 1});

    // Inisialisasi subkategori Grooming
    await _initGroomingSubcategory('teller');

    // Tambahkan subkategori lain untuk Teller seperti di Satpam
    await _firestore
        .collection('categories')
        .doc('teller')
        .collection('subcategories')
        .doc('sigap')
        .set({'name': 'Sigap', 'order': 2});

    // Tambahkan subkategori lain dan pertanyaan sederhana
    await _addSimpleQuestion(
      'teller',
      'sigap',
      'Sigap dalam melayani nasabah',
      1,
    );
  }

  // Inisialisasi kategori Customer Service
  Future<void> _initCustomerServiceCategory() async {
    await _firestore.collection('categories').doc('customer_service').set({
      'name': 'Customer Service',
      'order': 3,
    });

    // Tambahkan subkategori untuk Customer Service
    await _firestore
        .collection('categories')
        .doc('customer_service')
        .collection('subcategories')
        .doc('grooming')
        .set({'name': 'Grooming', 'order': 1});

    // Inisialisasi subkategori Grooming
    await _initGroomingSubcategory('customer_service');
  }

  // Inisialisasi subkategori Grooming - digunakan untuk semua kategori utama
  Future<void> _initGroomingSubcategory(String mainCategory) async {
    // Set dokumen Grooming jika belum diset
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc('grooming')
        .set({'name': 'Grooming', 'order': 1});

    // Tambah gender Pria dan Wanita
    await _initGenderCategory(mainCategory, 'grooming', 'pria', 'Pria', 1);
    await _initGenderCategory(mainCategory, 'grooming', 'wanita', 'Wanita', 2);
  }

  // Inisialisasi kategori gender dengan sections
  Future<void> _initGenderCategory(
    String mainCategory,
    String subcategory,
    String genderId,
    String genderName,
    int order,
  ) async {
    // Set dokumen gender
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .set({'name': genderName, 'order': order});

    // Tambahkan sections untuk gender
    await _initSections(mainCategory, subcategory, genderId);
  }

  // Inisialisasi sections untuk setiap gender
  Future<void> _initSections(
    String mainCategory,
    String subcategory,
    String genderId,
  ) async {
    // Wajah & Badan Section
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc('wajah_badan')
        .set({'name': 'Wajah & Badan', 'order': 1});

    // Tambahkan pertanyaan untuk Wajah & Badan
    if (genderId == 'pria') {
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'wajah_badan',
        'Wajah tidak berjenggot dan berkumis',
        1,
      );
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'wajah_badan',
        'Wajah bersih dari bekas jerawat',
        2,
      );
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'wajah_badan',
        'Kulit wajah tidak berminyak',
        3,
      );
    } else {
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'wajah_badan',
        'Wajah bersih dari bekas jerawat',
        1,
      );
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'wajah_badan',
        'Make up sesuai ketentuan',
        2,
      );
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'wajah_badan',
        'Kulit wajah tidak berminyak',
        3,
      );
    }

    // Rambut Section
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc('rambut')
        .set({'name': 'Rambut', 'order': 2});

    // Pertanyaan untuk rambut
    if (genderId == 'pria') {
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'rambut',
        'Rambut pendek sesuai ketentuan',
        1,
      );
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'rambut',
        'Tidak menggunakan pewarna rambut',
        2,
      );
    } else {
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'rambut',
        'Rambut tertata rapi',
        1,
      );
      await _addQuestion(
        mainCategory,
        subcategory,
        genderId,
        'rambut',
        'Menggunakan hairnet jika rambut panjang',
        2,
      );
    }

    // Pakaian Section
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc('pakaian')
        .set({'name': 'Pakaian', 'order': 3});

    // Tambahkan uniform types untuk pakaian
    await _initUniformTypes(mainCategory, subcategory, genderId, 'pakaian');
  }

  // Inisialisasi tipe uniform (PDH, PDL)
  Future<void> _initUniformTypes(
    String mainCategory,
    String subcategory,
    String genderId,
    String sectionId,
  ) async {
    // PDH - Pakaian Dinas Harian
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc(sectionId)
        .collection('uniform_types')
        .doc('pdh')
        .set({'name': 'PDH (Pakaian Dinas Harian)', 'order': 1});

    // Pertanyaan untuk PDH
    await _addQuestionForUniform(
      mainCategory,
      subcategory,
      genderId,
      sectionId,
      'pdh',
      'Pakaian bersih dan tidak kusut',
      1,
    );
    await _addQuestionForUniform(
      mainCategory,
      subcategory,
      genderId,
      sectionId,
      'pdh',
      'Kancing lengkap dan terpasang dengan benar',
      2,
    );

    // PDL - Pakaian Dinas Lapangan
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc(sectionId)
        .collection('uniform_types')
        .doc('pdl')
        .set({'name': 'PDL (Pakaian Dinas Lapangan)', 'order': 2});

    // Pertanyaan untuk PDL
    await _addQuestionForUniform(
      mainCategory,
      subcategory,
      genderId,
      sectionId,
      'pdl',
      'Pakaian bersih dan tidak kusut',
      1,
    );
    await _addQuestionForUniform(
      mainCategory,
      subcategory,
      genderId,
      sectionId,
      'pdl',
      'Atribut lengkap sesuai ketentuan',
      2,
    );
  }

  // Helper untuk menambahkan pertanyaan pada section
  Future<void> _addQuestion(
    String mainCategory,
    String subcategory,
    String genderId,
    String sectionId,
    String questionText,
    int order,
  ) async {
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc(sectionId)
        .collection('questions')
        .add({
          'text': questionText,
          'order': order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Helper untuk menambahkan pertanyaan pada uniform type
  Future<void> _addQuestionForUniform(
    String mainCategory,
    String subcategory,
    String genderId,
    String sectionId,
    String uniformTypeId,
    String questionText,
    int order,
  ) async {
    await _firestore
        .collection('categories')
        .doc(mainCategory)
        .collection('subcategories')
        .doc(subcategory)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc(sectionId)
        .collection('uniform_types')
        .doc(uniformTypeId)
        .collection('questions')
        .add({
          'text': questionText,
          'order': order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // BAGIAN UNTUK MENGAKSES DATA

  // Mendapatkan semua kategori utama
  Future<List<Category>> getMainCategories() async {
    try {
      print("Accessing Firestore for categories");
      final snapshot =
          await _firestore
              .collection('assessment_categories')
              .orderBy('order')
              .get();

      print("Firestore returned ${snapshot.docs.length} categories");

      return snapshot.docs.map((doc) {
        return Category(
          id: doc.id,
          name: doc.data()['name'] ?? doc.id,
          order: doc.data()['order'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting main categories: $e');
      return [];
    }
  }

  // Mendapatkan subkategori
  Future<List<Category>> getSubcategories(String mainCategoryId) async {
    try {
      print("Getting subcategories for $mainCategoryId");

      final snapshot =
          await _firestore
              .collection('assessment_categories')
              .doc(mainCategoryId)
              .collection('subcategories')
              .orderBy('order')
              .get();

      print("Found ${snapshot.docs.length} subcategories");

      return snapshot.docs.map((doc) {
        return Category(
          id: doc.id,
          name: doc.data()['name'] ?? doc.id,
          order: doc.data()['order'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting subcategories: $e');
      return [];
    }
  }

  // Mendapatkan kategori gender
  Future<List<Category>> getGenderCategories(
    String mainCategoryId,
    String subcategoryId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('categories')
              .doc(mainCategoryId)
              .collection('subcategories')
              .doc(subcategoryId)
              .collection('gender_categories')
              .orderBy('order')
              .get();

      return snapshot.docs
          .map(
            (doc) => Category(
              id: doc.id,
              name: doc['name'] ?? doc.id,
              order: doc['order'] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting gender categories: $e');
      return [];
    }
  }

  // Mendapatkan sections
  Future<List<Category>> getSections(
    String mainCategoryId,
    String subcategoryId,
    String genderId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('categories')
              .doc(mainCategoryId)
              .collection('subcategories')
              .doc(subcategoryId)
              .collection('gender_categories')
              .doc(genderId)
              .collection('sections')
              .orderBy('order')
              .get();

      return snapshot.docs
          .map(
            (doc) => Category(
              id: doc.id,
              name: doc['name'] ?? doc.id,
              order: doc['order'] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting sections: $e');
      return [];
    }
  }

  // Mendapatkan tipe uniform
  Future<List<Category>> getUniformTypes(
    String mainCategoryId,
    String subcategoryId,
    String genderId,
    String sectionId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('categories')
              .doc(mainCategoryId)
              .collection('subcategories')
              .doc(subcategoryId)
              .collection('gender_categories')
              .doc(genderId)
              .collection('sections')
              .doc(sectionId)
              .collection('uniform_types')
              .orderBy('order')
              .get();

      return snapshot.docs
          .map(
            (doc) => Category(
              id: doc.id,
              name: doc['name'] ?? doc.id,
              order: doc['order'] ?? 0,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting uniform types: $e');
      return [];
    }
  }

  // Mendapatkan pertanyaan berdasarkan path
  // Di QuestionService, perbaiki method getQuestionsForPath()
  Future<List<ChecklistItem>> getQuestionsForPath({
    required String mainCategory,
    String? subcategory,
    String? gender,
    String? section,
    String? uniformType,
  }) async {
    try {
      print("Getting questions for path with parameters:");
      print("- mainCategory: $mainCategory");
      print("- subcategory: $subcategory");
      print("- gender: $gender");
      print("- section: $section");
      print("- uniformType: $uniformType");

      String path =
          'assessment_categories/$mainCategory'; // Sesuaikan dengan struktur saat menambah!

      if (subcategory != null) {
        path += '/subcategories/$subcategory';

        if (gender != null) {
          path += '/gender_categories/$gender';

          if (section != null) {
            path += '/sections/$section';

            if (uniformType != null) {
              path += '/uniform_types/$uniformType';
            }
          }
        }
      }

      path += '/questions';

      print("Final query path: $path");

      final snapshot = await _firestore.collection(path).orderBy('order').get();

      print("Firestore returned ${snapshot.docs.length} questions");

      List<ChecklistItem> questions = [];

      for (var doc in snapshot.docs) {
        print("Processing question ${doc.id}: ${doc.data()}");
        questions.add(
          ChecklistItem(
            id: doc.id,
            question: doc.data()['text'] ?? '',
            category: mainCategory,
            subcategory: subcategory ?? '',
            gender: gender,
            section: section,
            uniformType: uniformType,
            order: doc.data()['order'] ?? 0,
          ),
        );
      }

      return questions;
    } catch (e) {
      print("Error getting questions: $e");
      return [];
    }
  }

  // Menambahkan pertanyaan baru
  // Sesuaikan method addQuestion untuk menerima subcategory null
  Future<void> addQuestion({
    required String mainCategory,
    required String
    subcategory, // Parameter masih required, tapi di implementasi kita akan memberikan nilai default
    String? gender,
    String? section,
    String? uniformType,
    required String questionText,
  }) async {
    try {
      String path = 'assessment_categories/$mainCategory';

      // Pastikan subcategory tidak null dalam path
      path += '/subcategories/$subcategory';

      if (gender != null) {
        path += '/gender_categories/$gender';

        if (section != null) {
          path += '/sections/$section';

          if (uniformType != null) {
            path += '/uniform_types/$uniformType';
          }
        }
      }

      path += '/questions';

      print("Adding question to path: $path");

      await _firestore.collection(path).add({
        'text': questionText,
        'order': await _getNextQuestionOrder(path),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Question added successfully");
    } catch (e) {
      print('Error adding question: $e');
      throw e;
    }
  }

  // Helper untuk mendapatkan urutan pertanyaan berikutnya
  Future<int> _getNextQuestionOrder(String path) async {
    try {
      final snapshot =
          await _firestore
              .collection(path)
              .orderBy('order', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return 1;
      }

      return (snapshot.docs.first['order'] ?? 0) + 1;
    } catch (e) {
      return 1;
    }
  }

  // Mengedit pertanyaan
  Future<void> editQuestion({
    required String path,
    required String questionId,
    required String newText,
  }) async {
    try {
      await _firestore.collection(path).doc(questionId).update({
        'text': newText,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error editing question: $e');
      throw e;
    }
  }

  // Menghapus pertanyaan
  Future<void> deleteQuestion({
    required String path,
    required String questionId,
  }) async {
    try {
      await _firestore.collection(path).doc(questionId).delete();
    } catch (e) {
      print('Error deleting question: $e');
      throw e;
    }
  }
}
