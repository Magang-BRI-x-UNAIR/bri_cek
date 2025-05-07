import 'dart:math' as Math;

import 'package:bri_cek/data/checklist_item_data.dart';
import 'package:bri_cek/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:bri_cek/widgets/category_indicators.dart';
import 'package:bri_cek/widgets/checklist_question_card.dart';
import 'package:intl/intl.dart';

class ChecklistScreen extends StatefulWidget {
  final String selectedBank;
  final DateTime selectedDate;
  final String selectedCategory;
  final Map<String, dynamic>? employeeData; // Optional - for people categories

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
  // Tambahkan controller dan variabel untuk animasi
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;

  // Tipe transisi untuk next/previous
  bool _isForward = true;

  // Function to get filtered checklist items based on current employee data
  List<ChecklistItem> _getFilteredChecklistItems() {
    // If no employee data, return all items
    if (widget.employeeData == null) return _checklistItems;

    // Get gender from employee data
    final bool isWoman = widget.employeeData!['gender'] == 'Wanita';

    // Here we should add logic to determine if employee wears hijab
    // For this example, let's assume we add this data to employeeData
    final bool hasHijab = widget.employeeData!['hasHijab'] == true;

    // Get current uniform type - in real app you might want to determine this by day or other logic
    // For this example, let's use a default or get from some configuration
    final String currentUniformType =
        widget.employeeData!['uniformType'] ?? 'Korporat';

    // Filter items based on gender, hijab, and uniform type
    return _checklistItems.where((item) {
      // Skip items that are gender-specific and don't match
      if (item.question.startsWith('Wanita:') && !isWoman) return false;
      if (item.question.startsWith('Pria:') && isWoman) return false;

      // Skip items based on hijab
      if (item.forHijab == true && !hasHijab) return false;
      if (item.forHijab == false && hasHijab) return false;

      // Skip items that are uniform-specific if they don't match current uniform
      if (item.uniformType.isNotEmpty &&
          !item.uniformType.contains(currentUniformType))
        return false;

      return true;
    }).toList();
  }

  // Group items by category and subcategory
  Map<String, Map<String, List<ChecklistItem>>> _getGroupedItems() {
    final filteredItems = _getFilteredChecklistItems();
    final Map<String, Map<String, List<ChecklistItem>>> groupedItems = {};

    for (var item in filteredItems) {
      // Create category map if it doesn't exist
      if (!groupedItems.containsKey(item.category)) {
        groupedItems[item.category] = {};
      }

      // Create subcategory list if it doesn't exist
      if (!groupedItems[item.category]!.containsKey(item.subcategory)) {
        groupedItems[item.category]![item.subcategory] = [];
      }

      // Add item to its category and subcategory
      groupedItems[item.category]![item.subcategory]!.add(item);
    }

    return groupedItems;
  }

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  List<ChecklistItem> _checklistItems = [];
  Map<String, Map<String, List<ChecklistItem>>> _groupedChecklistItems = {};
  bool _isLoading = true;
  int _currentCategoryIndex = 0;
  int _currentSubcategoryIndex = 0;
  int _currentItemIndex = 0;

  // For storing category and subcategory names in order
  List<String> _categoryNames = [];
  List<List<String>> _subcategoryNames = [];

  // For tracking current item
  ChecklistItem? _currentItem;

  // For form validation
  final _formKey = GlobalKey<FormState>();

  // For overall progress calculation
  int _totalItems = 0;
  int _completedItems = 0;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi controller dengan durasi lebih cepat
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    // Animasi slide dan fade - percepat timing
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _loadChecklistItems();
  }

  Future<void> _loadChecklistItems() async {
    // In a real app, this might be an async API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      // Get checklist items for the selected category
      _checklistItems = getChecklistForCategory(widget.selectedCategory);

      // Filter and group items
      _groupedChecklistItems = _getGroupedItems();

      // Extract ordered category and subcategory names
      _categoryNames = _groupedChecklistItems.keys.toList();

      _subcategoryNames =
          _categoryNames.map((category) {
            return _groupedChecklistItems[category]!.keys.toList();
          }).toList();

      // Calculate total number of items for progress tracking
      _totalItems = _getFilteredChecklistItems().length;

      // Set initial current item if available
      if (_categoryNames.isNotEmpty &&
          _subcategoryNames.isNotEmpty &&
          _subcategoryNames[0].isNotEmpty) {
        _currentItem =
            _groupedChecklistItems[_categoryNames[0]]![_subcategoryNames[0][0]]![0];
      }

      _isLoading = false;

      // Play animasi di awal
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate progress based on completed items
  double get _progress => _totalItems > 0 ? _completedItems / _totalItems : 0;

  // Helper to get current subcategory items
  List<ChecklistItem> _getCurrentSubcategoryItems() {
    if (_currentCategoryIndex >= _categoryNames.length ||
        _currentSubcategoryIndex >=
            _subcategoryNames[_currentCategoryIndex].length) {
      return [];
    }

    final category = _categoryNames[_currentCategoryIndex];
    final subcategory =
        _subcategoryNames[_currentCategoryIndex][_currentSubcategoryIndex];

    return _groupedChecklistItems[category]![subcategory]!;
  }

  // Navigate to the next item, subcategory, or category
  void _goToNextItem() {
    final currentSubcategoryItems = _getCurrentSubcategoryItems();

    // Set arah animasi ke forward (dari kanan ke kiri)
    _isForward = true;

    // Reset dan putar animasi untuk transisi
    _animationController.reset();

    if (_currentItemIndex < currentSubcategoryItems.length - 1) {
      // More items in current subcategory
      setState(() {
        _currentItemIndex++;
        _currentItem = currentSubcategoryItems[_currentItemIndex];
      });

      // Mulai animasi
      _animationController.forward();
    } else if (_currentSubcategoryIndex <
        _subcategoryNames[_currentCategoryIndex].length - 1) {
      // Move to next subcategory
      setState(() {
        _currentSubcategoryIndex++;
        _currentItemIndex = 0;
        _currentItem = _getCurrentSubcategoryItems()[0];
      });

      // Mulai animasi
      _animationController.forward();
    } else if (_currentCategoryIndex < _categoryNames.length - 1) {
      // Move to next category
      setState(() {
        _currentCategoryIndex++;
        _currentSubcategoryIndex = 0;
        _currentItemIndex = 0;
        _currentItem = _getCurrentSubcategoryItems()[0];
      });

      // Mulai animasi
      _animationController.forward();
    } else {
      // At the end - show summary
      _submitChecklist();
    }
  }

  // Navigate to the previous item
  void _goToPreviousItem() {
    // Set arah animasi ke backward (dari kiri ke kanan)
    _isForward = false;

    // Reset dan putar animasi untuk transisi
    _animationController.reset();

    if (_currentItemIndex > 0) {
      // Previous item in current subcategory
      setState(() {
        _currentItemIndex--;
        _currentItem = _getCurrentSubcategoryItems()[_currentItemIndex];
      });

      // Mulai animasi
      _animationController.forward();
    } else if (_currentSubcategoryIndex > 0) {
      // Move to previous subcategory
      setState(() {
        _currentSubcategoryIndex--;
        final items = _getCurrentSubcategoryItems();
        _currentItemIndex = items.length - 1;
        _currentItem = items[_currentItemIndex];
      });

      // Mulai animasi
      _animationController.forward();
    } else if (_currentCategoryIndex > 0) {
      // Move to previous category
      setState(() {
        _currentCategoryIndex--;
        _currentSubcategoryIndex =
            _subcategoryNames[_currentCategoryIndex].length - 1;
        final items = _getCurrentSubcategoryItems();
        _currentItemIndex = items.length - 1;
        _currentItem = items[_currentItemIndex];
      });

      // Mulai animasi
      _animationController.forward();
    }
  }

  // Check if we're at the last item overall
  bool get _isLastItem {
    return _currentCategoryIndex == _categoryNames.length - 1 &&
        _currentSubcategoryIndex ==
            _subcategoryNames[_currentCategoryIndex].length - 1 &&
        _currentItemIndex == _getCurrentSubcategoryItems().length - 1;
  }

  // Check if we're at the first item overall
  bool get _isFirstItem {
    return _currentCategoryIndex == 0 &&
        _currentSubcategoryIndex == 0 &&
        _currentItemIndex == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            _buildHeader(),

            // Checklist Content
            _isLoading
                ? _buildLoadingState()
                : Expanded(
                  child: Column(
                    children: [
                      // Padding yang lebih efisien
                      SizedBox(height: AppSize.heightPercent(0.5)),

                      // Progress indicator
                      ProgressIndicatorWidget(progress: _progress),

                      // Category indicators
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: child,
                          );
                        },
                        child: CategoryIndicators(
                          categoryNames: _categoryNames,
                          subcategoryNames: _subcategoryNames,
                          currentCategoryIndex: _currentCategoryIndex,
                          currentSubcategoryIndex: _currentSubcategoryIndex,
                        ),
                      ),

                      // Question card
                      Expanded(
                        child:
                            _currentItem != null
                                ? AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    // Slide dan fade animation
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin:
                                            _isForward
                                                ? Offset(
                                                  0.3,
                                                  0,
                                                ) // Dari kanan ke kiri
                                                : Offset(
                                                  -0.3,
                                                  0,
                                                ), // Dari kiri ke kanan
                                        end: Offset.zero,
                                      ).animate(_animation),
                                      child: FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: QuestionCard(
                                    item: _currentItem!,
                                    questionNumber: _completedItems + 1,
                                    formKey: _formKey,
                                    onAnswerChanged: (value) {
                                      setState(() {
                                        _currentItem!.answerValue = value;
                                      });
                                    },
                                    onNoteChanged: (value) {
                                      setState(() {
                                        _currentItem!.note = value;
                                      });
                                    },
                                  ),
                                )
                                : Center(child: Text('No questions available')),
                      ),

                      // Navigation buttons
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Memperkecil ukuran header
    final double headerHeight =
        widget.employeeData != null
            ? AppSize.heightPercent(24) // Lebih kecil dari sebelumnya (28)
            : AppSize.heightPercent(20); // Lebih kecil dari sebelumnya (21)

    return Container(
      width: double.infinity,
      height: headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF2680C5), Color(0xFF3D91D1), Color(0xFFF37021)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Cloud decorations
          _buildCloudDecoration(
            top: AppSize.heightPercent(17),
            left: AppSize.widthPercent(70),
            size: AppSize.widthPercent(10),
            opacity: 0.3,
          ),
          _buildCloudDecoration(
            top: AppSize.heightPercent(5),
            left: AppSize.widthPercent(42),
            size: AppSize.widthPercent(12),
            opacity: 0.2,
          ),
          _buildCloudDecoration(
            top: AppSize.heightPercent(8),
            left: AppSize.widthPercent(90),
            size: AppSize.widthPercent(15),
            opacity: 0.2,
          ),

          // Header content
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSize.widthPercent(6),
                top: AppSize.heightPercent(2),
                right: AppSize.widthPercent(6),
                bottom: AppSize.heightPercent(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bank info and date row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bank info section
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSize.widthPercent(2)),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  AppSize.cardBorderRadius,
                                ),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: Colors.white,
                                size: AppSize.iconSize,
                              ),
                            ),
                            SizedBox(width: AppSize.widthPercent(2)),
                            Expanded(
                              child: Text(
                                widget.selectedBank,
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.subtitleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: AppSize.widthPercent(2)),

                      // Date display
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSize.widthPercent(2),
                            vertical: AppSize.heightPercent(1),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppSize.cardBorderRadius,
                            ),
                          ),
                          child: Text(
                            _dateFormat.format(widget.selectedDate),
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.smallFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSize.heightPercent(1.5)),

                  // Title
                  Text(
                    "Checklist",
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Employee info if available
                  if (widget.employeeData != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.widthPercent(3),
                        vertical: AppSize.heightPercent(0.8),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          AppSize.cardBorderRadius,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.employeeData!['gender'] == 'Pria'
                                ? Icons.person
                                : Icons.person_2,
                            color: Colors.white,
                            size: AppSize.iconSize * 0.8,
                          ),
                          SizedBox(width: AppSize.widthPercent(1.5)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.employeeData!['name'],
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "ID: ${widget.employeeData!['id']} | ${widget.employeeData!['gender']}",
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.smallFontSize,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: AppSize.heightPercent(0.5)),
                  Text(
                    _isLoading
                        ? "Memuat daftar pertanyaan..."
                        : "Pertanyaan ${_completedItems + 1} dari ${_totalItems}",
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.bodyFontSize,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudDecoration({
    required double top,
    required double left,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.cloud,
        color: Colors.white.withOpacity(opacity),
        size: size,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue.shade700),
            SizedBox(height: AppSize.heightPercent(2)),
            Text(
              'Memuat pertanyaan checklist...',
              style: AppSize.getTextStyle(
                fontSize: AppSize.bodyFontSize,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.all(AppSize.paddingHorizontal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (visible if not first question)
          !_isFirstItem
              ? Expanded(
                flex: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _goToPreviousItem,
                    borderRadius: BorderRadius.circular(
                      AppSize.cardBorderRadius,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade700, Colors.grey.shade600],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSize.cardBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSize.heightPercent(2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: AppSize.iconSize * 0.8,
                              color: Colors.white,
                            ),
                            SizedBox(width: AppSize.widthPercent(1.5)),
                            Text(
                              'Kembali',
                              style: AppSize.getTextStyle(
                                fontSize: AppSize.bodyFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              : SizedBox(width: AppSize.widthPercent(2)),

          SizedBox(width: AppSize.widthPercent(2)),

          // Next/Submit button
          Expanded(
            flex: 3,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Get current item
                  if (_currentItem == null) return;

                  // If item is required and not answered, show validation message
                  if (_currentItem!.isRequired &&
                      _currentItem!.answerValue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Silahkan pilih jawaban terlebih dahulu'),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSize.cardBorderRadius,
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  // Update completed items count if the current item has been answered
                  if (_currentItem!.answerValue != null) {
                    setState(() {
                      _completedItems = Math.min(
                        _completedItems + 1,
                        _totalItems,
                      );
                    });
                  }

                  // If last question, submit the form
                  if (_isLastItem) {
                    _submitChecklist();
                  } else {
                    // Else, go to next question
                    _goToNextItem();
                  }
                },
                borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _isLastItem
                            ? Colors.green.shade500
                            : Colors.blue.shade500,
                        _isLastItem
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppSize.cardBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _isLastItem
                                ? Colors.green.withOpacity(0.3)
                                : Colors.blue.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSize.heightPercent(2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLastItem ? 'Selesai' : 'Lanjutkan',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.bodyFontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppSize.widthPercent(1.5)),
                        Icon(
                          _isLastItem
                              ? Icons.check_circle
                              : Icons.arrow_forward_rounded,
                          size: AppSize.iconSize * 0.8,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitChecklist() {
    // Count completed and required questions
    int totalAnswered = 0;
    int totalRequired = 0;

    List<ChecklistItem> filteredItems = _getFilteredChecklistItems();

    for (var item in filteredItems) {
      if (item.isRequired) totalRequired++;
      if (item.answerValue != null) totalAnswered++;
    }

    // Check if all required questions are answered
    if (totalRequired > totalAnswered) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masih ada pertanyaan yang belum dijawab'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          ),
        ),
      );
      return;
    }

    // Calculate score - in real app, you might have a more complex calculation
    int positiveAnswers = 0;
    for (var item in filteredItems) {
      if (item.answerValue == true) positiveAnswers++;
    }

    final score =
        filteredItems.isEmpty
            ? 0
            : (positiveAnswers / filteredItems.length) * 100;

    // In real app, you would save the results to database here

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(score.toDouble()),
    );
  }

  Widget _buildCompletionDialog(double score) {
    final scoreInt = score.toInt();
    final bool isPassing = scoreInt >= 75;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
      ),
      title: Column(
        children: [
          // Animasi ikon dengan scaling tapi tanpa rotasi untuk warning icon
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 500), // Dipercepat dari 800ms
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child:
                    isPassing
                        ? Transform.rotate(
                          // Rotasi hanya untuk ikon sukses, tidak untuk warning
                          angle: value * 2 * 3.14 * 0.05,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: AppSize.iconSize * 2,
                          ),
                        )
                        : Icon(
                          Icons.warning,
                          color: Colors.amber,
                          size: AppSize.iconSize * 2,
                        ),
              );
            },
          ),
          SizedBox(height: AppSize.heightPercent(1)),
          Text(
            isPassing ? 'Checklist Selesai' : 'Checklist Perlu Perhatian',
            style: AppSize.getTextStyle(
              fontSize: AppSize.subtitleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score display dengan animasi (percepat)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score / 100),
            duration: Duration(milliseconds: 800), // Dipercepat dari 1500ms
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: AppSize.widthPercent(25),
                    height: AppSize.widthPercent(25),
                    child: CircularProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey.shade200,
                      color: isPassing ? Colors.green : Colors.amber,
                      strokeWidth: 10,
                    ),
                  ),
                  Column(
                    children: [
                      // Animasi counter score (percepat)
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: scoreInt),
                        duration: Duration(
                          milliseconds: 600,
                        ), // Dipercepat dari 1200ms
                        builder: (context, value, child) {
                          return Text(
                            '$value%',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: isPassing ? Colors.green : Colors.amber,
                            ),
                          );
                        },
                      ),
                      Text(
                        'Score',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          SizedBox(height: AppSize.heightPercent(2)),

          // Results summary dengan animasi fade in (percepat)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 400), // Dipercepat dari 800ms
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  isPassing
                      ? 'Checklist ${widget.selectedCategory} telah selesai dengan hasil yang baik.'
                      : 'Checklist ${widget.selectedCategory} memerlukan perhatian lebih lanjut.',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Return to bank details screen (2 levels up)
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Close checklist screen
            if (widget.employeeData != null) {
              Navigator.of(
                context,
              ).pop(); // Also close employee screen if exists
            }
          },
          child: Text(
            'Kembali ke Detail Bank',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            // Close all screens and return to choose bank
            Navigator.of(context).popUntil(
              (route) => route.isFirst || route.settings.name == '/choose_bank',
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
            ),
          ),
          child: Text('Selesai'),
        ),
      ],
    );
  }
}
