import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
// import 'package:bri_cek/screens/checklist_screen.dart';
import 'package:intl/intl.dart';

class EmployeeInfoScreen extends StatefulWidget {
  final String selectedBank;
  final DateTime selectedDate;
  final String selectedCategory;

  const EmployeeInfoScreen({
    super.key,
    required this.selectedBank,
    required this.selectedDate,
    required this.selectedCategory,
  });

  @override
  State<EmployeeInfoScreen> createState() => _EmployeeInfoScreenState();
}

class _EmployeeInfoScreenState extends State<EmployeeInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  // Employee data controllers
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  String? _selectedGender;
  final List<String> _genderOptions = ['Pria', 'Wanita'];

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
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
            Container(
              width: double.infinity,
              height: AppSize.heightPercent(24),
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

                        SizedBox(height: AppSize.heightPercent(1)),

                        // Main header text
                        Text(
                          "Data ${widget.selectedCategory}",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(1)),
                        Text(
                          "Silahkan isi data ${widget.selectedCategory} yang akan disurvei",
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

            // Employee Info Form
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal,
                  vertical: AppSize.heightPercent(2),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Form Fields
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name Field
                              _buildFormLabel('Nama'),
                              _buildTextFormField(
                                controller: _nameController,
                                hintText:
                                    'Masukkan nama ${widget.selectedCategory.toLowerCase()}',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: AppSize.heightPercent(2)),

                              // ID Field
                              _buildFormLabel('ID Karyawan'),
                              _buildTextFormField(
                                controller: _idController,
                                hintText: 'Masukkan ID karyawan',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ID Karyawan tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: AppSize.heightPercent(2)),

                              // Gender Selection
                              _buildFormLabel('Jenis Kelamin'),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius,
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  children:
                                      _genderOptions.map((gender) {
                                        return RadioListTile<String>(
                                          title: Text(gender),
                                          value: gender,
                                          groupValue: _selectedGender,
                                          activeColor: Colors.blue.shade700,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedGender = value;
                                            });
                                          },
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSize.heightPercent(2)),

                      // Navigation Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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

                          // Next Button
                          Expanded(
                            flex: 3,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate() &&
                                      _selectedGender != null) {
                                    // Create employee data map
                                    final employeeData = {
                                      'name': _nameController.text,
                                      'id': _idController.text,
                                      'gender': _selectedGender,
                                      'position': widget.selectedCategory,
                                    };

                                    // Navigate to checklist screen with employee data
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => ChecklistScreen(
                                    //       selectedBank: widget.selectedBank,
                                    //       selectedDate: widget.selectedDate,
                                    //       selectedCategory: widget.selectedCategory,
                                    //       employeeData: employeeData,
                                    //     ),
                                    //   ),
                                    // );
                                  } else if (_selectedGender == null) {
                                    // Show error for gender selection
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Silahkan pilih jenis kelamin',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppSize.cardBorderRadius,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(
                                  AppSize.cardBorderRadius,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade500,
                                        Colors.blue.shade700,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSize.cardBorderRadius,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSize.widthPercent(1),
        bottom: AppSize.heightPercent(1),
      ),
      child: Text(
        label,
        style: AppSize.getTextStyle(
          fontSize: AppSize.subtitleFontSize,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppSize.getTextStyle(
          fontSize: AppSize.bodyFontSize,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSize.widthPercent(4),
          vertical: AppSize.heightPercent(2),
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
