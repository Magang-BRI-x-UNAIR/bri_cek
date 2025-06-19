import 'package:bri_cek/screens/checklist/checklist_screen.dart';
import 'package:bri_cek/screens/employee_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';

class ChooseCategoryScreen extends StatefulWidget {
  final String selectedBank;
  final DateTime selectedDate;
  final String bankBranchId; // Tambahkan parameter ini
  final String sessionId; // Tambahkan parameter ini

  const ChooseCategoryScreen({
    super.key,
    required this.selectedBank,
    required this.selectedDate,
    required this.bankBranchId, // Tambahkan parameter ini
    required this.sessionId, // Tambahkan parameter ini
  });

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  String? _selectedCategory;

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
                    // Categories grid
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSize.heightPercent(1),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSize.widthPercent(4),
                          mainAxisSpacing: AppSize.heightPercent(2),
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected =
                              _selectedCategory == category['name'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category['name'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.blue.shade50
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.blue.shade400
                                          : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        isSelected
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    category['icon'],
                                    color:
                                        isSelected
                                            ? Colors.blue.shade600
                                            : Colors.grey.shade700,
                                    size: AppSize.iconSize * 1.2,
                                  ),
                                  SizedBox(height: AppSize.heightPercent(1)),
                                  Text(
                                    category['name'],
                                    style: AppSize.getTextStyle(
                                      fontSize: AppSize.subtitleFontSize * 0.85,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                      color:
                                          isSelected
                                              ? Colors.blue.shade700
                                              : Colors.grey.shade800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: AppSize.heightPercent(2)),

                    // Continue button
                    Container(
                      width: double.infinity,
                      height: AppSize.heightPercent(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _selectedCategory != null
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.transparent,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
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
                                              (context) => EmployeeInfoScreen(
                                                selectedBank:
                                                    widget.selectedBank,
                                                selectedDate:
                                                    widget.selectedDate,
                                                selectedCategory:
                                                    _selectedCategory!,
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
                                                // Employee data is null for non-people categories
                                                employeeData: null,
                                              ),
                                        ),
                                      );
                                    }
                                  }
                                  : null, // Disable if no category selected
                          borderRadius: BorderRadius.circular(15),
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
                                          Colors.grey.shade300,
                                          Colors.grey.shade400,
                                        ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                'Lanjutkan',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _selectedCategory != null
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
