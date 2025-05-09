import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class CategoryNavigator extends StatelessWidget {
  final List<String> categories;
  final List<List<String>> subcategories;
  final int currentCategoryIndex;
  final int currentSubcategoryIndex;
  final Function(int) onCategorySelected;
  final Function(int) onSubcategorySelected;
  // Add these new parameters to track completion status
  final List<bool> categoryCompletionStatus;
  final List<List<bool>> subcategoryCompletionStatus;

  const CategoryNavigator({
    Key? key,
    required this.categories,
    required this.subcategories,
    required this.currentCategoryIndex,
    required this.currentSubcategoryIndex,
    required this.onCategorySelected,
    required this.onSubcategorySelected,
    required this.categoryCompletionStatus,
    required this.subcategoryCompletionStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(5),
        vertical: AppSize.heightPercent(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryTabs(),
          SizedBox(height: AppSize.heightPercent(1.5)),
          if (currentCategoryIndex < categories.length &&
              subcategories.isNotEmpty &&
              currentCategoryIndex < subcategories.length)
            _buildSubcategoryTabs(),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
          (index) => _buildCategoryTab(index),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(int index) {
    final bool isActive = index == currentCategoryIndex;
    // Instead of isPast, use completion status
    final bool isCompleted =
        index < categoryCompletionStatus.length
            ? categoryCompletionStatus[index]
            : false;

    return InkWell(
      onTap: () => onCategorySelected(index),
      child: Container(
        margin: EdgeInsets.only(right: AppSize.widthPercent(2)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: AppSize.widthPercent(7),
                  height: AppSize.widthPercent(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isActive
                            ? Colors.blue.shade600
                            : (isCompleted
                                ? Colors.green.shade500
                                : Colors.grey.shade300),
                    border: Border.all(
                      color:
                          isActive
                              ? Colors.blue.shade100
                              : (isCompleted
                                  ? Colors.green.shade100
                                  : Colors.transparent),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check : null,
                      color: Colors.white,
                      size: AppSize.iconSize * 0.5,
                    ),
                  ),
                ),
                if (index < categories.length - 1)
                  Container(
                    width: AppSize.widthPercent(10),
                    height: 2,
                    color:
                        isCompleted
                            ? Colors.green.shade500
                            : Colors.grey.shade300,
                  ),
              ],
            ),
            SizedBox(height: AppSize.heightPercent(0.5)),
            Container(
              constraints: BoxConstraints(maxWidth: AppSize.widthPercent(20)),
              child: Text(
                categories[index],
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isActive
                          ? Colors.blue.shade600
                          : (isCompleted
                              ? Colors.green.shade600
                              : Colors.grey.shade600),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryTabs() {
    if (currentCategoryIndex >= subcategories.length) {
      return SizedBox.shrink();
    }

    final categorySubcats = subcategories[currentCategoryIndex];
    final subcatCompletionStatus =
        currentCategoryIndex < subcategoryCompletionStatus.length
            ? subcategoryCompletionStatus[currentCategoryIndex]
            : <bool>[];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categorySubcats.length, (index) {
          final bool isActive = index == currentSubcategoryIndex;
          // Instead of isPast, use completion status
          final bool isCompleted =
              index < subcatCompletionStatus.length
                  ? subcatCompletionStatus[index]
                  : false;

          return InkWell(
            onTap: () => onSubcategorySelected(index),
            child: Container(
              margin: EdgeInsets.only(right: AppSize.widthPercent(2)),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.widthPercent(3),
                  vertical: AppSize.heightPercent(0.8),
                ),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? Colors.blue.shade50
                          : (isCompleted
                              ? Colors.green.shade50
                              : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                  border: Border.all(
                    color:
                        isActive
                            ? Colors.blue.shade300
                            : (isCompleted
                                ? Colors.green.shade300
                                : Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    if (isCompleted)
                      Icon(
                        Icons.check,
                        size: AppSize.iconSize * 0.6,
                        color: Colors.green.shade600,
                      ),
                    if (isCompleted) SizedBox(width: AppSize.widthPercent(1)),
                    Text(
                      categorySubcats[index],
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isActive
                                ? Colors.blue.shade700
                                : (isCompleted
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
