import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class CategoryIndicators extends StatelessWidget {
  final List<String> categoryNames;
  final List<List<String>> subcategoryNames;
  final int currentCategoryIndex;
  final int currentSubcategoryIndex;

  const CategoryIndicators({
    Key? key,
    required this.categoryNames,
    required this.subcategoryNames,
    required this.currentCategoryIndex,
    required this.currentSubcategoryIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryNames.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.paddingHorizontal,
        vertical: AppSize.heightPercent(1),
      ),
      child: Row(
        // Mengubah dari Column menjadi Row untuk tampilan lebih seimbang
        children: [
          // Category indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.widthPercent(3),
              vertical: AppSize.heightPercent(0.5),
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              categoryNames[currentCategoryIndex],
              style: AppSize.getTextStyle(
                fontSize: AppSize.smallFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),

          // Divider between badges
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ),

          // Subcategory indicator
          Expanded(
            // Expanded untuk mencegah overflow text
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.widthPercent(3),
                vertical: AppSize.heightPercent(0.5),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                subcategoryNames[currentCategoryIndex][currentSubcategoryIndex],
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis, // Mencegah overflow text
              ),
            ),
          ),
        ],
      ),
    );
  }
}
