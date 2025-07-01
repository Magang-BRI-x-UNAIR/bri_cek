import 'package:bri_cek/data/checklist_item_data.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/screens/checklist/widgets/category_navigator.dart';
import 'package:bri_cek/screens/checklist/widgets/checklist_header.dart';
import 'package:bri_cek/screens/checklist/widgets/completion_dialog.dart';
import 'package:bri_cek/screens/checklist/widgets/navigation_controls.dart';
import 'package:bri_cek/screens/checklist/widgets/subcategory_questions.dart';
import 'package:bri_cek/services/checklist_service.dart';
import 'package:bri_cek/services/question_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  final String selectedBank;
  final DateTime selectedDate;
  final String selectedCategory;
  final Map<String, dynamic>? employeeData;
  final String bankBranchId;
  final String sessionId;
  final bool fetchFromDatabase;

  const ChecklistScreen({
    super.key,
    required this.selectedBank,
    required this.selectedDate,
    required this.selectedCategory,
    required this.bankBranchId,
    required this.sessionId,
    this.employeeData,
    this.fetchFromDatabase = false, // Default to false
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ChecklistService _checklistService = ChecklistService();
  final ScrollController _scrollController = ScrollController();

  // State variables
  bool _isLoading = true;
  List<ChecklistItem> _checklistItems = [];
  Map<String, Map<String, List<ChecklistItem>>> _groupedChecklistItems = {};
  List<String> _categoryNames =
      []; // Note: Contains subcategories in database (grooming, sigap, etc.)
  List<List<String>> _subcategoryNames =
      []; // Note: Contains sections in database (wajah & badan, rambut, etc.)
  List<ChecklistItem> _currentSubcategoryItems = [];
  List<List<ChecklistItem>> _checklist = [];
  int _currentCategoryIndex = 0; // Note: Actually subcategory index in database
  int _currentSubcategoryIndex = 0; // Note: Actually section index in database
  int _totalItems = 0;
  int _completedItems = 0;
  final _formKey = GlobalKey<FormState>();
  List<bool> _categoryCompletionStatus =
      []; // Note: Actually subcategory completion status
  List<List<bool>> _subcategoryCompletionStatus =
      []; // Note: Actually section completion status
  String _currentCategory = '';
  String _currentSubcategory = '';

  final QuestionService _questionService = QuestionService();
  @override
  void initState() {
    super.initState();
    _setupAnimations();

    print("InitState - Selected category: ${widget.selectedCategory}");
    print("InitState - fetchFromDatabase: ${widget.fetchFromDatabase}");

    // Selalu ambil dari database untuk kategori Toilet
    if (widget.selectedCategory == "Toilet" || widget.fetchFromDatabase) {
      print(
        "Calling _fetchChecklistItems for category: ${widget.selectedCategory}",
      );
      _fetchChecklistItems();
    } else {
      print(
        "Calling _loadDefaultChecklistItems for category: ${widget.selectedCategory}",
      );
      _loadDefaultChecklistItems();
    }
  }

  Future<void> _fetchChecklistItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<ChecklistItem> items = [];

      // Ambil pertanyaan dari Firestore berdasarkan kategori yang dipilih
      String categoryId;

      // Handle khusus untuk kategori tertentu
      if (widget.selectedCategory.toLowerCase() == "gallery e-channel") {
        categoryId = "gallery_echannel";
      } else {
        categoryId = widget.selectedCategory.toLowerCase().replaceAll(' ', '_');
      }

      // Khusus untuk kategori "toilet"
      if (categoryId == "toilet") {
        print("Mengambil data pertanyaan toilet dari database...");

        // Gunakan path khusus untuk toilet
        final QuerySnapshot snapshot =
            await FirebaseFirestore.instance
                .collection('assessment_categories')
                .doc('toilet')
                .collection('subcategories')
                .doc('toilet')
                .collection('questions')
                .orderBy('order')
                .get();

        print(
          "Database mengembalikan ${snapshot.docs.length} pertanyaan toilet",
        );

        if (snapshot.docs.isNotEmpty) {
          items =
              snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ChecklistItem(
                  id: doc.id,
                  question: data['text'] ?? '',
                  category: 'Toilet',
                  subcategory: 'Toilet',
                  order: data['order'] ?? 0,
                );
              }).toList();

          print(
            "Berhasil memuat ${items.length} pertanyaan toilet dari database",
          );
        } else {
          print(
            "Tidak ada pertanyaan toilet di database. Menggunakan data default.",
          );
          items = _getDefaultChecklistItems();
          print("Default toilet items count: ${items.length}");
        }
      } else {
        // Untuk kategori lain, ambil semua subcategory dari kategori tersebut
        print("=== FETCHING DATA FOR CATEGORY: $categoryId ===");
        print("Employee data: ${widget.employeeData}");

        try {
          // Ambil semua subcategory dari kategori ini
          final subcategories = await _questionService.getSubcategories(
            categoryId,
          );

          print("=== SUBCATEGORIES FOUND ===");
          print("Count: ${subcategories.length}");
          print("Names: ${subcategories.map((s) => s.name).toList()}");
          print("IDs: ${subcategories.map((s) => s.id).toList()}");

          if (subcategories.isNotEmpty) {
            // Ambil pertanyaan dari semua subcategory
            for (var subcategory in subcategories) {
              print(
                "=== PROCESSING SUBCATEGORY: ${subcategory.name} (${subcategory.id}) ===",
              );

              final subcategoryItems = await _questionService
                  .getQuestionsForPath(
                    mainCategory: categoryId,
                    subcategory: subcategory.id,
                  );

              print(
                "Questions found for ${subcategory.name}: ${subcategoryItems.length}",
              );

              // Create new ChecklistItem objects with corrected subcategory name from database
              final correctedItems =
                  subcategoryItems.map((item) {
                    // Use the name from database only
                    final subcategoryDisplayName = subcategory.name;

                    print(
                      "Item: ${item.question} -> Category: ${item.category}, Subcategory: $subcategoryDisplayName",
                    );

                    // Section names are already set from database in the new method
                    return ChecklistItem(
                      id: item.id,
                      question: item.question,
                      category: item.category,
                      subcategory: subcategoryDisplayName,
                      gender: item.gender,
                      section:
                          item.section, // Already contains the name from database
                      uniformType:
                          item.uniformType, // Already contains the name from database
                      forHijab: item.forHijab,
                      order: item.order,
                      options: item.options,
                      isRequired: item.isRequired,
                      allowsNote: item.allowsNote,
                      answerValue: item.answerValue,
                      note: item.note,
                      skipped: item.skipped,
                      createdAt: item.createdAt,
                      updatedAt: item.updatedAt,
                      isActive: item.isActive,
                    );
                  }).toList();

              items.addAll(correctedItems);
              print(
                "Added ${correctedItems.length} questions from subcategory ${subcategory.name}",
              );
            }
            print(
              "=== TOTAL QUESTIONS LOADED: ${items.length} from ${subcategories.length} subcategories ===",
            );
          } else {
            print("=== NO SUBCATEGORIES FOUND FOR $categoryId ===");
          }

          // Coba juga ambil pertanyaan langsung dari level kategori (jika ada)
          final directCategoryItems = await _questionService
              .getQuestionsForPath(
                mainCategory: categoryId,
                // subcategory: null, jadi ambil langsung dari kategori
              );
          items.addAll(directCategoryItems);

          if (directCategoryItems.isNotEmpty) {
            print(
              "Berhasil memuat ${directCategoryItems.length} pertanyaan langsung dari kategori",
            );
          }
        } catch (e) {
          print("Error mengambil pertanyaan: $e");
        }

        if (items.isEmpty) {
          print("Tidak ada pertanyaan ditemukan, menggunakan data default");
          items = _getDefaultChecklistItems();
        }
      }

      // Organize items into categories and subcategories
      _organizeChecklistItems(items);
    } catch (e) {
      print('Error loading checklist items: $e');
      // Fallback ke data statis jika terjadi error
      final items = _getDefaultChecklistItems();
      _organizeChecklistItems(items);
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Start animation after loading is complete for toilet
      if (widget.selectedCategory.toLowerCase() == "toilet" &&
          _currentSubcategoryItems.isNotEmpty) {
        _animationController.forward();
      }
    }
  }

  void _organizeChecklistItems(List<ChecklistItem> items) {
    // Reset data yang ada
    _categoryNames = [];
    _subcategoryNames = [];
    _checklist = [];
    _checklistItems = items;

    // Set total items untuk progress calculation
    _totalItems = items.length;
    _completedItems =
        items
            .where((item) => item.answerValue != null || item.skipped == true)
            .length;

    print(
      "Organizing ${items.length} checklist items for category: ${widget.selectedCategory}",
    );

    // Debug: Print all items to see their subcategory values
    for (var item in items) {
      print(
        "Item: ${item.question} | Category: ${item.category} | Subcategory: ${item.subcategory} | Section: ${item.section}",
      );
    }

    // Case khusus untuk Toilet atau kategori sederhana lainnya
    if (widget.selectedCategory == "Toilet") {
      print("Processing Toilet category with ${items.length} items");

      // Jika tidak ada item, gunakan kategori default
      if (items.isEmpty) {
        print("No toilet items found, using default");
        _categoryNames = ["Toilet"];
        _subcategoryNames = [
          ["Toilet"],
        ];
        _checklist = [[]];
        _currentCategoryIndex = 0;
        _currentSubcategoryIndex = 0;
        _currentSubcategoryItems = [];
        return;
      }

      // Untuk toilet, gunakan struktur sederhana
      _categoryNames = ["Toilet"];
      _subcategoryNames = [
        ["Toilet"],
      ]; // Hanya satu subcategory
      _checklist = [items]; // Semua items toilet dalam satu checklist

      // Inisialisasi completion status
      _categoryCompletionStatus = [false];
      _subcategoryCompletionStatus = [
        [false],
      ];

      // Set indeks awal dan current items
      _currentCategoryIndex = 0;
      _currentSubcategoryIndex = 0;
      _currentSubcategoryItems = items; // Langsung gunakan semua items toilet
      _currentCategory = "Toilet";
      _currentSubcategory = "Toilet";

      print("Toilet setup complete:");
      print("- _categoryNames: $_categoryNames");
      print("- _subcategoryNames: $_subcategoryNames");
      print(
        "- _currentSubcategoryItems count: ${_currentSubcategoryItems.length}",
      );
      print(
        "- Items: ${_currentSubcategoryItems.map((e) => e.question).toList()}",
      );

      // Update completion status
      _updateCompletionStatus();

      return;
    }

    // Untuk kategori lain yang lebih kompleks
    // Kelompokkan berdasarkan subcategory sebagai level utama (sesuai struktur database)
    Map<String, Map<String, List<ChecklistItem>>> subcategoryMap = {};

    for (var item in items) {
      String subcategory =
          item.subcategory.isNotEmpty ? item.subcategory : "Umum";
      String section =
          item.section?.isNotEmpty == true
              ? item.section! // Use section name directly from database
              : "Umum";

      // Inisialisasi jika belum ada
      if (!subcategoryMap.containsKey(subcategory)) {
        subcategoryMap[subcategory] = {};
      }
      if (!subcategoryMap[subcategory]!.containsKey(section)) {
        subcategoryMap[subcategory]![section] = [];
      }

      // Tambahkan item ke section yang sesuai
      subcategoryMap[subcategory]![section]!.add(item);
    }

    print("Subcategory map keys: ${subcategoryMap.keys.toList()}");

    // Bentuk struktur data yang dibutuhkan untuk CategoryNavigator
    // _categoryNames akan berisi subcategories (pintu_masuk, ruang_atm, atm_dan_rm untuk Gallery E-Channel)
    _categoryNames = subcategoryMap.keys.toList();

    print("_categoryNames (subcategories): $_categoryNames");

    // Update _groupedChecklistItems untuk kompatibilitas dengan fungsi navigasi
    _groupedChecklistItems = subcategoryMap;

    // _subcategoryNames akan berisi sections untuk setiap subcategory (atau "Umum" jika tidak ada sections)
    for (var subcategory in _categoryNames) {
      List<String> sections = subcategoryMap[subcategory]!.keys.toList();
      _subcategoryNames.add(sections);
      print("Subcategory '$subcategory' has sections: $sections");

      List<ChecklistItem> subcategoryItems = [];
      for (var section in sections) {
        subcategoryItems.addAll(subcategoryMap[subcategory]![section]!);
      }

      _checklist.add(subcategoryItems);
    }

    print("Final _subcategoryNames (sections): $_subcategoryNames");

    // Set indeks awal jika ada data
    if (_categoryNames.isNotEmpty) {
      _currentCategoryIndex = 0;
      _currentSubcategoryIndex = 0;
      _currentSubcategoryItems = _checklist.isNotEmpty ? _checklist[0] : [];
      _currentCategory = _categoryNames[0];
      _currentSubcategory =
          _subcategoryNames.isNotEmpty && _subcategoryNames[0].isNotEmpty
              ? _subcategoryNames[0][0]
              : '';

      print(
        "Initial setup - Category: $_currentCategory, Subcategory: $_currentSubcategory",
      );
      print(
        "Initial _currentSubcategoryItems count: ${_currentSubcategoryItems.length}",
      );

      // Initialize completion status arrays
      _categoryCompletionStatus = List<bool>.filled(
        _categoryNames.length,
        false,
      );
      _subcategoryCompletionStatus = List.generate(
        _categoryNames.length,
        (catIndex) =>
            List<bool>.filled(_subcategoryNames[catIndex].length, false),
      );

      // Update completion status
      _updateCompletionStatus();

      // For toilet, don't use automatic navigation since we have simple structure
      if (widget.selectedCategory.toLowerCase() != "toilet") {
        // Automatically navigate to the first subcategory to show questions for complex categories
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_categoryNames.isNotEmpty &&
              _subcategoryNames.isNotEmpty &&
              _subcategoryNames[0].isNotEmpty) {
            _navigateToSubcategory(0, 0);
          }
        });
      }
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _updateCompletionStatus() {
    // Check each category and subcategory for completion
    for (int catIndex = 0; catIndex < _categoryNames.length; catIndex++) {
      final category = _categoryNames[catIndex];
      bool isCategoryComplete = true;

      for (
        int subIndex = 0;
        subIndex < _subcategoryNames[catIndex].length;
        subIndex++
      ) {
        final subcategory = _subcategoryNames[catIndex][subIndex];

        // Try to get items from _groupedChecklistItems first, fallback to filtering _checklistItems
        List<ChecklistItem> items = [];
        if (_groupedChecklistItems.isNotEmpty &&
            _groupedChecklistItems[category]?[subcategory] != null) {
          items = _groupedChecklistItems[category]![subcategory]!;
        } else {
          // Fallback: filter items by subcategory name
          items =
              _checklistItems
                  .where(
                    (item) =>
                        item.subcategory == category &&
                        (item.section == subcategory ||
                            (item.section?.isEmpty ??
                                true && subcategory == "Umum")),
                  )
                  .toList();
        }

        // A subcategory is complete if all its items have an answer or are skipped
        final isSubcategoryComplete = items.every(
          (item) => item.answerValue != null || item.skipped == true,
        );

        // Update subcategory status
        if (subIndex < _subcategoryCompletionStatus[catIndex].length) {
          _subcategoryCompletionStatus[catIndex][subIndex] =
              isSubcategoryComplete;
        }

        // If any subcategory is incomplete, the category is incomplete
        if (!isSubcategoryComplete) {
          isCategoryComplete = false;
        }
      }

      // Update category status
      if (catIndex < _categoryCompletionStatus.length) {
        _categoryCompletionStatus[catIndex] = isCategoryComplete;
      }
    }

    // Update completed items count - Include skipped items in progress calculation
    _completedItems =
        _checklistItems
            .where((item) => item.answerValue != null || item.skipped == true)
            .length;
  }

  void _loadDefaultChecklistItems() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil data checklist default sesuai kategori yang dipilih
      List<ChecklistItem> items = _getDefaultChecklistItems();

      // Jika tidak ada data default, coba ambil dari static data dan filter
      if (items.isEmpty) {
        final staticItems = getChecklistForCategory(widget.selectedCategory);
        final filteredItems = _checklistService.getFilteredItems(
          staticItems,
          widget.employeeData,
        );
        items = filteredItems;
      }

      // Organize items into categories and subcategories
      _organizeChecklistItems(items);
    } catch (e) {
      print('Error loading default checklist items: $e');
      // Jika terjadi error, inisialisasi list kosong
      _checklistItems = [];
      _categoryNames = [];
      _subcategoryNames = [];
      _checklist = [];
      _currentCategoryIndex = 0;
      _currentSubcategoryIndex = 0;
      _currentSubcategoryItems = [];
      _totalItems = 0;
      _completedItems = 0;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<ChecklistItem> _getDefaultChecklistItems() {
    final String category = widget.selectedCategory;

    // Data default untuk kategori Toilet
    if (category == "Toilet") {
      return [
        ChecklistItem(
          id: 'toilet_1',
          question: 'Toilet bersih dan tidak berbau',
          category: 'Toilet',
          subcategory: 'Kebersihan',
        ),
        ChecklistItem(
          id: 'toilet_2',
          question: 'Wastafel berfungsi dengan baik',
          category: 'Toilet',
          subcategory: 'Fasilitas',
        ),
        ChecklistItem(
          id: 'toilet_3',
          question: 'Toilet flush berfungsi dengan baik',
          category: 'Toilet',
          subcategory: 'Fasilitas',
        ),
        ChecklistItem(
          id: 'toilet_4',
          question: 'Tersedia sabun cuci tangan',
          category: 'Toilet',
          subcategory: 'Kelengkapan',
        ),
        ChecklistItem(
          id: 'toilet_5',
          question: 'Tersedia tisu toilet yang cukup',
          category: 'Toilet',
          subcategory: 'Kelengkapan',
        ),
        ChecklistItem(
          id: 'toilet_6',
          question: 'Lantai toilet kering dan tidak licin',
          category: 'Toilet',
          subcategory: 'Kebersihan',
        ),
      ];
    }

    // Data default untuk kategori lain (tambahkan sesuai kebutuhan)
    // ...

    // Default: kembalikan daftar kosong jika tidak ada yang cocok
    return [];
  }

  /// Navigates to a specific subcategory and section
  /// Note: In database terms, categoryIndex refers to subcategory and subcategoryIndex refers to section
  void _navigateToSubcategory(int categoryIndex, int subcategoryIndex) {
    if (categoryIndex >= _categoryNames.length) return;

    final category = _categoryNames[categoryIndex];
    final subcategories = _subcategoryNames[categoryIndex];

    // Special handling for Toilet category - always show all items
    if (widget.selectedCategory.toLowerCase() == "toilet") {
      setState(() {
        _currentCategoryIndex = categoryIndex;
        _currentSubcategoryIndex = subcategoryIndex;
        _currentSubcategoryItems = _checklistItems; // Use all toilet items
        _currentCategory = category;
        _currentSubcategory = "Toilet";
      });

      print(
        "Toilet navigation - showing ${_currentSubcategoryItems.length} items",
      );
      print(
        "Items: ${_currentSubcategoryItems.map((e) => e.question).toList()}",
      );

      _animationController.reset();
      _animationController.forward();
      return;
    }

    // Handle categories that don't have subcategories
    if (subcategories.isEmpty) {
      // For categories without subcategories, show all items in that category
      setState(() {
        _currentCategoryIndex = categoryIndex;
        _currentSubcategoryIndex = 0;
        _currentSubcategoryItems =
            _checklistItems.where((item) => item.category == category).toList();
        _currentCategory = category;
        _currentSubcategory = '';
      });

      _animationController.reset();
      _animationController.forward();
      return;
    }

    // Normal case: subcategory has sections
    if (subcategoryIndex >= subcategories.length) return;

    final subcategory = subcategories[subcategoryIndex];

    // For the new structure, get items from _checklist directly
    List<ChecklistItem> items = [];

    // If we have organized data in _checklist, use it
    if (categoryIndex < _checklist.length) {
      // Get all items from the subcategory, filtering by section if needed
      final allSubcategoryItems = _checklist[categoryIndex];

      // If this is a section selection (subcategoryIndex represents section index)
      // and we have grouped items by section, filter accordingly
      if (_groupedChecklistItems.isNotEmpty &&
          _groupedChecklistItems.containsKey(category) &&
          _groupedChecklistItems[category]!.containsKey(subcategory)) {
        items = _groupedChecklistItems[category]![subcategory]!;
        print(
          "Using grouped items for $category -> $subcategory: ${items.length} items",
        );
      } else {
        // Fallback: use all items from this subcategory
        items = allSubcategoryItems;
        print(
          "Using all subcategory items for $category: ${items.length} items",
        );
      }
    }

    // If still no items, try to filter from _checklistItems directly
    if (items.isEmpty && _checklistItems.isNotEmpty) {
      items =
          _checklistItems.where((item) {
            // For toilet or single category items
            if (widget.selectedCategory.toLowerCase() == "toilet") {
              return item.category.toLowerCase() == "toilet";
            }

            // For other categories, match by subcategory and section
            return item.subcategory == category &&
                (item.section == subcategory ||
                    (item.section?.isEmpty ?? true && subcategory == "Umum"));
          }).toList();
      print(
        "Fallback filter found ${items.length} items for $category -> $subcategory",
      );
    }

    // Scroll back to top when changing subcategories
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    setState(() {
      _currentCategoryIndex = categoryIndex;
      _currentSubcategoryIndex = subcategoryIndex;
      _currentSubcategoryItems = items;
      _currentCategory = category;
      _currentSubcategory = subcategory;
    });

    _animationController.reset();
    _animationController.forward();
  }

  void _handlePrevious() {
    if (_currentSubcategoryIndex > 0) {
      // Previous subcategory in same category
      _navigateToSubcategory(
        _currentCategoryIndex,
        _currentSubcategoryIndex - 1,
      );
    } else if (_currentCategoryIndex > 0) {
      // Last subcategory of previous category
      final prevCategorySubcategories =
          _subcategoryNames[_currentCategoryIndex - 1];
      // If the previous category has subcategories, navigate to the last one
      // Otherwise just navigate to the category itself (with subcategoryIndex 0)
      final prevSubcatIndex =
          prevCategorySubcategories.isEmpty
              ? 0
              : prevCategorySubcategories.length - 1;

      _navigateToSubcategory(_currentCategoryIndex - 1, prevSubcatIndex);
    }
  }

  void _handleNext() {
    // Check if all questions in current subcategory are answered or skipped
    final allCurrentAnsweredOrSkipped = _currentSubcategoryItems.every(
      (item) => item.answerValue != null || item.skipped == true,
    );

    if (!allCurrentAnsweredOrSkipped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap jawab atau skip semua pertanyaan terlebih dahulu.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final currentCategorySubcategories =
        _subcategoryNames[_currentCategoryIndex];

    if (currentCategorySubcategories.isEmpty ||
        _currentSubcategoryIndex >= currentCategorySubcategories.length - 1) {
      // We're at the end of current category's subcategories (or it has none)
      if (_currentCategoryIndex < _categoryNames.length - 1) {
        // Move to the first subcategory of the next category
        _navigateToSubcategory(_currentCategoryIndex + 1, 0);
      } else {
        // End of checklist
        _handleSaveChecklist();
      }
    } else {
      // Next subcategory in same category
      _navigateToSubcategory(
        _currentCategoryIndex,
        _currentSubcategoryIndex + 1,
      );
    }
  }

  void _handleAnswerChanged(ChecklistItem item, bool? value) {
    setState(() {
      item.answerValue = value;

      if (value == true && item.note != null) {
        item.note = null;
      }

      // Update completion status
      _updateCompletionStatus();
    });
  }

  void _handleNoteChanged(ChecklistItem item, String? value) {
    setState(() {
      item.note = value;
    });
  }

  /// Handles subcategory selection (database subcategory like grooming, sigap, etc.)
  void _handleCategorySelected(int index) {
    if (index == _currentCategoryIndex) return;
    _navigateToSubcategory(index, 0);
  }

  /// Handles section selection (database section like wajah & badan, rambut, etc.)
  void _handleSubcategorySelected(int index) {
    if (index == _currentSubcategoryIndex) return;
    _navigateToSubcategory(_currentCategoryIndex, index);
  }

  void _handleSaveChecklist() {
    // Ubah pengecekan untuk menerima pertanyaan yang di-skip
    final allAnswered = _checklistItems.every(
      (item) => item.answerValue != null || item.skipped == true,
    );

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap jawab atau skip semua pertanyaan sebelum menyimpan.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    // Hitung jumlah pertanyaan yang di-skip
    final skippedCount =
        _checklistItems.where((item) => item.skipped == true).length;
    final score = _checklistService.calculateScore(_checklistItems);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CompletionDialog(
            score: score,
            categoryName: widget.selectedCategory,
            hasEmployeeData: widget.employeeData != null,
            skippedCount: skippedCount, // Kirimkan jumlah yang di-skip
            onBackToDetails: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            onFinish: () {
              // Save checklist results then return to home
              // In a real app, you would save to local storage or API here
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final progress = _completedItems / (_totalItems > 0 ? _totalItems : 1);
    final isFirstItem =
        _currentCategoryIndex == 0 && _currentSubcategoryIndex == 0;
    final isLastItem =
        _currentCategoryIndex == _categoryNames.length - 1 &&
        _currentSubcategoryIndex ==
            (_categoryNames.isEmpty
                ? 0
                : _subcategoryNames[_currentCategoryIndex].length - 1);

    // All questions in current subcategory are answered or skipped
    final isValid = _currentSubcategoryItems.every(
      (item) => item.answerValue != null || item.skipped == true,
    );

    // Check if we should show the subcategory navigator (database subcategories)
    // Don't show for toilet category since it's simple
    final bool showCategoryNavigator =
        widget.selectedCategory.toLowerCase() != "toilet" &&
        (_categoryNames.length > 1 ||
            (_categoryNames.length == 1 &&
                _categoryNames[0] != 'Uncategorized'));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Updated Header section
              ChecklistHeader(
                bankName: widget.selectedBank,
                categoryName: widget.selectedCategory,
                date: widget.selectedDate,
                employeeData: widget.employeeData,
                progress: progress,
                onBackPressed: () => Navigator.pop(context),
              ),

              // Show empty state if no checklist items
              if (_checklistItems.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: AppSize.iconSize * 2,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: AppSize.heightPercent(2)),
                        Text(
                          'Tidak ada checklist untuk kategori ini',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.subtitleFontSize,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSize.heightPercent(1)),
                        Text(
                          'Silahkan pilih kategori lain atau hubungi administrator',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.bodyFontSize,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSize.heightPercent(4)),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back),
                          label: Text('Kembali'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSize.widthPercent(5),
                              vertical: AppSize.heightPercent(1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // CategoryNavigator: maps internal variables to correct database structure
                if (showCategoryNavigator)
                  CategoryNavigator(
                    subcategories:
                        _categoryNames, // _categoryNames actually contains subcategories from database
                    sections:
                        _subcategoryNames, // _subcategoryNames actually contains sections from database
                    currentSubcategoryIndex:
                        _currentCategoryIndex, // Maps to current subcategory in database
                    currentSectionIndex:
                        _currentSubcategoryIndex, // Maps to current section in database
                    onSubcategorySelected:
                        _handleCategorySelected, // Handler for subcategory selection
                    onSectionSelected:
                        _handleSubcategorySelected, // Handler for section selection
                    subcategoryCompletionStatus:
                        _categoryCompletionStatus, // Subcategory completion status
                    sectionCompletionStatus:
                        _subcategoryCompletionStatus, // Section completion status
                  ),

                // Questions list
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child:
                              _currentSubcategoryItems.isNotEmpty
                                  ? SubcategoryQuestions(
                                    key: ValueKey(
                                      '${_currentCategoryIndex}_${_currentSubcategoryIndex}_${_currentSubcategoryItems.length}',
                                    ),
                                    categoryName:
                                        widget.selectedCategory.toLowerCase() ==
                                                "toilet"
                                            ? "Toilet"
                                            : (showCategoryNavigator
                                                ? _currentCategory
                                                : ''),
                                    subcategoryName: _currentSubcategory,
                                    questions: _currentSubcategoryItems,
                                    onAnswerChanged: _handleAnswerChanged,
                                    onNoteChanged: _handleNoteChanged,
                                  )
                                  : Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        AppSize.widthPercent(8),
                                      ),
                                      child: Text(
                                        'Tidak ada pertanyaan untuk subkategori ini.',
                                        style: AppSize.getTextStyle(
                                          fontSize: AppSize.bodyFontSize,
                                          color: Colors.grey.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation controls
                NavigationControls(
                  isFirstItem: isFirstItem,
                  isLastItem: isLastItem,
                  isValid: isValid,
                  isAnimating: _animationController.isAnimating,
                  onPrevious: _handlePrevious,
                  onNext: _handleNext,
                  onSave: _handleSaveChecklist,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
