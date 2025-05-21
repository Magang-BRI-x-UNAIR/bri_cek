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

class ChecklistScreen extends StatefulWidget {
  final String selectedBank;
  final DateTime selectedDate;
  final String selectedCategory;
  final Map<String, dynamic>? employeeData;

  const ChecklistScreen({
    super.key,
    required this.selectedBank,
    required this.selectedDate,
    required this.selectedCategory,
    this.employeeData,
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
  List<String> _categoryNames = [];
  List<List<String>> _subcategoryNames = [];
  List<ChecklistItem> _currentSubcategoryItems = [];
  int _currentCategoryIndex = 0;
  int _currentSubcategoryIndex = 0;
  int _totalItems = 0;
  int _completedItems = 0;
  final _formKey = GlobalKey<FormState>();
  List<bool> _categoryCompletionStatus = [];
  List<List<bool>> _subcategoryCompletionStatus = [];
  String _currentCategory = '';
  String _currentSubcategory = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadChecklistItems();
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
