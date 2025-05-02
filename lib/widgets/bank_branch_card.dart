import 'package:bri_cek/screens/bank_details_screen.dart';
import 'package:bri_cek/screens/choose_date.dart';
import 'package:flutter/material.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/utils/app_size.dart';

class BankBranchCard extends StatelessWidget {
  final BankBranch branch;

  const BankBranchCard({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          onTap: () {
            // Handle card tap - navigate to detail screen or selection
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BankDetailScreen(branch: branch),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch image
                _buildBranchImage(),

                SizedBox(height: AppSize.heightPercent(1)),

                // Branch information
                Row(
                  children: [
                    Expanded(child: _buildBranchInfo()),

                    // Navigation arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[800],
                      size: AppSize.iconSize * 0.7,
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

  Widget _buildBranchImage() {
    final imageHeight = AppSize.heightPercent(15);

    // Container for consistent size and border radius
    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius * 0.5),
        color: Colors.grey[200],
      ),
      clipBehavior:
          Clip.antiAlias, // Ensures the image respects the border radius
      child: _getBranchImage(),
    );
  }

  Widget _getBranchImage() {
    // Check if it's a local image or network image
    if (branch.isLocalImage) {
      return Image.asset(
        branch.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image can't be loaded
          return Center(
            child: Icon(
              Icons.account_balance,
              size: AppSize.iconSize * 1.5,
              color: Colors.grey[400],
            ),
          );
        },
      );
    } else {
      // Handle network images
      return Image.network(
        branch.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Fallback if network image fails to load
          return Center(
            child: Icon(
              Icons.account_balance,
              size: AppSize.iconSize * 1.5,
              color: Colors.grey[400],
            ),
          );
        },
      );
    }
  }

  Widget _buildBranchInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Branch name
        Text(
          branch.name,
          style: AppSize.getTextStyle(
            fontSize: AppSize.isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900] ?? Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: AppSize.heightPercent(0.5)),

        // Branch address
        Text(
          branch.address,
          style: AppSize.getTextStyle(
            fontSize: AppSize.isSmallScreen ? 12 : 14,
            color: Colors.grey[600] ?? Colors.black54,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
