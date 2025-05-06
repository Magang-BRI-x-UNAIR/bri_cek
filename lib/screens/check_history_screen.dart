import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';

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
                    // Branch Image
                    widget.branch.isLocalImage
                        ? Image.asset(widget.branch.imageUrl, fit: BoxFit.cover)
                        : Image.network(
                          widget.branch.imageUrl,
                          fit: BoxFit.cover,
                        ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),

                    // Header content overlay
                    Positioned(
                      left: AppSize.paddingHorizontal,
                      right: AppSize.paddingHorizontal,
                      bottom: AppSize.heightPercent(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Branch name
                          Text(
                            widget.branch.name,
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.subtitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: AppSize.heightPercent(0.5)),

                          // Date row with badge
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: AppSize.iconSize * 0.8,
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
                                    AppSize.cardBorderRadius,
                                  ),
                                ),
                                child: Text(
                                  _dateFormat.format(widget.history.checkDate),
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.smallFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSize.widthPercent(1.5)),
                              Text(
                                '(Week ${widget.history.weekNumberInMonth})',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppSize.heightPercent(1)),

                          // Score and checker info row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Overall score
                              _buildScoreDisplay(
                                widget.history.score,
                                'Overall Score',
                              ),

                              // Checked by info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Checked by:',
                                    style: AppSize.getTextStyle(
                                      fontSize: AppSize.smallFontSize,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar for categories
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.blue.shade700,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: Colors.blue.shade700,
                  labelStyle: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize,
                    fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildScoreDisplay(double score, String label) {
    // Determine color based on score
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green.shade400;
    } else if (score >= 65) {
      scoreColor = Colors.orange.shade400;
    } else {
      scoreColor = Colors.red.shade400;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Score circle
            Container(
              height: AppSize.widthPercent(9),
              width: AppSize.widthPercent(9),
              child: CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: scoreColor,
                strokeWidth: 4.0,
              ),
            ),
            // Score text
            Text(
              score.toStringAsFixed(0),
              style: AppSize.getTextStyle(
                fontSize: AppSize.bodyFontSize * 0.9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(width: AppSize.widthPercent(1.5)),
        Text(
          label,
          style: AppSize.getTextStyle(
            fontSize: AppSize.smallFontSize,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabContent(String categoryName, double score) {
    // Mock checklist data for each category - in a real app, this would come from your database
    final List<Map<String, dynamic>> checklistItems = _getMockChecklistItems(
      categoryName,
    );

    return Padding(
      padding: EdgeInsets.all(AppSize.paddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category score card
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
            child: Row(
              children: [
                // Category icon
                Icon(
                  _getCategoryIcon(categoryName),
                  size: AppSize.iconSize,
                  color: Colors.blue.shade700,
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

                // Score circle
                _buildCategoryScoreCircle(score),
              ],
            ),
          ),

          SizedBox(height: AppSize.heightPercent(2)),

          // Checklist items heading
          Text(
            'Checklist Items',
            style: AppSize.getTextStyle(
              fontSize: AppSize.subtitleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          SizedBox(height: AppSize.heightPercent(1)),

          // Checklist items list
          Expanded(
            child:
                checklistItems.isEmpty
                    ? _buildEmptyChecklistState(categoryName)
                    : ListView.builder(
                      itemCount: checklistItems.length,
                      itemBuilder: (context, index) {
                        final item = checklistItems[index];
                        return _buildChecklistItem(item);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScoreCircle(double score) {
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
      height: AppSize.widthPercent(13),
      width: AppSize.widthPercent(13),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            color: scoreColor,
            strokeWidth: 8,
          ),
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
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item) {
    final IconData statusIcon =
        item['completed'] ? Icons.check_circle : Icons.cancel;
    final Color statusColor =
        item['completed'] ? Colors.green : Colors.red.shade400;

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.heightPercent(1)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          item['description'],
          style: AppSize.getTextStyle(
            fontSize: AppSize.bodyFontSize,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle:
            item['note'] != null
                ? Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Note: ${item['note']}',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.smallFontSize,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildEmptyChecklistState(String categoryName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_box_outline_blank,
            size: AppSize.iconSize * 2,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: AppSize.heightPercent(1)),
          Text(
            'No checklist data available for $categoryName',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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

  // Helper method to get mock checklist items
  List<Map<String, dynamic>> _getMockChecklistItems(String categoryName) {
    // In a real app, you'd fetch this data from your database
    // Here we're creating mock data for demonstration

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
    } else if (categoryName == 'Customer Service') {
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
          'description': 'Memberikan salam dan sapaan',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Mendengarkan keluhan dengan baik',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Memberikan solusi yang tepat',
          'completed': true,
          'note': null,
        },
      ];
    } else if (categoryName == 'Banking Hall') {
      return [
        {
          'description': 'Area bersih dan rapi',
          'completed': true,
          'note': null,
        },
        {'description': 'Pencahayaan memadai', 'completed': true, 'note': null},
        {
          'description': 'Suhu ruangan nyaman',
          'completed': false,
          'note': 'AC perlu disetel ulang',
        },
        {
          'description': 'Kursi tunggu memadai',
          'completed': true,
          'note': null,
        },
        {'description': 'Tersedia air minum', 'completed': true, 'note': null},
      ];
    } else if (categoryName == 'Toilet') {
      return [
        {'description': 'Lantai bersih', 'completed': true, 'note': null},
        {
          'description': 'Wastafel berfungsi dengan baik',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Tersedia sabun dan tissue',
          'completed': false,
          'note': 'Tissue perlu diisi ulang',
        },
        {
          'description': 'Kloset dalam kondisi baik',
          'completed': true,
          'note': null,
        },
        {
          'description': 'Tidak berbau tidak sedap',
          'completed': true,
          'note': null,
        },
      ];
    }

    // Default empty list for categories without specific mock data
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
    return Container(color: Colors.white, child: tabBar);
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
