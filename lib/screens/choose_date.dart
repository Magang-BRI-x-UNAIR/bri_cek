import 'package:bri_cek/screens/choose_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';
import 'package:bri_cek/services/assessment_session_service.dart';

class ChooseDateScreen extends StatefulWidget {
  final String selectedBank;
  final String bankBranchId;

  const ChooseDateScreen({
    super.key,
    required this.selectedBank,
    required this.bankBranchId,
  });

  @override
  State<ChooseDateScreen> createState() => _ChooseDateScreenState();
}

class _ChooseDateScreenState extends State<ChooseDateScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  final AssessmentSessionService _assessmentSessionService =
      AssessmentSessionService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = AppSize.isSmallScreen;

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
                        // App title and logo
                        Row(
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

                        SizedBox(height: AppSize.heightPercent(4)),

                        // Main header text
                        Text(
                          "Pilih Tanggal",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(1)),
                        Text(
                          "Tanggal pemeriksaan bank",
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

            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.paddingHorizontal,
                  vertical: AppSize.heightPercent(2),
                ),
                child: Column(
                  children: [
                    // Selected Date Display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSize.heightPercent(2),
                        horizontal: AppSize.widthPercent(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSize.cardBorderRadius,
                        ),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tanggal terpilih:",
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: AppSize.heightPercent(0.5)),
                          Text(
                            _dateFormat.format(_selectedDate),
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.subtitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSize.heightPercent(3)),

                    // Calendar with improved styling
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSize.cardBorderRadius * 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppSize.widthPercent(2)),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                onSurface: Colors.black87,
                              ),
                            ),
                            child: CalendarDatePicker(
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              onDateChanged: (date) {
                                setState(() {
                                  _selectedDate = date;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSize.heightPercent(3)),

                    // Buttons with improved styling
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

                        // Next Button with improved styling
                        Expanded(
                          flex: 3,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  _isLoading
                                      ? null
                                      : () async {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        try {
                                          // Simpan data session ke Firestore
                                          final sessionId =
                                              await _assessmentSessionService
                                                  .createAssessmentSession(
                                                    bankBranchId:
                                                        widget.bankBranchId,
                                                    sessionDate: _selectedDate,
                                                  );

                                          setState(() {
                                            _isLoading = false;
                                          });

                                          // Navigasi ke layar pemilihan kategori dengan data yang diperlukan
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => ChooseCategoryScreen(
                                                    selectedBank:
                                                        widget.selectedBank,
                                                    selectedDate: _selectedDate,
                                                    bankBranchId:
                                                        widget
                                                            .bankBranchId, // Teruskan ID cabang
                                                    sessionId:
                                                        sessionId, // Teruskan ID sesi yang baru dibuat
                                                  ),
                                            ),
                                          );
                                        } catch (e) {
                                          setState(() {
                                            _isLoading = false;
                                          });

                                          // Tampilkan error
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
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
