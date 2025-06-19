import 'package:bri_cek/data/bank_check_history_data.dart';
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/screens/check_history_screen.dart';
import 'package:bri_cek/screens/choose_date.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:bri_cek/services/assessment_session_service.dart';

class BankDetailScreen extends StatelessWidget {
  final BankBranch branch;
  final AssessmentSessionService _assessmentSessionService =
      AssessmentSessionService();

  BankDetailScreen({Key? key, required this.branch}) : super(key: key);

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
                branch.name,
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
                  branch.isLocalImage
                      ? Image.asset(branch.imageUrl, fit: BoxFit.cover)
                      : Image.network(branch.imageUrl, fit: BoxFit.cover),
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
                branch.id,
                now.year,
                now.month,
                currentWeekNumber,
              );

          return FloatingActionButton.extended(
            onPressed: () async {
              if (canCheck) {
                try {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 20),
                          Text('Mempersiapkan survey...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.blue.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // Navigate to ChooseDateScreen passing the current branch
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChooseDateScreen(
                            selectedBank: branch.name,
                            bankBranchId: branch.id,
                          ),
                    ),
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
                  label: branch.city,
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
                  label: branch.phoneNumber ?? 'Not available',
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
                  content: branch.address,
                  icon: Icons.location_on_outlined,
                  color: Colors.red.shade400,
                ),

                SizedBox(height: AppSize.heightPercent(2)),

                _buildEnhancedInfoCard(
                  title: 'Opening Hours',
                  content: branch.operationalHours ?? 'Not available',
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
    // Get histories for this specific branch
    final List<BankCheckHistory> histories = getHistoriesForBranch(branch.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Check History'),
            if (histories.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // View all history
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

        histories.isEmpty
            ? _buildEmptyHistoryState()
            : Column(
              children:
                  histories
                      .take(3) // Show only the 3 most recent entries
                      .map(
                        (history) =>
                            _buildEnhancedHistoryItem(context, history),
                      )
                      .toList(),
            ),
      ],
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
              Icons.history,
              size: AppSize.iconSize * 2,
              color: Colors.grey[400],
            ),
            SizedBox(height: AppSize.heightPercent(1)),
            Text(
              'No check history available',
              style: AppSize.getTextStyle(
                fontSize: AppSize.bodyFontSize,
                color: Colors.grey[600] ?? Colors.black54,
              ),
            ),
            SizedBox(height: AppSize.heightPercent(0.5)),
            Text(
              'Tap the + button to add a new check',
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

  Widget _buildEnhancedHistoryItem(
    BuildContext context,
    BankCheckHistory history,
  ) {
    // Determine status color and text
    final Color statusColor =
        history.isSuccessful ? Colors.green : Colors.amber.shade700;
    final String statusText = history.isSuccessful ? 'Completed' : 'Incomplete';

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
            // Navigate to history detail screen
          },
          child: Padding(
            padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.8),
            child: Column(
              children: [
                // Top row: Date and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date with calendar icon and week number
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
                              history.formattedDate,
                              style: AppSize.getTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: AppSize.smallFontSize,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            Text(
                              'Week ${history.weekNumberInMonth}',
                              style: AppSize.getTextStyle(
                                fontSize: AppSize.smallFontSize * 0.85,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Status chip with updated text and color
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
                            history.isSuccessful
                                ? Icons.check
                                : Icons.pending_outlined,
                            size: AppSize.iconSize * 0.7,
                            color: statusColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            statusText,
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.smallFontSize * 0.9,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Rest of the widget remains unchanged
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Colors.grey.shade200),
                ),

                Row(
                  children: [
                    _buildScoreIndicator(history.score),
                    SizedBox(width: AppSize.widthPercent(3)),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checked by:',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.smallFontSize * 0.9,
                              color: Colors.grey[600] ?? Colors.black54,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            history.checkedBy,
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
                        // Navigate to history details screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CheckHistoryDetailScreen(
                                  history: history,
                                  branch: branch,
                                ),
                          ),
                        );
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
}
