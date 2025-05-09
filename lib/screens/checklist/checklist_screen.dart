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

        // A subcategory is complete if all its items have an answer
        final isSubcategoryComplete = items.every(
          (item) => item.answerValue != null,
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

    // Update completed items count
    _completedItems =
        _checklistItems.where((item) => item.answerValue != null).length;
  }

  void _navigateToSubcategory(int categoryIndex, int subcategoryIndex) {
    if (categoryIndex >= _categoryNames.length) return;

    final category = _categoryNames[categoryIndex];
    final subcategories = _subcategoryNames[categoryIndex];

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
      _navigateToSubcategory(
        _currentCategoryIndex - 1,
        _subcategoryNames[_currentCategoryIndex - 1].length - 1,
      );
    }
  }

  void _handleNext() {
    // Check if all questions in current subcategory are answered
    final allCurrentAnswered = _currentSubcategoryItems.every(
      (item) => item.answerValue != null,
    );

    if (!allCurrentAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap jawab semua pertanyaan pada subkategori ini.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (_currentSubcategoryIndex <
        _subcategoryNames[_currentCategoryIndex].length - 1) {
      // Next subcategory in same category
      _navigateToSubcategory(
        _currentCategoryIndex,
        _currentSubcategoryIndex + 1,
      );
    } else if (_currentCategoryIndex < _categoryNames.length - 1) {
      // First subcategory of next category
      _navigateToSubcategory(_currentCategoryIndex + 1, 0);
    } else {
      // End of checklist
      _handleSaveChecklist();
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
    final allAnswered = _checklistItems.every(
      (item) => item.answerValue != null,
    );

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap jawab semua pertanyaan sebelum menyimpan.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final score = _checklistService.calculateScore(_checklistItems);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CompletionDialog(
            score: score,
            categoryName: widget.selectedCategory,
            hasEmployeeData: widget.employeeData != null,
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
            _subcategoryNames[_currentCategoryIndex].length - 1;

    // All questions in current subcategory are answered
    final isValid = _currentSubcategoryItems.every(
      (item) => item.answerValue != null,
    );

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

              // Category and subcategory navigation
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
                                  categoryName: _currentCategory,
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
          ),
        ),
      ),
    );
  }
}
