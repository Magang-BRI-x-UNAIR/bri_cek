import 'package:bri_cek/services/excel_export_service.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/models/checklist_item.dart';
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

  // Fungsi untuk mengambil data checklist dari Firestore (placeholder untuk sekarang)
  Future<List<ChecklistItem>> fetchChecklistItemsForHistory(
    String historyId,
  ) async {
    // TODO: Implementasi fetch dari Firestore
    // Untuk sekarang return list kosong sebagai placeholder
    return [];
  }

  // Fungsi untuk tombol ekspor
  void _handleExportHistory() async {
    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Menyiapkan ekspor..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      // 1. Ambil List<ChecklistItem> dari Firestore untuk riwayat ini
      final List<ChecklistItem> answeredItems =
          await fetchChecklistItemsForHistory(widget.history.id);

      // Close loading dialog
      Navigator.of(context).pop();

      if (answeredItems.isEmpty) {
        // Tampilkan pesan info jika data tidak ditemukan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Belum ada data checklist untuk riwayat ini'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 2. Panggil service ekspor dengan data yang ada
      await _excelExportService.exportAndShareExcel(
        bankCheckHistory: widget.history,
        bankBranch: widget.branch,
        allChecklistItems: answeredItems,
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Detail Riwayat',
                  style: TextStyle(color: Colors.white),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade800, Colors.blue.shade600],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 60), // Space for app bar
                      // Branch info
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.branch.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              _dateFormat.format(widget.history.checkDate),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Skor: ${widget.history.score.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.file_download, color: Colors.white),
                  onPressed: _handleExportHistory,
                  tooltip: 'Export to Excel',
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs:
                      _categories.map((category) {
                        return Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category['icon']),
                              SizedBox(width: 8),
                              Text(category['name']),
                            ],
                          ),
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
                return _buildCategoryTabContent(
                  category['name'],
                  85.0,
                ); // Mock score
              }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleExportHistory,
        backgroundColor: Colors.green.shade600,
        icon: Icon(Icons.file_download, color: Colors.white),
        label: Text(
          'Export Excel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
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
          // Category score display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildEnhancedCategoryScoreCircle(score),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getScoreLabel(score),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Checklist items
          Expanded(
            child:
                checklistItems.isEmpty
                    ? _buildEmptyChecklistState(categoryName)
                    : ListView.builder(
                      itemCount: checklistItems.length,
                      itemBuilder: (context, index) {
                        return _buildEnhancedChecklistItem(
                          checklistItems[index],
                        );
                      },
                    ),
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

  // Enhanced score circle with animation
  Widget _buildEnhancedCategoryScoreCircle(double score) {
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
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.1),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced checklist item with better visual design
  Widget _buildEnhancedChecklistItem(Map<String, dynamic> item) {
    final IconData statusIcon =
        item['completed'] ? Icons.check_circle : Icons.cancel;
    final Color statusColor =
        item['completed'] ? Colors.green : Colors.red.shade400;

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.heightPercent(1)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['question'],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (item['note'] != null && item['note'].isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Catatan: ${item['note']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
          Icon(
            _getCategoryIcon(categoryName),
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada data checklist',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'untuk kategori $categoryName',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
    // Mock data for demonstration - replace with actual Firestore data
    if (categoryName == 'Satpam') {
      return [
        {
          'question': 'Penampilan seragam rapi dan bersih',
          'completed': true,
          'note': 'Seragam dalam kondisi baik',
        },
        {
          'question': 'Bersikap ramah dan sopan',
          'completed': true,
          'note': null,
        },
        {
          'question': 'Berada di posisi yang tepat',
          'completed': false,
          'note': 'Perlu perbaikan posisi',
        },
      ];
    } else if (categoryName == 'Teller') {
      return [
        {
          'question': 'Grooming sesuai standar',
          'completed': true,
          'note': 'Penampilan profesional',
        },
        {'question': 'Melayani dengan senyum', 'completed': true, 'note': null},
      ];
    } else if (categoryName == 'Customer Service') {
      return [
        {
          'question': 'Menyambut nasabah dengan ramah',
          'completed': true,
          'note': 'Sangat baik',
        },
        {
          'question': 'Memberikan informasi yang jelas',
          'completed': false,
          'note': 'Perlu training komunikasi',
        },
      ];
    }
    // Return empty list for other categories as placeholder
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
      child: tabBar,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
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
