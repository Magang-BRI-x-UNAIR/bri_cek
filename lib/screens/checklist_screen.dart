import 'package:bri_cek/data/checklist_item_data.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/utils/app_size.dart';
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

class _ChecklistScreenState extends State<ChecklistScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  List<ChecklistItem> _checklistItems = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final List<GlobalKey<FormState>> _formKeys = [];

  // For overall progress
  double get _progress => (_currentIndex + 1) / _checklistItems.length;

  @override
  void initState() {
    super.initState();
    _loadChecklistItems();
  }

  Future<void> _loadChecklistItems() async {
    // In a real app, this might be an async API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _checklistItems = getChecklistForCategory(widget.selectedCategory);

      // Generate form keys for each item
      for (int i = 0; i < _checklistItems.length; i++) {
        _formKeys.add(GlobalKey<FormState>());
      }

      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header with consistent styling
            _buildHeader(),

            // Checklist Content
            _isLoading
                ? _buildLoadingState()
                : Expanded(
                  child: Column(
                    children: [
                      // Progress indicator
                      _buildProgressIndicator(),

                      // Checklist questions
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _checklistItems.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildQuestionPage(index);
                          },
                        ),
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
    // Dynamically adjust header height based on whether employee data exists
    final double headerHeight =
        widget.employeeData != null
            ? AppSize.heightPercent(
              28,
            ) // Lebih tinggi untuk header dengan info karyawan
            : AppSize.heightPercent(
              21,
            ); // Tinggi standar untuk header kategori lain

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
            top: AppSize.heightPercent(10),
            left: AppSize.widthPercent(20),
            size: AppSize.widthPercent(13),
            opacity: 0.3,
          ),
          _buildCloudDecoration(
            top: AppSize.heightPercent(3),
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

          // Header content - wrapping in SingleChildScrollView for extra safety
          SingleChildScrollView(
            physics:
                NeverScrollableScrollPhysics(), // Prevents actual scrolling
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSize.widthPercent(6),
                top: AppSize.heightPercent(2),
                right: AppSize.widthPercent(6),
                bottom: AppSize.heightPercent(
                  2,
                ), // Add bottom padding for safety
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Important for proper sizing
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

                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.widthPercent(3),
                      vertical: AppSize.heightPercent(0.5),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppSize.cardBorderRadius,
                      ),
                    ),
                    child: Text(
                      widget.selectedCategory,
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Employee info if available - using more compact layout
                  if (widget.employeeData != null) ...[
                    SizedBox(height: AppSize.heightPercent(1.5)),
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

                  SizedBox(height: AppSize.heightPercent(1)),

                  // Title - using more concise text for employee categories
                  Text(
                    widget.employeeData != null
                        ? "Checklist ${widget.selectedCategory}"
                        : "Checklist ${widget.selectedCategory}",
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSize.heightPercent(0.5)),
                  Text(
                    _isLoading
                        ? "Memuat daftar pertanyaan..."
                        : "Pertanyaan ${_currentIndex + 1} dari ${_checklistItems.length}",
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

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.paddingHorizontal,
        vertical: AppSize.heightPercent(1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.5)),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue.shade700,
            minHeight: AppSize.heightPercent(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final item = _checklistItems[index];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.paddingHorizontal),
      child: Form(
        key: _formKeys[index],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question card
              Container(
                padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.widthPercent(2.5),
                        vertical: AppSize.heightPercent(0.3),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Pertanyaan ${index + 1}',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSize.heightPercent(1)),

                    // Question text
                    Text(
                      item.question,
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    SizedBox(height: AppSize.heightPercent(2)),

                    // Options
                    Column(
                      children:
                          item.options.map((option) {
                            final isSelected =
                                item.answerValue == (option == 'Ya');
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: AppSize.heightPercent(1),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue.shade400
                                          : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSize.cardBorderRadius,
                                ),
                                color:
                                    isSelected
                                        ? Colors.blue.shade50
                                        : Colors.white,
                              ),
                              child: RadioListTile<bool>(
                                title: Text(
                                  option,
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.bodyFontSize,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade800,
                                  ),
                                ),
                                value: option == 'Ya',
                                groupValue: item.answerValue,
                                activeColor: Colors.blue.shade700,
                                onChanged: (value) {
                                  setState(() {
                                    item.answerValue = value;
                                  });
                                },
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSize.widthPercent(3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    SizedBox(height: AppSize.heightPercent(1)),

                    // Note field
                    if (item.allowsNote) ...[
                      Text(
                        'Catatan (opsional):',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: AppSize.heightPercent(0.5)),
                      TextFormField(
                        initialValue: item.note,
                        onChanged: (value) {
                          setState(() {
                            item.note = value;
                          });
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan catatan jika perlu',
                          hintStyle: AppSize.getTextStyle(
                            fontSize: AppSize.smallFontSize,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSize.cardBorderRadius,
                            ),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSize.cardBorderRadius,
                            ),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSize.cardBorderRadius,
                            ),
                            borderSide: BorderSide(color: Colors.blue.shade400),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastQuestion = _currentIndex == _checklistItems.length - 1;

    return Padding(
      padding: EdgeInsets.all(AppSize.paddingHorizontal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (visible if not first question)
          _currentIndex > 0
              ? Expanded(
                flex: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
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
                  final currentItem = _checklistItems[_currentIndex];

                  // If item is required and not answered, show validation message
                  if (currentItem.isRequired &&
                      currentItem.answerValue == null) {
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

                  // If last question, submit the form
                  if (isLastQuestion) {
                    _submitChecklist();
                  } else {
                    // Else, go to next question
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isLastQuestion
                            ? Colors.green.shade500
                            : Colors.blue.shade500,
                        isLastQuestion
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
                            isLastQuestion
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
                          isLastQuestion ? 'Selesai' : 'Lanjutkan',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.bodyFontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppSize.widthPercent(1.5)),
                        Icon(
                          isLastQuestion
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

    for (var item in _checklistItems) {
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
    for (var item in _checklistItems) {
      if (item.answerValue == true) positiveAnswers++;
    }

    final score = (positiveAnswers / _checklistItems.length) * 100;

    // In real app, you would save the results to database here

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(score),
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
          Icon(
            isPassing ? Icons.check_circle : Icons.warning,
            color: isPassing ? Colors.green : Colors.amber,
            size: AppSize.iconSize * 2,
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
          // Score display
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: AppSize.widthPercent(25),
                height: AppSize.widthPercent(25),
                child: CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: isPassing ? Colors.green : Colors.amber,
                  strokeWidth: 10,
                ),
              ),
              Column(
                children: [
                  Text(
                    '$scoreInt%',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: isPassing ? Colors.green : Colors.amber,
                    ),
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
          ),

          SizedBox(height: AppSize.heightPercent(2)),

          // Results summary
          Text(
            isPassing
                ? 'Checklist ${widget.selectedCategory} telah selesai dengan hasil yang baik.'
                : 'Checklist ${widget.selectedCategory} memerlukan perhatian lebih lanjut.',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
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
