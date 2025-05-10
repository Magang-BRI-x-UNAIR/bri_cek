import 'package:bri_cek/utils/app_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChecklistHeader extends StatelessWidget {
  final String bankName;
  final String categoryName;
  final DateTime date;
  final Map<String, dynamic>? employeeData;
  final double progress;
  final VoidCallback onBackPressed;

  const ChecklistHeader({
    Key? key,
    required this.bankName,
    required this.categoryName,
    required this.date,
    this.employeeData,
    required this.progress,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
    final String employeeName = employeeData?['name'] ?? '';

    return Container(
      width: double.infinity,
      height: AppSize.heightPercent(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF2680C5), Color(0xFF3D91D1), Color(0xFFF37021)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
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
              bottom: AppSize.heightPercent(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with back button, bank name and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and Bank/Category info
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onBackPressed,
                              borderRadius: BorderRadius.circular(
                                AppSize.cardBorderRadius,
                              ),
                              child: Container(
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
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: AppSize.iconSize * 0.8,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: AppSize.widthPercent(3)),

                          // Bank and Category names
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bank name
                                Text(
                                  bankName,
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.subtitleFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Category name
                                Text(
                                  categoryName,
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.smallFontSize,
                                    fontWeight: FontWeight.w500,
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

                    // Date display
                    Container(
                      margin: EdgeInsets.only(left: AppSize.widthPercent(2)),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.widthPercent(2.5),
                        vertical: AppSize.heightPercent(0.8),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppSize.cardBorderRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white,
                            size: AppSize.iconSize * 0.7,
                          ),
                          SizedBox(width: AppSize.widthPercent(1)),
                          Text(
                            _dateFormat.format(date),
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.smallFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSize.heightPercent(1.3)),

                // Main header text
                Text(
                  "Checklist ${categoryName}",
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Employee name below the main header
                if (employeeData != null && employeeName.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: AppSize.heightPercent(0.8)),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                          size: AppSize.iconSize * 0.7,
                        ),
                        SizedBox(width: AppSize.widthPercent(1)),
                        Text(
                          employeeName,
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.smallFontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Progress indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.smallFontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.smallFontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.heightPercent(0.5)),
                    Stack(
                      children: [
                        // Background
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Progress
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          height: 8,
                          width:
                              MediaQuery.of(context).size.width *
                              progress *
                              0.88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
}
