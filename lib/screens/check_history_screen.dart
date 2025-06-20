import 'package:bri_cek/services/excel_export_service.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';
// MOCK DATA IMPORT - REMOVE WHEN FIRESTORE IS READY
import 'package:bri_cek/data/checklist_item_data.dart' as MockData;

// ==============================================
// FIRESTORE INTEGRATION GUIDE
// ==============================================
// TODO: WHEN FIRESTORE IS READY, REPLACE THE FOLLOWING:
// 1. Remove the MockData import above
// 2. Replace fetchChecklistItemsForHistory() implementation
// 3. Replace _getMockChecklistItems() implementation
// 4. Add proper Firestore queries
// 5. Remove all "MOCK DATA" comment sections
// ==============================================

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
  // Define all the categories in the correct order
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Customer Service', 'icon': Icons.support_agent}, // Sheet 1 - CS
    {'name': 'Teller', 'icon': Icons.person}, // Sheet 2 - Teller
    {'name': 'Satpam', 'icon': Icons.security}, // Sheet 3 - Satpam
    {'name': 'Banking Hall', 'icon': Icons.business}, // Sheet 4 - Banking Hall
    {
      'name': 'Gallery e-Channel',
      'icon': Icons.devices,
    }, // Sheet 5 - Gallery e-Channel
    {'name': 'Fasad Gedung', 'icon': Icons.apartment}, // Sheet 6 - Fasad Gedung
    {
      'name': 'Ruang BRIMEN',
      'icon': Icons.meeting_room,
    }, // Sheet 7 - Ruang BRIMEN
    {'name': 'Toilet', 'icon': Icons.wc}, // Sheet 8 - Toilet
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
    // TODO: REPLACE WITH FIRESTORE IMPLEMENTATION
    // ==============================================
    // MOCK DATA IMPLEMENTATION - DELETE THIS SECTION WHEN FIRESTORE IS READY
    // This function should be replaced with actual Firestore queries to fetch
    // checklist items based on the history ID
    // ==============================================

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Generate mock data with answers for all categories
    List<ChecklistItem> allMockData =
        []; // Mock data untuk setiap kategori dengan jawaban acak
    for (String category in [
      'Customer Service', // CS - Sheet 1
      'Teller', // Teller - Sheet 2
      'Satpam', // Satpam - Sheet 3
      'Banking Hall', // Banking Hall - Sheet 4
      'Gallery e-Channel', // Gallery E-Channel - Sheet 5
      'Fasad Gedung', // Fasad Gedung - Sheet 6
      'Ruang BRIMEN', // Ruang BRIMEN - Sheet 7
      'Toilet', // Toilet - Sheet 8
    ]) {
      List<ChecklistItem> categoryItems = MockData.getChecklistForCategory(
        category,
      ); // Berikan jawaban mock untuk setiap item
      for (ChecklistItem item in categoryItems) {
        // 80% kemungkinan jawaban "Ya" (true)
        bool mockAnswer = DateTime.now().millisecond % 5 != 0;
        String mockNote =
            mockAnswer ? '' : 'Perlu perbaikan atau catatan tambahan';

        // Create new item with mock answers and ensure category is set
        ChecklistItem answeredItem = ChecklistItem(
          id: item.id,
          question: item.question,
          category:
              item.category.isEmpty
                  ? category
                  : item.category, // Pastikan category tidak kosong
          subcategory: item.subcategory,
          uniformType: item.uniformType,
          forHijab: item.forHijab,
          answerValue: mockAnswer,
          note: mockNote,
        );

        allMockData.add(answeredItem);
      }
    }

    return allMockData;

    // ==============================================
    // END OF MOCK DATA SECTION
    // ==============================================

    // FIRESTORE IMPLEMENTATION TEMPLATE (UNCOMMENT AND MODIFY WHEN READY):
    /*
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('checklist_responses')
          .where('historyId', isEqualTo: historyId)
          .get();
      
      List<ChecklistItem> items = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        items.add(ChecklistItem.fromFirestore(data));
      }
      
      return items;
    } catch (e) {
      print('Error fetching checklist items: $e');
      return [];
    }
    */
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
      // ==============================================
      // MOCK DATA USAGE - REPLACE WITH FIRESTORE WHEN READY
      // ==============================================

      // 1. Ambil List<ChecklistItem> dari Mock Data (ganti dengan Firestore)
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

      // Show success message with mock data indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚧 Menggunakan MOCK DATA - Total ${answeredItems.length} items',
          ),
          backgroundColor: Colors.blue.shade600,
          duration: Duration(seconds: 2),
        ),
      );

      // 2. Panggil service ekspor dengan data yang ada
      await _excelExportService.exportAndShareExcel(
        bankCheckHistory: widget.history,
        bankBranch: widget.branch,
        allChecklistItems: answeredItems,
      );

      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ File Excel berhasil diekspor!'),
          backgroundColor: Colors.green.shade600,
        ),
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
    // ==============================================
    // MOCK DATA IMPLEMENTATION - MODIFY WHEN FIRESTORE IS READY
    // This function should be replaced with actual data from Firestore
    // ==============================================

    List<ChecklistItem> categoryItems = MockData.getChecklistForCategory(
      categoryName,
    );

    // Convert ChecklistItem to display format with mock answers
    return categoryItems.map((item) {
      // 85% kemungkinan jawaban "Ya" untuk tampilan yang lebih realistis
      bool mockCompleted = DateTime.now().millisecond % 7 != 0;
      String? mockNote = mockCompleted ? null : 'Catatan perbaikan diperlukan';

      return {
        'question': item.question,
        'completed': mockCompleted,
        'note': mockNote,
        'category': item.category,
        'subcategory': item.subcategory,
      };
    }).toList();

    // ==============================================
    // END OF MOCK DATA SECTION
    // ==============================================

    // FIRESTORE IMPLEMENTATION TEMPLATE (UNCOMMENT WHEN READY):
    /*
    // This should return actual data from Firestore based on the historyId
    // You would filter the ChecklistItem list based on category
    return checklistItemsFromFirestore
        .where((item) => item.category == categoryName)
        .map((item) => {
          'question': item.question,
          'completed': item.answerValue ?? false,
          'note': item.note,
          'category': item.category,
          'subcategory': item.subcategory,
        }).toList();
    */
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
