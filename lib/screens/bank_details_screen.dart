import 'package:bri_cek/data/bank_check_history_data.dart';
import 'package:bri_cek/screens/choose_date.dart';
import 'package:bri_cek/screens/survey_detail_from_bank_screen.dart';
import 'package:bri_cek/services/survey_result_service.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';

class BankDetailScreen extends StatefulWidget {
  final BankBranch branch;

  const BankDetailScreen({Key? key, required this.branch}) : super(key: key);

  @override
  State<BankDetailScreen> createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  final SurveyResultService _surveyResultService = SurveyResultService();
  List<Map<String, dynamic>> _surveyHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadSurveyHistory();
    _debugCheckAllSurveyData(); // Temporary debug method
  }

  // Temporary debug method to check all survey data
  Future<void> _debugCheckAllSurveyData() async {
    try {
      final allHistory = await _surveyResultService.getUserSurveyResults(
        userId: null,
      );
      print('=== DEBUG: All user survey results ===');
      print('Total: ${allHistory.length}');

      bool foundMatchForThisBank = false;

      for (var result in allHistory) {
        final selectedBank = result['selectedBank'];
        final bankMatches = selectedBank == widget.branch.name;

        // Print all survey data
        print('ID: ${result['id']}');
        print('Bank: "${selectedBank}"');
        print('Bank match with "${widget.branch.name}": $bankMatches');
        if (!bankMatches) {
          // Try case insensitive match
          final caseInsensitiveMatch =
              selectedBank.toString().toLowerCase() ==
              widget.branch.name.toLowerCase();
          print('Case insensitive match: $caseInsensitiveMatch');
        }
        print('Categories: ${result['categories']}');
        print('Date: ${result['selectedDate']}');
        print('IsActive: ${result['isActive']}');
        print('---');

        if (bankMatches ||
            (selectedBank != null &&
                selectedBank.toString().toLowerCase() ==
                    widget.branch.name.toLowerCase())) {
          foundMatchForThisBank = true;
        }
      }

      print(
        'Found matches for current bank (${widget.branch.name}): $foundMatchForThisBank',
      );
      print('=== END DEBUG ===');
    } catch (e) {
      print('Debug error: $e');
    }
  }

  Future<void> _loadSurveyHistory() async {
    print('Loading survey history for bank: ${widget.branch.name}');
    try {
      final history = await _surveyResultService.getUserSurveyResults(
        userId: null, // Show all users' survey results, not just current user's
        limit: 10, // Limit to recent 10 results
      );

      // Filter results for this specific bank with more robust matching
      final filteredHistory =
          history.where((result) {
            final selectedBank = result['selectedBank'];
            if (selectedBank == null) return false;

            // Try exact match first
            if (selectedBank == widget.branch.name) return true;

            // Try case-insensitive match
            if (selectedBank.toString().toLowerCase() ==
                widget.branch.name.toLowerCase())
              return true;

            // Try trimmed match
            if (selectedBank.toString().trim() == widget.branch.name.trim())
              return true;

            // Try case-insensitive and trimmed match
            if (selectedBank.toString().toLowerCase().trim() ==
                widget.branch.name.toLowerCase().trim())
              return true;

            // Log mismatch for debugging
            print(
              'Bank name mismatch: "$selectedBank" vs "${widget.branch.name}"',
            );
            return false;
          }).toList();

      print(
        'Found ${filteredHistory.length} survey results for this bank out of ${history.length} total results',
      );

      setState(() {
        _surveyHistory = filteredHistory;
        _isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading survey history: $e');
      setState(() {
        _isLoadingHistory = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat survey: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Tanggal tidak tersedia';

    DateTime date;
    if (timestamp is DateTime) {
      date = timestamp;
    } else {
      date = timestamp.toDate();
    }

    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getScoreColor(dynamic score) {
    if (score == null) return Colors.grey;
    final scoreValue = (score as num).toDouble();
    if (scoreValue >= 80) return Colors.green;
    if (scoreValue >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Enhanced SliverAppBar
          SliverAppBar(
            expandedHeight: AppSize.heightPercent(30),
            pinned: true,
            backgroundColor: Colors.blue.shade700,
            elevation: 0,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // Share branch information
                  },
                ),
              ),
              SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.branch.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5),
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
                ],
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // Branch Information
          SliverToBoxAdapter(child: _buildBranchInformation(context)),
        ],
      ),
      // Enhanced Floating Action Button
      floatingActionButton: Builder(
        builder: (context) {
          // Check if current week already has a check
          final now = DateTime.now();
          final currentWeekNumber = getWeekNumberInMonth(now);
          final canCheck =
              !hasCheckInWeek(
                widget.branch.id,
                now.year,
                now.month,
                currentWeekNumber,
              );

          return FloatingActionButton.extended(
            onPressed: () {
              if (canCheck) {
                // Navigate to ChooseDateScreen passing the current branch
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChooseDateScreen(
                          selectedBank: widget.branch.name,
                          bankBranchId: widget.branch.id,
                        ),
                  ),
                );
              } else {
                // Show snackbar indicating check already done this week
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Check already performed this week. Next check available next week.',
                    ),
                    backgroundColor: Colors.amber.shade700,
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'OK',
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                );
              }
            },
            backgroundColor: canCheck ? Colors.green : Colors.grey.shade400,
            icon: Icon(canCheck ? Icons.add_task : Icons.block),
            label: Text(canCheck ? 'New Check' : 'Check Locked'),
            elevation: canCheck ? 4 : 2,
            tooltip:
                canCheck
                    ? 'Create a new check'
                    : 'Check already performed this week',
          );
        },
      ),
    );
  }

  Widget _buildBranchInformation(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSize.paddingHorizontal,
        bottom: AppSize.heightPercent(8), // Space for FAB
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Info Row
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.paddingHorizontal,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // City badge
                _buildInfoBadge(
                  icon: Icons.location_city,
                  label: widget.branch.city,
                  color: Colors.blue.shade600,
                ),

                // Divider
                Container(
                  height: AppSize.heightPercent(4),
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                // Phone badge
                _buildInfoBadge(
                  icon: Icons.phone,
                  label: widget.branch.phoneNumber ?? 'Not available',
                  color: Colors.green.shade600,
                ),
              ],
            ),
          ),

          SizedBox(height: AppSize.heightPercent(3)),

          // Detailed Information Cards
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.paddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Branch Information'),
                SizedBox(height: AppSize.heightPercent(1.5)),

                _buildEnhancedInfoCard(
                  title: 'Address',
                  content: widget.branch.address,
                  icon: Icons.location_on_outlined,
                  color: Colors.red.shade400,
                ),

                SizedBox(height: AppSize.heightPercent(2)),

                _buildEnhancedInfoCard(
                  title: 'Opening Hours',
                  content: widget.branch.operationalHours ?? 'Not available',
                  icon: Icons.access_time,
                  color: Colors.amber.shade700,
                ),

                SizedBox(height: AppSize.heightPercent(3)),

                _buildHistorySection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: AppSize.widthPercent(4),
          child: Icon(icon, color: color, size: AppSize.widthPercent(4)),
        ),
        SizedBox(width: AppSize.widthPercent(2)),
        Text(
          label,
          style: AppSize.getTextStyle(
            fontSize: AppSize.smallFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppSize.getTextStyle(
        fontSize: AppSize.subtitleFontSize,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildEnhancedInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with colored icon
            Row(
              children: [
                CircleAvatar(
                  radius: AppSize.widthPercent(3.5),
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    icon,
                    color: color,
                    size: AppSize.widthPercent(3.5),
                  ),
                ),
                SizedBox(width: AppSize.widthPercent(2)),
                Text(
                  title,
                  style: AppSize.getTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSize.bodyFontSize,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),

            // Divider with gradient
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),

            // Content
            Text(
              content,
              style: AppSize.getTextStyle(
                fontSize: AppSize.bodyFontSize,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Survey History'),
            if (_surveyHistory.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // Navigate to full survey history
                  Navigator.pushNamed(context, '/survey-history');
                },
                icon: Icon(
                  Icons.history,
                  size: AppSize.iconSize * 0.8,
                  color: Colors.blue,
                ),
                label: Text(
                  'View All',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),

        SizedBox(height: AppSize.heightPercent(1.5)),

        _isLoadingHistory
            ? _buildLoadingHistoryState()
            : _surveyHistory.isEmpty
            ? _buildEmptyHistoryState()
            : Column(
              children:
                  _surveyHistory
                      .take(3) // Show only the 3 most recent entries
                      .map((survey) => _buildSurveyHistoryItem(context, survey))
                      .toList(),
            ),

        // Temporary debug buttons
        if (_surveyHistory.isEmpty && !_isLoadingHistory) ...[
          SizedBox(height: AppSize.heightPercent(1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _debugCheckAllSurveyData();
                  await _loadSurveyHistory();
                },
                child: Text('Debug: Reload Survey Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  final allHistory = await _surveyResultService
                      .getUserSurveyResults(userId: null);
                  final bankNames =
                      allHistory
                          .map((result) => result['selectedBank'])
                          .toSet()
                          .toList();
                  print('Current bank name: "${widget.branch.name}"');
                  print('All bank names in survey results:');
                  bankNames.forEach((name) => print(' - "$name"'));
                },
                child: Text('Debug: Check Bank Names'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingHistoryState() {
    return Container(
      height: AppSize.heightPercent(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
            SizedBox(height: AppSize.heightPercent(1)),
            Text(
              'Memuat riwayat survey...',
              style: AppSize.getTextStyle(
                fontSize: AppSize.bodyFontSize,
                color: Colors.grey[600] ?? Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      height: AppSize.heightPercent(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: AppSize.iconSize * 2,
              color: Colors.grey[400],
            ),
            SizedBox(height: AppSize.heightPercent(1)),
            Text(
              'No survey history available',
              style: AppSize.getTextStyle(
                fontSize: AppSize.bodyFontSize,
                color: Colors.grey[600] ?? Colors.black54,
              ),
            ),
            SizedBox(height: AppSize.heightPercent(0.5)),
            Text(
              'Tap the + button to start a new survey',
              style: AppSize.getTextStyle(
                fontSize: AppSize.smallFontSize,
                color: Colors.grey[500] ?? Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyHistoryItem(
    BuildContext context,
    Map<String, dynamic> survey,
  ) {
    final statistics = survey['statistics'] as Map<String, dynamic>? ?? {};
    final score = statistics['score'] ?? 0;
    final statusColor = _getScoreColor(score);
    final categories = List<String>.from(survey['categories'] ?? []);

    // Check if all questions in the selected categories have been answered
    final answeredQuestions = statistics['answeredQuestions'] ?? 0;
    // Check completion status without relying on totalQuestions
    final isCompleted = answeredQuestions > 0 && categories.isNotEmpty;

    // Status text shows categories completed without question count
    final statusText =
        isCompleted ? '${categories.length} Categories Done' : 'Incomplete';

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.heightPercent(1)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Navigate to survey detail screen with category selection
            _showSurveyDetailDialog(context, survey);
          },
          child: Padding(
            padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.8),
            child: Column(
              children: [
                // Top row: Date and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date with calendar icon
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: AppSize.iconSize * 0.8,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: AppSize.widthPercent(1)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(survey['selectedDate']),
                              style: AppSize.getTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: AppSize.smallFontSize,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            Text(
                              '${categories.length} kategori',
                              style: AppSize.getTextStyle(
                                fontSize: AppSize.smallFontSize * 0.85,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Surveyor: ${survey['userName'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: AppSize.smallFontSize * 0.85,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Status chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted ? Icons.check : Icons.pending_outlined,
                            size: AppSize.iconSize * 0.7,
                            color: statusColor,
                          ),
                          SizedBox(width: 4),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusText,
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize * 0.9,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Question count removed as requested
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Colors.grey.shade200),
                ),

                // Kategori yang telah dikerjakan
                if (categories.isNotEmpty) ...[
                  Wrap(
                    spacing: AppSize.paddingXS,
                    runSpacing: AppSize.paddingXS,
                    children:
                        categories
                            .map(
                              (category) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSize.paddingS * 0.6,
                                  vertical: AppSize.paddingXS * 0.6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppSize.cardBorderRadius,
                                  ),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.captionFontSize * 0.9,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: AppSize.heightPercent(1)),
                ],

                Row(
                  children: [
                    _buildScoreIndicator(score.toDouble()),
                    SizedBox(width: AppSize.widthPercent(3)),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Questions: ${statistics['totalQuestions'] ?? 0}',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.smallFontSize * 0.9,
                              color: Colors.grey[600] ?? Colors.black54,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Answered: ${statistics['answeredQuestions'] ?? 0} | Skipped: ${statistics['skippedQuestions'] ?? 0}',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize * 0.95,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to survey detail screen with category selection
                        _showSurveyDetailDialog(context, survey);
                      },
                      icon: Icon(
                        Icons.visibility,
                        size: AppSize.iconSize * 0.8,
                      ),
                      label: Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        textStyle: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildScoreIndicator(double score) {
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
      width: AppSize.widthPercent(15),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Score circle background
              CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey.shade200,
                color: scoreColor,
                strokeWidth: 5,
              ),
              // Score text
              Text(
                score.toStringAsFixed(0),
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize * 0.9,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Score',
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize * 0.9,
              color: Colors.grey[600] ?? Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showSurveyDetailDialog(
    BuildContext context,
    Map<String, dynamic> survey,
  ) {
    final categories = List<String>.from(survey['categories'] ?? []);

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada kategori ditemukan untuk survey ini'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    if (categories.length == 1) {
      // Jika hanya satu kategori, langsung buka detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SurveyDetailFromBankScreen(
                surveyId: survey['id'],
                surveyData: survey,
                selectedCategory: categories.first,
              ),
        ),
      );
    } else {
      // Jika lebih dari satu kategori, tampilkan dialog pilihan
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pilih Kategori'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Survey ini memiliki ${categories.length} kategori:'),
                SizedBox(height: AppSize.heightPercent(1)),
                ...categories
                    .map(
                      (category) => ListTile(
                        title: Text(category),
                        leading: Icon(Icons.folder),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SurveyDetailFromBankScreen(
                                    surveyId: survey['id'],
                                    surveyData: survey,
                                    selectedCategory: category,
                                  ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
                SizedBox(height: AppSize.heightPercent(1)),
                ListTile(
                  title: Text('Lihat Semua Kategori'),
                  leading: Icon(Icons.list_alt),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SurveyDetailFromBankScreen(
                              surveyId: survey['id'],
                              surveyData: survey,
                              selectedCategory:
                                  null, // null berarti tampilkan semua
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
