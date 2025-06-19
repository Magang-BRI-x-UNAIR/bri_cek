import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/screens/checklist/widgets/category_navigator.dart';
import 'package:bri_cek/screens/checklist/widgets/checklist_header.dart';
import 'package:bri_cek/screens/checklist/widgets/completion_dialog.dart';
import 'package:bri_cek/screens/checklist/widgets/navigation_controls.dart';
import 'package:bri_cek/screens/checklist/widgets/subcategory_questions.dart';
import 'package:bri_cek/services/checklist_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/data/checklist_item_data.dart';
import 'package:bri_cek/services/assessment_session_service.dart';
import 'package:bri_cek/services/question_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isSaving = false;

  // State variables
  bool _isLoading = true;
  List<ChecklistItem> _checklistItems = [];
  Map<String, Map<String, List<ChecklistItem>>> _groupedChecklistItems = {};
  List<String> _categoryNames = [];
  List<List<String>> _subcategoryNames = [];
  List<ChecklistItem> _currentSubcategoryItems = [];
  List<List<ChecklistItem>> _checklist = [];
  int _currentCategoryIndex = 0;
  int _currentSubcategoryIndex = 0;
  int _totalItems = 0;
  int _completedItems = 0;
  final _formKey = GlobalKey<FormState>();
  List<bool> _categoryCompletionStatus = [];
  List<List<bool>> _subcategoryCompletionStatus = [];
  String _currentCategory = '';
  String _currentSubcategory = '';

  final QuestionService _questionService = QuestionService();
  final AssessmentSessionService _assessmentSessionService =
      AssessmentSessionService();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Selalu ambil dari database untuk kategori Toilet
    if (widget.selectedCategory == "Toilet" || widget.fetchFromDatabase) {
      _fetchChecklistItems();
    } else {
      _loadDefaultChecklistItems();
    }
    _setupAnimations();
    _loadChecklistItems();
  }

  Future<void> _fetchChecklistItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<ChecklistItem> items = [];

      // Ambil pertanyaan dari Firestore berdasarkan kategori yang dipilih
      String categoryId = widget.selectedCategory.toLowerCase().replaceAll(
        ' ',
        '_',
      );

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
        }
      } else {
        // Untuk kategori lain, gunakan metode umum
        final questionItems = await _questionService.getQuestionsForPath(
          mainCategory: categoryId,
          subcategory: categoryId,
        );

        if (questionItems.isNotEmpty) {
          items = questionItems;
        } else {
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
    }
  }

  void _organizeChecklistItems(List<ChecklistItem> items) {
    // Reset data yang ada
    _categoryNames = [];
    _subcategoryNames = [];
    _checklist = [];
    _checklistItems = items;

    // Case khusus untuk Toilet atau kategori sederhana lainnya
    if (widget.selectedCategory == "Toilet") {
      // Jika tidak ada item, gunakan kategori default
      if (items.isEmpty) {
        _categoryNames = ["Toilet"];
        _subcategoryNames = [
          ["Umum"],
        ];
        _checklist = [[]];
        _currentCategoryIndex = 0;
        _currentSubcategoryIndex = 0;
        _currentSubcategoryItems = [];
        return;
      }

      // Mengelompokkan items berdasarkan subcategory
      Map<String, List<ChecklistItem>> subcategoryMap = {};

      for (var item in items) {
        String subcategory =
            item.subcategory.isNotEmpty ? item.subcategory : "Umum";
        if (!subcategoryMap.containsKey(subcategory)) {
          subcategoryMap[subcategory] = [];
        }
        subcategoryMap[subcategory]!.add(item);
      }

      // Menggunakan satu kategori untuk Toilet
      _categoryNames = ["Toilet"];

      // Subkategori adalah keys dari subcategoryMap
      _subcategoryNames = [subcategoryMap.keys.toList()];

      // Bentuk checklist structure
      List<List<ChecklistItem>> subcategorizedItems = [];
      for (var subcategory in _subcategoryNames[0]) {
        subcategorizedItems.add(subcategoryMap[subcategory]!);
      }

      _checklist = [subcategorizedItems.expand((e) => e).toList()];

      // Set indeks awal
      _currentCategoryIndex = 0;
      _currentSubcategoryIndex = 0;
      _currentSubcategoryItems =
          _checklist.isNotEmpty && _checklist[0].isNotEmpty
              ? _checklist[0]
              : [];

      return;
    }

    // Untuk kategori lain yang lebih kompleks
    // Kelompokkan berdasarkan category dan subcategory
    Map<String, Map<String, List<ChecklistItem>>> categoryMap = {};

    for (var item in items) {
      String category = item.category;
      String subcategory =
          item.subcategory.isNotEmpty ? item.subcategory : "Umum";

      // Inisialisasi jika belum ada
      if (!categoryMap.containsKey(category)) {
        categoryMap[category] = {};
      }
      if (!categoryMap[category]!.containsKey(subcategory)) {
        categoryMap[category]![subcategory] = [];
      }

      // Tambahkan item ke subkategori yang sesuai
      categoryMap[category]![subcategory]!.add(item);
    }

    // Bentuk struktur data yang dibutuhkan
    _categoryNames = categoryMap.keys.toList();

    for (var category in _categoryNames) {
      List<String> subCategories = categoryMap[category]!.keys.toList();
      _subcategoryNames.add(subCategories);

      List<ChecklistItem> categoryItems = [];
      for (var subcategory in subCategories) {
        categoryItems.addAll(categoryMap[category]![subcategory]!);
      }

      _checklist.add(categoryItems);
    }

    // Set indeks awal jika ada data
    if (_categoryNames.isNotEmpty) {
      _currentCategoryIndex = 0;
      _currentSubcategoryIndex = 0;
      _currentSubcategoryItems = _checklist.isNotEmpty ? _checklist[0] : [];
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

  void _loadChecklistItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = getChecklistForCategory(widget.selectedCategory);
      final filteredItems = _checklistService.getFilteredItems(
        items,
        widget.employeeData,
      );

      if (filteredItems.isEmpty) {
        setState(() {
          _checklistItems = [];
          _groupedChecklistItems = {};
          _categoryNames = [];
          _subcategoryNames = [];
          _isLoading = false;
        });
        return;
      }

      final groupedItems = _checklistService.groupItems(filteredItems);

      setState(() {
        _checklistItems = filteredItems;
        _groupedChecklistItems = groupedItems;
        _categoryNames = groupedItems.keys.toList();

        if (_categoryNames.isNotEmpty) {
          _subcategoryNames =
              _categoryNames
                  .map((category) => groupedItems[category]!.keys.toList())
                  .toList();

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

          // Navigate to first subcategory
          _navigateToSubcategory(0, 0);

          _totalItems = filteredItems.length;
          _completedItems =
              filteredItems.where((item) => item.answerValue != null).length;

          // Update completion status
          _updateCompletionStatus();
        }
      });
    } catch (e) {
      print('Error loading checklist items: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        final items = _groupedChecklistItems[category]![subcategory]!;

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

  void _navigateToSubcategory(int categoryIndex, int subcategoryIndex) {
    if (categoryIndex >= _categoryNames.length) return;

    final category = _categoryNames[categoryIndex];
    final subcategories = _subcategoryNames[categoryIndex];

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

    // Normal case: category has subcategories
    if (subcategoryIndex >= subcategories.length) return;

    final subcategory = subcategories[subcategoryIndex];
    final items = _groupedChecklistItems[category]![subcategory]!;

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

  void _handleCategorySelected(int index) {
    if (index == _currentCategoryIndex) return;
    _navigateToSubcategory(index, 0);
  }

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

    // Check if we should show the category navigator
    final bool showCategoryNavigator =
        _categoryNames.length > 1 ||
        (_categoryNames.length == 1 && _categoryNames[0] != 'Uncategorized');

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
                // Only show Category navigator if we have multiple categories or one non-uncategorized category
                if (showCategoryNavigator)
                  CategoryNavigator(
                    categories: _categoryNames,
                    subcategories: _subcategoryNames,
                    currentCategoryIndex: _currentCategoryIndex,
                    currentSubcategoryIndex: _currentSubcategoryIndex,
                    onCategorySelected: _handleCategorySelected,
                    onSubcategorySelected: _handleSubcategorySelected,
                    categoryCompletionStatus: _categoryCompletionStatus,
                    subcategoryCompletionStatus: _subcategoryCompletionStatus,
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
                                    categoryName:
                                        showCategoryNavigator
                                            ? _currentCategory
                                            : '',
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
