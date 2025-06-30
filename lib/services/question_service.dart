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
      await _clearCollection(
        'assessment_categories',
      ); // Daftar kategori dan subkategori mereka
      final Map<String, Map<String, dynamic>> categories = {
        'customer_service': {
          'name': 'Customer Service',
          'order': 1,
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
        'satpam': {
          'name': 'Satpam',
          'order': 3,
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
  // Method untuk menambahkan pertanyaan Pakaian Wanita untuk Satpam
  Future<void> initializeSatpamPakaianWanitaQuestions() async {
    try {
      print("Initializing Satpam Pakaian Wanita questions...");

      final categoryId = 'satpam';
      final subcategoryId = 'grooming';
      final genderCategoryId = 'wanita';
      final sectionId = 'pakaian';
      final Timestamp now = Timestamp.now();

      // Pastikan section Pakaian ada
      await _firestore
          .collection('assessment_categories')
          .doc(categoryId)
          .collection('subcategories')
          .doc(subcategoryId)
          .collection('gender_categories')
          .doc(genderCategoryId)
          .collection('sections')
          .doc(sectionId)
          .set({
            'name': 'Pakaian',
            'order':
                7, // Asumsi order 7 (setelah wajah_badan, rambut, jilbab, atribut, aksesoris, sepatu)
            'isActive': true,
            'createdAt': now,
            'updatedAt': now,
          }, SetOptions(merge: true));

      // Tambahkan pertanyaan untuk uniform type PDH (Pakaian Dinas Harian)
      await _addSatpamPakaianWanitaQuestionsForType(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        genderCategoryId: genderCategoryId,
        sectionId: sectionId,
        uniformType: 'pdh',
        uniformTypeName: 'PDH (Pakaian Dinas Harian)',
        questions: [
          {
            'text':
                'Pakaian harus terlihat bersih, rapi, tidak kusam dan lusuh',
            'order': 1,
          },
          {
            'text':
                'Atasan kemeja lengan pendek (untuk yang berjiilbab menggunakan lengan panjang) warna krem dengan lap pundak dimasukan ke dalam celana',
            'order': 2,
          },
          {
            'text':
                'Bawahan celana panjang kain cokelat tua pada saat dinas di banking hall pada jam layanan operasional',
            'order': 3,
          },
        ],
        now: now,
      );

      // Tambahkan pertanyaan untuk uniform type PDL (Pakaian Dinas Lapangan)
      await _addSatpamPakaianWanitaQuestionsForType(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        genderCategoryId: genderCategoryId,
        sectionId: sectionId,
        uniformType: 'pdl',
        uniformTypeName: 'PDL (Pakaian Dinas Lapangan)',
        questions: [
          {
            'text':
                'Pakaian harus terlihat bersih, rapi, tidak kusam dan lusuh',
            'order': 1,
          },
          {
            'text':
                'Satpam luar wajib menggunakan topi PDL selama bertugas di luar',
            'order': 2,
          },
          {
            'text':
                'Atasan kemeja lengan panjang warna krem dengan lap pundak dimasukkan ke dalam celana',
            'order': 3,
          },
          {
            'text':
                'Bawahan celana panjang cargo cokelat tua pada saat dinas di luar banking hall',
            'order': 4,
          },
        ],
        now: now,
      );

      print("Added all Satpam Pakaian Wanita questions successfully!");
    } catch (e) {
      print("Error initializing Satpam Pakaian Wanita questions: $e");
      throw e;
    }
  }

  // Helper method untuk menambahkan pertanyaan pakaian wanita berdasarkan uniform type
  Future<void> _addSatpamPakaianWanitaQuestionsForType({
    required String categoryId,
    required String subcategoryId,
    required String genderCategoryId,
    required String sectionId,
    required String uniformType,
    required String uniformTypeName,
    required List<Map<String, dynamic>> questions,
    required Timestamp now,
  }) async {
    // Pastikan uniform type ada
    await _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('gender_categories')
        .doc(genderCategoryId)
        .collection('sections')
        .doc(sectionId)
        .collection('uniform_types')
        .doc(uniformType)
        .set({
          'name': uniformTypeName,
          'isActive': true,
          'createdAt': now,
          'updatedAt': now,
        }, SetOptions(merge: true));

    // Path ke collection questions untuk uniform type ini
    final questionsCollection = _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('gender_categories')
        .doc(genderCategoryId)
        .collection('sections')
        .doc(sectionId)
        .collection('uniform_types')
        .doc(uniformType)
        .collection('questions');

    // Hapus pertanyaan yang mungkin sudah ada sebelumnya
    final existingQuestions = await questionsCollection.get();
    final batch = _firestore.batch();

    for (var doc in existingQuestions.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    // Tambahkan pertanyaan baru
    for (var question in questions) {
      await questionsCollection.add({
        'text': question['text'],
        'order': question['order'],
        'isActive': true,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    print(
      "Added ${questions.length} Pakaian ${uniformTypeName} questions for Satpam successfully!",
    );
  }

  // Method untuk inisialisasi struktur Grooming
  Future<void> _initializeGroomingStructure(String categoryId) async {
    try {
      // Tambahkan gender categories (pria & wanita)
      await _addGenderCategory(categoryId, 'grooming', 'pria', 'Pria', 1);
      await _addGenderCategory(categoryId, 'grooming', 'wanita', 'Wanita', 2);

      // Untuk PRIA
      await _initializeMaleSections(categoryId, 'grooming', 'pria');

      // Untuk WANITA
      await _initializeFemaleSections(categoryId, 'grooming', 'wanita');

      print("Grooming structure initialized successfully!");
    } catch (e) {
      print("Error initializing grooming structure: $e");
      throw e;
    }
  }

  // Method untuk menambahkan gender category
  Future<void> _addGenderCategory(
    String categoryId,
    String subcategoryId,
    String genderId,
    String genderName,
    int order,
  ) async {
    await _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('gender_categories')
        .doc(genderId)
        .set({
          'name': genderName,
          'order': order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Method untuk inisialisasi sections khusus PRIA
  Future<void> _initializeMaleSections(
    String categoryId,
    String subcategoryId,
    String genderId,
  ) async {
    // 1. Wajah & Badan Section
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'wajah_badan',
      'Wajah & Badan',
      1,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'wajah_badan',
      'Wajah bersih dari bekas jerawat',
      1,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'wajah_badan',
      'Tidak berbau badan, mulut, dan parfum menyengat',
      2,
    );

    // 2. Rambut Section dengan uniform types
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'Rambut',
      2,
    );

    // 2.1 Rambut - Korporat/Batik
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'korporat_batik',
      'Seragam Korporat/Batik',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'korporat_batik',
      'Rambut pendek rapi, tidak menyentuh kerah baju dan daun telinga',
      1,
    );

    // 2.2 Rambut - Kasual
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'kasual',
      'Pakaian Kasual',
      2,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'kasual',
      'Rambut pendek rapi, tidak menyentuh kerah baju dan daun telinga',
      1,
    );

    // 3. Pakaian Section dengan uniform types
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'Pakaian',
      3,
    );

    // 3.1 Pakaian - Korporat
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'korporat',
      'Seragam Korporat',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'korporat',
      'Menggunakan seragam korporat sesuai ketentuan pada hari Senin-Rabu',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'korporat',
      'Seragam bersih, rapi dan tidak kusut',
      2,
    );

    // 3.2 Pakaian - Batik
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'batik',
      'Seragam Batik',
      2,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'batik',
      'Menggunakan seragam batik sesuai ketentuan pada hari Kamis',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'batik',
      'Batik bersih, rapi dan tidak kusut',
      2,
    );

    // 3.3 Pakaian - Kasual
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'kasual',
      'Pakaian Kasual',
      3,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'kasual',
      'Menggunakan pakaian casual sesuai ketentuan pada hari Jumat',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'kasual',
      'Pakaian casual bersih, rapi dan tidak kusut',
      2,
    );

    // 4. Atribut & Aksesoris
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'atribut_aksesoris',
      'Atribut & Aksesoris',
      4,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'atribut_aksesoris',
      'Menggunakan name tag secara benar dan terlihat jelas',
      1,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'atribut_aksesoris',
      'Tidak menggunakan aksesoris selain cincin kawin dan jam tangan',
      2,
    );

    // 5. Sepatu
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'Sepatu',
      5,
    );

    // 5.1 Sepatu - Korporat
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'korporat',
      'Seragam Korporat',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'korporat',
      'Sepatu pantofel warna hitam tertutup',
      1,
    );

    // 5.2 Sepatu - Batik
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'batik',
      'Seragam Batik',
      2,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'batik',
      'Sepatu pantofel warna hitam tertutup',
      1,
    );

    // 5.3 Sepatu - Kasual
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'kasual',
      'Pakaian Kasual',
      3,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'kasual',
      'Sepatu tertutup yang sopan',
      1,
    );
  }

  // Method untuk inisialisasi sections khusus WANITA
  Future<void> _initializeFemaleSections(
    String categoryId,
    String subcategoryId,
    String genderId,
  ) async {
    // 1. Wajah & Badan Section
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'wajah_badan',
      'Wajah & Badan',
      1,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'wajah_badan',
      'Wajah bersih dari bekas jerawat',
      1,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'wajah_badan',
      'Menggunakan make up natural (bedak, alis, eye liner, blush on, lipstick)',
      2,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'wajah_badan',
      'Tidak berbau badan, mulut, dan parfum menyengat',
      3,
    );

    // 2. Rambut Section (khusus non-hijab)
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'Rambut',
      2,
    );

    // 2.1 Rambut - Korporat/Batik
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'korporat_batik',
      'Seragam Korporat/Batik',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'korporat_batik',
      'Rambut diikat/disanggul rapi dengan jaring rambut/hairnet warna hitam/sesuai warna rambut',
      1,
    );

    // 2.2 Rambut - Kasual
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'kasual',
      'Pakaian Kasual',
      2,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'rambut',
      'kasual',
      'Rambut pendek/sedang/panjang diikat rapi panjang maksimal sebahu, tidak diwarnai mencolok',
      1,
    );

    // 3. Jilbab Section
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'Jilbab',
      3,
    );

    // 3.1 Jilbab - Korporat
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'korporat',
      'Seragam Korporat',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'korporat',
      'Jilbab dikenakan dengan rapi, tidak terlihat rambut atau leher',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'korporat',
      'Jilbab berwarna senada/sesuai dengan seragam',
      2,
    );

    // 3.2 Jilbab - Batik
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'batik',
      'Seragam Batik',
      2,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'batik',
      'Jilbab dikenakan dengan rapi, tidak terlihat rambut atau leher',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'batik',
      'Jilbab berwarna senada/sesuai dengan seragam batik',
      2,
    );

    // 3.3 Jilbab - Kasual
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'kasual',
      'Pakaian Kasual',
      3,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'kasual',
      'Jilbab dikenakan dengan rapi, tidak terlihat rambut atau leher',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'jilbab',
      'kasual',
      'Jilbab berwarna senada/sesuai dengan pakaian kasual',
      2,
    );

    // 4. Pakaian Section dengan uniform types (sama seperti pria)
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'Pakaian',
      4,
    );

    // 4.1 Pakaian - Korporat
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'korporat',
      'Seragam Korporat',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'korporat',
      'Menggunakan seragam korporat sesuai ketentuan pada hari Senin-Rabu',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'korporat',
      'Seragam bersih, rapi dan tidak kusut',
      2,
    );

    // 4.2 Pakaian - Batik
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'batik',
      'Seragam Batik',
      2,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'batik',
      'Menggunakan seragam batik sesuai ketentuan pada hari Kamis',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'batik',
      'Batik bersih, rapi dan tidak kusut',
      2,
    );

    // 4.3 Pakaian - Kasual
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'kasual',
      'Pakaian Kasual',
      3,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'kasual',
      'Menggunakan pakaian casual sesuai ketentuan pada hari Jumat',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'pakaian',
      'kasual',
      'Pakaian casual bersih, rapi dan tidak kusut',
      2,
    );

    // 5. Atribut & Aksesoris
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'atribut_aksesoris',
      'Atribut & Aksesoris',
      5,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'atribut_aksesoris',
      'Menggunakan name tag secara benar dan terlihat jelas',
      1,
    );
    await _addQuestionToSection(
      categoryId,
      subcategoryId,
      genderId,
      'atribut_aksesoris',
      'Menggunakan aksesoris yang tidak berlebihan dan minimalis',
      2,
    );

    // 6. Sepatu (sama seperti pria)
    await _addSection(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'Sepatu',
      6,
    );

    // 6.1 Sepatu - Korporat
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'korporat',
      'Seragam Korporat',
      1,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'korporat',
      'Sepatu pantofel warna hitam tertutup dengan hak 3-7cm',
      1,
    );

    // 6.2 Sepatu - Batik
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'batik',
      'Seragam Batik',
      2,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'batik',
      'Sepatu pantofel warna hitam tertutup dengan hak 3-7cm',
      1,
    );

    // 6.3 Sepatu - Kasual
    await _addUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'kasual',
      'Pakaian Kasual',
      3,
    );
    await _addQuestionToUniformType(
      categoryId,
      subcategoryId,
      genderId,
      'sepatu',
      'kasual',
      'Sepatu tertutup yang sopan dengan hak maksimal 7cm',
      1,
    );
  }

  // Helper methods untuk membuat struktur

  Future<void> _addSection(
    String categoryId,
    String subcategoryId,
    String genderId,
    String sectionId,
    String sectionName,
    int order,
  ) async {
    await _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc(sectionId)
        .set({
          'name': sectionName,
          'order': order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _addUniformType(
    String categoryId,
    String subcategoryId,
    String genderId,
    String sectionId,
    String uniformTypeId,
    String uniformTypeName,
    int order,
  ) async {
    await _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('gender_categories')
        .doc(genderId)
        .collection('sections')
        .doc(sectionId)
        .collection('uniform_types')
        .doc(uniformTypeId)
        .set({
          'name': uniformTypeName,
          'order': order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _addQuestionToSection(
    String categoryId,
    String subcategoryId,
    String genderId,
    String sectionId,
    String questionText,
    int order,
  ) async {
    await _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
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

  Future<void> _addQuestionToUniformType(
    String categoryId,
    String subcategoryId,
    String genderId,
    String sectionId,
    String uniformTypeId,
    String questionText,
    int order,
  ) async {
    await _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
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

  // Method untuk menambahkan pertanyaan sederhana (tanpa hierarki gender/section)
  Future<void> _addSimpleQuestionToAssessment(
    String categoryId,
    String subcategoryId,
    String questionText,
    int order,
  ) async {
    await _firestore
        .collection('assessment_categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('questions')
        .add({
          'text': questionText,
          'order': order,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
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
