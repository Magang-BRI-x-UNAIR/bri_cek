import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class ChooseDateScreen extends StatefulWidget {
  final String selectedBank;

  const ChooseDateScreen({super.key, required this.selectedBank});

  @override
  State<ChooseDateScreen> createState() => _ChooseDateScreenState();
}

class _ChooseDateScreenState extends State<ChooseDateScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = AppSize.isSmallScreen;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: AppSize.getHeaderPadding(),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                  bottom: Radius.circular(AppSize.cardBorderRadius * 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                          Text(
                            widget.selectedBank,
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.heightPercent(4)),
                  Text(
                    "Pilih Tanggal",
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSize.screenHeight * 0.02),

            // Calendar
            Expanded(
              child: Column(
                children: [
                  // Calendar Widget
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.paddingHorizontal,
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
                  SizedBox(height: AppSize.heightPercent(2)),

                  // Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.paddingHorizontal,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSize.heightPercent(1.5),
                              horizontal: AppSize.widthPercent(5),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Next Button
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the next page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSize.heightPercent(1.5),
                              horizontal: AppSize.widthPercent(5),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
