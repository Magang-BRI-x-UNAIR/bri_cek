import 'package:bri_cek/services/excel_export_service.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class CheckHistoryDetailScreen extends StatefulWidget {
  final BankCheckHistory history;
  final BankBranch branch;

  const CheckHistoryDetailScreen({
    super.key,
    required this.history,
    required this.branch,
  });

  @override
  State<CheckHistoryDetailScreen> createState() =>
      _CheckHistoryDetailScreenState();
}

class _CheckHistoryDetailScreenState extends State<CheckHistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  final ExcelExportService _excelExportService = ExcelExportService();

  // Define all the categories
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
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: AppSize.heightPercent(25),
              pinned: true,
              backgroundColor: Colors.blue.shade700,
              leading: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Add improved export button in the actions
              // actions: [
              //   Container(
              //     margin: EdgeInsets.only(right: AppSize.widthPercent(3)),
              //     decoration: BoxDecoration(
              //       color: Colors.green.shade500,
              //       borderRadius: BorderRadius.circular(
              //         AppSize.cardBorderRadius,
              //       ),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.2),
              //           blurRadius: 4,
              //           offset: Offset(0, 2),
              //         ),
              //       ],
              //     ),
              //     child: Material(
              //       color: Colors.transparent,
              //       child: InkWell(
              //         onTap: _exportToExcel,
              //         borderRadius: BorderRadius.circular(
              //           AppSize.cardBorderRadius,
              //         ),
              //         child: Padding(
              //           padding: EdgeInsets.symmetric(
              //             horizontal: AppSize.widthPercent(3),
              //             vertical: AppSize.heightPercent(0.8),
              //           ),
              //           child: Row(
              //             children: [
              //               Icon(
              //                 Icons.file_download,
              //                 color: Colors.white,
              //                 size: AppSize.iconSize * 0.8,
              //               ),
              //               SizedBox(width: AppSize.widthPercent(1)),
              //               Text(
              //                 'Export',
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: AppSize.smallFontSize,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Check History',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Branch Image with fade-in animation
                    Hero(
                      tag: 'branch_image_${widget.branch.id}',
                      child:
                          widget.branch.isLocalImage
                              ? Image.asset(
                                widget.branch.imageUrl,
                                fit: BoxFit.cover,
                              )
                              : Image.network(
                                widget.branch.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                    ),

                    // Enhanced gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.4, 0.6, 1.0],
                        ),
                      ),
                    ),

                    // Header content overlay with improved layout
                    Positioned(
                      left: AppSize.paddingHorizontal,
                      right: AppSize.paddingHorizontal,
                      bottom: AppSize.heightPercent(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Branch name with enhanced style
                          Text(
                            widget.branch.name,
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.subtitleFontSize * 1.1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: AppSize.heightPercent(0.8)),

                          // Date row with redesigned badge
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSize.widthPercent(2),
                                  vertical: AppSize.heightPercent(0.5),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade500.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius * 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.white,
                                      size: AppSize.iconSize * 0.7,
                                    ),
                                    SizedBox(width: AppSize.widthPercent(1)),
                                    Text(
                                      _dateFormat.format(
                                        widget.history.checkDate,
                                      ),
                                      style: AppSize.getTextStyle(
                                        fontSize: AppSize.smallFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: AppSize.widthPercent(1.5)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSize.widthPercent(2),
                                  vertical: AppSize.heightPercent(0.5),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius * 0.8,
                                  ),
                                ),
                                child: Text(
                                  'Week ${widget.history.weekNumberInMonth}',
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.smallFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppSize.heightPercent(1.5)),

                          // Score and checker info row with enhanced design
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Overall score with improved visualization
                              _buildEnhancedScoreDisplay(
                                widget.history.score,
                                'Overall Score',
                              ),

                              // Checked by info with enhanced styling
                              Container(
                                padding: EdgeInsets.all(
                                  AppSize.widthPercent(2),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Checked by',
                                      style: AppSize.getTextStyle(
                                        fontSize: AppSize.smallFontSize * 0.9,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: AppSize.iconSize * 0.7,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: AppSize.widthPercent(1),
                                        ),
                                        Text(
                                          widget.history.checkedBy,
                                          style: AppSize.getTextStyle(
                                            fontSize: AppSize.bodyFontSize,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Improved Tab Bar for categories
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.blue.shade700,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: Colors.blue.shade700,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize * 0.95,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs:
                      _categories.map<Tab>((category) {
                        return Tab(
                          icon: Icon(category['icon']),
                          text: category['name'],
                        );
                      }).toList(),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children:
              _categories.map((category) {
                // Get the aspect score for this category if available
                final aspectName = category['name'];
                final double aspectScore = widget.history.getAspectScore(
                  aspectName,
                );

                return _buildCategoryTabContent(aspectName, aspectScore);
              }).toList(),
        ),
      ),
      // Add a more visible floating export button as an alternative
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportToExcel,
        backgroundColor: Colors.green.shade600,
        icon: Icon(Icons.file_download, color: Colors.white),
        label: Text(
          'Export to Excel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Enhanced score display with animation effects
  Widget _buildEnhancedScoreDisplay(double score, String label) {
    // Determine color based on score
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green.shade400;
    } else if (score >= 65) {
      scoreColor = Colors.orange.shade400;
    } else {
      scoreColor = Colors.red.shade400;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(2),
        vertical: AppSize.heightPercent(0.7),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated score circle
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: score / 100),
            duration: Duration(seconds: 1),
            builder: (context, double value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: AppSize.widthPercent(11),
                    width: AppSize.widthPercent(11),
                    child: CircularProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: scoreColor,
                      strokeWidth: 4.5,
                    ),
                  ),
                  // Score text
                  Text(
                    score.toStringAsFixed(0),
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.subtitleFontSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(width: AppSize.widthPercent(1.5)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize * 0.9,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 2),
              Text(
                _getScoreLabel(score),
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  fontWeight: FontWeight.w500,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to get score label
  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    return 'Needs Improvement';
  }

  Widget _buildCategoryTabContent(String categoryName, double score) {
    // Mock checklist data for each category
    final List<Map<String, dynamic>> checklistItems = _getMockChecklistItems(
      categoryName,
    );

    return Padding(
      padding: EdgeInsets.all(AppSize.paddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Category score card
          Container(
            padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Category icon with gradient background
                Container(
                  padding: EdgeInsets.all(AppSize.widthPercent(2)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade500, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(
                      AppSize.cardBorderRadius,
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(categoryName),
                    size: AppSize.iconSize,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSize.widthPercent(3)),

                // Category name and score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: AppSize.heightPercent(0.5)),
                      Text(
                        'Category Score',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score circle with enhanced animation
                _buildEnhancedCategoryScoreCircle(score),
              ],
            ),
          ),

          SizedBox(height: AppSize.heightPercent(2)),

          // Improved checklist items heading with count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Checklist Items',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.widthPercent(2),
                  vertical: AppSize.heightPercent(0.3),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${checklistItems.length} items',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize * 0.9,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSize.heightPercent(1)),

          // Improved checklist items list with animations
          Expanded(
            child:
                checklistItems.isEmpty
                    ? _buildEmptyChecklistState(categoryName)
                    : ListView.builder(
                      itemCount: checklistItems.length,
                      itemBuilder: (context, index) {
                        final item = checklistItems[index];
                        // Add animation for list items
                        return AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 100),
                              ),
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 20),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildEnhancedChecklistItem(item),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Enhanced score circle with animation
  Widget _buildEnhancedCategoryScoreCircle(double score) {
    // Determine color based on score
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 65) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      height: AppSize.widthPercent(14),
      width: AppSize.widthPercent(14),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: score / 100),
        duration: Duration(seconds: 1),
        curve: Curves.easeOutCubic,
        builder: (context, double value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                height: AppSize.widthPercent(14),
                width: AppSize.widthPercent(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
              ),
              // Progress indicator
              CircularProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                color: scoreColor,
                strokeWidth: 8,
              ),
              // Score display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    'points',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.smallFontSize * 0.8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Enhanced checklist item with better visual design
  Widget _buildEnhancedChecklistItem(Map<String, dynamic> item) {
    final IconData statusIcon =
        item['completed'] ? Icons.check_circle : Icons.cancel;
    final Color statusColor =
        item['completed'] ? Colors.green : Colors.red.shade400;
    final String statusText = item['completed'] ? 'Completed' : 'Not Completed';

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.heightPercent(1)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: item['completed'] ? Colors.green.shade50 : Colors.red.shade50,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: AppSize.iconSize * 0.9,
                ),
                SizedBox(width: AppSize.widthPercent(2)),
                Expanded(
                  child: Text(
                    item['description'],
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.bodyFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.widthPercent(2),
                    vertical: AppSize.heightPercent(0.2),
                  ),
                  decoration: BoxDecoration(
                    color:
                        item['completed']
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: AppSize.smallFontSize * 0.8,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (item['note'] != null) ...[
              SizedBox(height: AppSize.heightPercent(0.8)),
              Container(
                padding: EdgeInsets.all(AppSize.widthPercent(2)),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      color: Colors.grey.shade500,
                      size: AppSize.iconSize * 0.7,
                    ),
                    SizedBox(width: AppSize.widthPercent(1.5)),
                    Expanded(
                      child: Text(
                        '${item['note']}',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Enhanced empty state visualization
  Widget _buildEmptyChecklistState(String categoryName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(5)),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_box_outline_blank,
              size: AppSize.iconSize * 2,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: AppSize.heightPercent(2)),
          Text(
            'No checklist data available',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize * 1.1,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.heightPercent(0.5)),
          Text(
            'No items found for $categoryName category',
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSize.heightPercent(3)),
          TextButton.icon(
            onPressed: () {
              // This could refresh data in a real app
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Refreshing data...')));
            },
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.widthPercent(4),
                vertical: AppSize.heightPercent(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get category icon
  IconData _getCategoryIcon(String categoryName) {
    final category = _categories.firstWhere(
      (c) => c['name'] == categoryName,
      orElse: () => {'name': categoryName, 'icon': Icons.check_box},
    );
    return category['icon'];
  }

  // Add this method to handle Excel export with enhanced UX
  Future<void> _exportToExcel() async {
    // Show enhanced loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: AppSize.heightPercent(7),
                  width: AppSize.heightPercent(7),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Preparing Excel Export',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSize.bodyFontSize * 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait while we prepare your file...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: AppSize.smallFontSize,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // First generate the Excel file
      final filePath = await _excelExportService.generateExcelFile(
        widget.history,
        widget.branch,
        _categories,
      );

      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (filePath == null) {
        _showExportErrorDialog(
          'Failed to create Excel file. Please try again.',
        );
      } else {
        // Show options dialog
        _showExportOptionsDialog(filePath);
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Show detailed error message
      _showExportErrorDialog('Error: ${e.toString()}');
    }
  }

  // Show options dialog for the exported file
  void _showExportOptionsDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: AppSize.iconSize * 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Excel File Ready',
                  style: TextStyle(
                    fontSize: AppSize.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 24),

                // Share button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Share.shareXFiles([
                      XFile(filePath),
                    ], text: 'BRI Check Report for ${widget.branch.name}');
                  },
                  icon: Icon(Icons.share),
                  label: Text('Share Excel File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // Save to device button
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Save the file to downloads or another location
                    String?
                    savedPath = await _excelExportService.saveToDownloads(
                      filePath,
                      'BRI_Check_${widget.branch.name.replaceAll(' ', '_')}_${DateFormat('yyyy-MM-dd').format(widget.history.checkDate)}.xlsx',
                    );

                    if (savedPath != null) {
                      _showSaveSuccessDialog(savedPath);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save file to device'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.save_alt),
                  label: Text('Save to Device'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // Cancel button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show success dialog for saved file
  // Show success dialog for saved file with an option to open it
  void _showSaveSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: AppSize.iconSize * 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'File Saved',
                  style: TextStyle(
                    fontSize: AppSize.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Excel file successfully saved at:',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    filePath,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      fontSize: AppSize.smallFontSize,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    // Open File Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openFile(filePath);
                        },
                        icon: Icon(Icons.open_in_new),
                        label: Text('Open File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Done button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to open the Excel file
  Future<void> _openFile(String filePath) async {
    try {
      // Add this import to the top of the file if not already there:
      // import 'package:open_file/open_file.dart';

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        // If there was an error opening the file
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the file: ${result.message}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: AppSize.heightPercent(8),
              left: AppSize.widthPercent(4),
              right: AppSize.widthPercent(4),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: AppSize.heightPercent(8),
            left: AppSize.widthPercent(4),
            right: AppSize.widthPercent(4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Enhanced error dialog
  void _showExportErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: AppSize.iconSize * 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Export Failed',
                    style: TextStyle(
                      fontSize: AppSize.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(message, style: TextStyle(color: Colors.grey.shade700)),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Possible solutions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildSolutionItem(
                        '1. Check app permissions in Settings',
                        Icons.security,
                      ),
                      SizedBox(height: 6),
                      _buildSolutionItem(
                        '2. Allow storage access for this app',
                        Icons.folder,
                      ),
                      SizedBox(height: 6),
                      _buildSolutionItem(
                        '3. Make sure device has available storage',
                        Icons.storage,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          openAppSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Open Settings'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSolutionItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: AppSize.iconSize * 0.7, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSize.smallFontSize,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to get mock checklist items (existing implementation is fine)
  List<Map<String, dynamic>> _getMockChecklistItems(String categoryName) {
    // Your existing implementation is good, keep it as is
    if (categoryName == 'Satpam') {
      return [
        {
          'description': 'Berpakaian sesuai dengan ketentuan',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Menggunakan atribut lengkap',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Memberikan salam kepada nasabah',
          'completed': false,
          'note': 'Perlu pelatihan tentang standar greeting',
        },
        {
          'description': 'Mengarahkan nasabah sesuai kebutuhan',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Sikap siap dan sigap',
          'completed': true,
          'note': null,
        },
      ];
    } else if (categoryName == 'Teller') {
      return [
        {
          'description': 'Berpakaian rapi dan profesional',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Menggunakan name tag',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Memberikan salam kepada nasabah',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Melayani dengan efisien',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Konfirmasi transaksi kepada nasabah',
          'completed': false,
          'note': 'Terkadang lupa mengkonfirmasi',
        },
      ];
    }
    // Continue with your existing implementation for other categories
    // ...

    return [];
  }
}

// Delegate for the persistent tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      // Remove the color property since it's included in the decoration
      child: tabBar,
      decoration: BoxDecoration(
        color: Colors.white, // Color is included here in the decoration
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
