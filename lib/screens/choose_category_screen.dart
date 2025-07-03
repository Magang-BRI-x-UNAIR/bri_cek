import 'package:bri_cek/screens/checklist/checklist_screen.dart';
import 'package:bri_cek/screens/employee_info_screen.dart';
import 'package:bri_cek/services/survey_result_service.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';

class ChooseCategoryScreen extends StatefulWidget {
  final String selectedBank;
  final DateTime selectedDate;
  final String bankBranchId; // Pastikan parameter ini ada
  final String sessionId;

  const ChooseCategoryScreen({
    super.key,
    required this.selectedBank,
    required this.selectedDate,
    required this.bankBranchId,
    required this.sessionId,
  });

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  final SurveyResultService _surveyResultService = SurveyResultService();
  String? _selectedCategory;
  Map<String, String> _categoryStatus = {};
  bool _isLoadingStatus = true;

  // Define the categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Satpam', 'icon': Icons.security},
    {'name': 'Teller', 'icon': Icons.person},
    {'name': 'Customer Service', 'icon': Icons.support_agent},
    {'name': 'Banking Hall', 'icon': Icons.business},
    {'name': 'Gallery e-Channel', 'icon': Icons.devices},
    {'name': 'Fasad Gedung', 'icon': Icons.apartment},
    {'name': 'Ruang BRIMEN', 'icon': Icons.meeting_room},
    {'name': 'Toilet', 'icon': Icons.wc},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategoryStatus();
  }

  Future<void> _loadCategoryStatus() async {
    try {
      setState(() {
        _isLoadingStatus = true;
      });

      final categoryNames =
          _categories.map((cat) => cat['name'] as String).toList();

      final status = await _surveyResultService.getCategoryStatusForDate(
        bankName: widget.selectedBank,
        selectedDate: widget.selectedDate,
        categories: categoryNames,
      );

      setState(() {
        _categoryStatus = status;
        _isLoadingStatus = false;
      });
    } catch (e) {
      print('Error loading category status: $e');
      setState(() {
        _isLoadingStatus = false;
        // Set all categories to default status on error
        for (var category in _categories) {
          _categoryStatus[category['name']] = 'default';
        }
      });
    }
  }

  Color _getCategoryBackgroundColor(String categoryName, bool isSelected) {
    if (isSelected) {
      return Colors.blue.shade50;
    }

    final status = _categoryStatus[categoryName] ?? 'default';
    switch (status) {
      case 'completed':
        return Colors.green.shade50;
      case 'partial':
        return Colors.yellow.shade50;
      default:
        return Colors.white;
    }
  }

  Color _getCategoryBorderColor(String categoryName, bool isSelected) {
    if (isSelected) {
      return Colors.blue.shade400;
    }

    final status = _categoryStatus[categoryName] ?? 'default';
    switch (status) {
      case 'completed':
        return Colors.green.shade400;
      case 'partial':
        return Colors.yellow.shade600;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getCategoryIconColor(String categoryName, bool isSelected) {
    if (isSelected) {
      return Colors.blue.shade600;
    }

    final status = _categoryStatus[categoryName] ?? 'default';
    switch (status) {
      case 'completed':
        return Colors.green.shade600;
      case 'partial':
        return Colors.yellow.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getCategoryTextColor(String categoryName, bool isSelected) {
    if (isSelected) {
      return Colors.blue.shade700;
    }

    final status = _categoryStatus[categoryName] ?? 'default';
    switch (status) {
      case 'completed':
        return Colors.green.shade700;
      case 'partial':
        return Colors.yellow.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildStatusIndicator(String categoryName) {
    final status = _categoryStatus[categoryName] ?? 'default';

    switch (status) {
      case 'completed':
        return Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
        );
      case 'partial':
        return Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time, color: Colors.white, size: 16),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: AppSize.widthPercent(1)),
        Text(
          label,
          style: AppSize.getTextStyle(
            fontSize: AppSize.bodyFontSize * 0.8,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header with consistent styling
            Container(
              width: double.infinity,
              height: AppSize.heightPercent(21),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF2680C5),
                    Color(0xFF3D91D1),
                    Color(0xFFF37021),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
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

                  // Header content
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSize.widthPercent(6),
                      top: AppSize.heightPercent(2),
                      right: AppSize.widthPercent(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App title and info row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Bank info section
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      AppSize.widthPercent(2),
                                    ),
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

                        SizedBox(height: AppSize.heightPercent(4)),

                        // Main header text
                        Text(
                          "Pilih Kategori",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(1)),
                        Text(
                          "Silahkan pilih area yang ingin Anda periksa",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.bodyFontSize,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Category Selection
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal,
                  vertical: AppSize.heightPercent(2),
                ),
                child: Column(
                  children: [
                    // Legend section
                    Container(
                      margin: EdgeInsets.only(bottom: AppSize.heightPercent(1)),
                      padding: EdgeInsets.all(AppSize.widthPercent(3)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Survey:',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize * 0.9,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: AppSize.heightPercent(0.5)),
                          Row(
                            children: [
                              _buildLegendItem(
                                Colors.green.shade600,
                                'Selesai',
                              ),
                              SizedBox(width: AppSize.widthPercent(4)),
                              _buildLegendItem(
                                Colors.orange.shade600,
                                'Sebagian',
                              ),
                              SizedBox(width: AppSize.widthPercent(4)),
                              _buildLegendItem(
                                Colors.grey.shade600,
                                'Belum Mulai',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Categories grid
                    Expanded(
                      child:
                          _isLoadingStatus
                              ? const Center(child: CircularProgressIndicator())
                              : RefreshIndicator(
                                onRefresh: _loadCategoryStatus,
                                child: GridView.builder(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSize.heightPercent(1),
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: AppSize.widthPercent(
                                          4,
                                        ),
                                        mainAxisSpacing: AppSize.heightPercent(
                                          2,
                                        ),
                                        childAspectRatio: 1.2,
                                      ),
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    final categoryName =
                                        category['name'] as String;
                                    final isSelected =
                                        _selectedCategory == categoryName;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = categoryName;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getCategoryBackgroundColor(
                                            categoryName,
                                            isSelected,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          border: Border.all(
                                            color: _getCategoryBorderColor(
                                              categoryName,
                                              isSelected,
                                            ),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  isSelected
                                                      ? Colors.blue.withOpacity(
                                                        0.2,
                                                      )
                                                      : _getCategoryBorderColor(
                                                        categoryName,
                                                        false,
                                                      ).withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  category['icon'],
                                                  color: _getCategoryIconColor(
                                                    categoryName,
                                                    isSelected,
                                                  ),
                                                  size: AppSize.iconSize * 1.2,
                                                ),
                                                SizedBox(
                                                  height: AppSize.heightPercent(
                                                    1,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: Text(
                                                    categoryName,
                                                    style: AppSize.getTextStyle(
                                                      fontSize:
                                                          AppSize
                                                              .subtitleFontSize *
                                                          0.85,
                                                      fontWeight:
                                                          isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight.w500,
                                                      color:
                                                          _getCategoryTextColor(
                                                            categoryName,
                                                            isSelected,
                                                          ),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            _buildStatusIndicator(categoryName),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    ),

                    SizedBox(height: AppSize.heightPercent(2)),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button with improved styling
                        Expanded(
                          flex: 2,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(
                                AppSize.cardBorderRadius,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.shade700,
                                      Colors.grey.shade600,
                                    ],
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
                                      SizedBox(
                                        width: AppSize.widthPercent(1.5),
                                      ),
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
                        ),

                        SizedBox(width: AppSize.widthPercent(4)),

                        // Continue Button with improved styling
                        Expanded(
                          flex: 3,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  _selectedCategory != null
                                      ? () {
                                        // Check which category was selected
                                        if ([
                                          'Satpam',
                                          'Teller',
                                          'Customer Service',
                                        ].contains(_selectedCategory)) {
                                          // Navigate to employee info screen for people-related categories
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => EmployeeInfoScreen(
                                                    selectedBank:
                                                        widget.selectedBank,
                                                    selectedDate:
                                                        widget.selectedDate,
                                                    selectedCategory:
                                                        _selectedCategory!,
                                                    bankBranchId:
                                                        widget
                                                            .bankBranchId, // Teruskan dari widget
                                                    sessionId: widget.sessionId,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          // Navigate directly to checklist screen for location-based categories
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ChecklistScreen(
                                                    selectedBank:
                                                        widget.selectedBank,
                                                    selectedDate:
                                                        widget.selectedDate,
                                                    selectedCategory:
                                                        _selectedCategory!,
                                                    bankBranchId:
                                                        widget
                                                            .bankBranchId, // Tambahkan ini
                                                    sessionId:
                                                        widget
                                                            .sessionId, // Tambahkan ini
                                                    // Employee data is null for non-people categories
                                                    employeeData: null,
                                                    fetchFromDatabase: true,
                                                  ),
                                            ),
                                          );
                                        }
                                      }
                                      : null, // Disable if no category selected
                              borderRadius: BorderRadius.circular(
                                AppSize.cardBorderRadius,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        _selectedCategory != null
                                            ? [
                                              Colors.blue.shade500,
                                              Colors.blue.shade700,
                                            ]
                                            : [
                                              Colors.grey.shade400,
                                              Colors.grey.shade500,
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
                                          _selectedCategory != null
                                              ? Colors.blue.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.2),
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
                                        'Lanjutkan',
                                        style: AppSize.getTextStyle(
                                          fontSize: AppSize.bodyFontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: AppSize.widthPercent(1.5),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_rounded,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
