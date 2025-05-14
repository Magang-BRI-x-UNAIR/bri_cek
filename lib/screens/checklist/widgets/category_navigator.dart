import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class CategoryNavigator extends StatelessWidget {
  final List<String> categories;
  final List<List<String>> subcategories;
  final int currentCategoryIndex;
  final int currentSubcategoryIndex;
  final Function(int) onCategorySelected;
  final Function(int) onSubcategorySelected;
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
  @override
  Widget build(BuildContext context) {
    // Check if the current category has valid subcategories
    bool hasSubcategories =
        currentCategoryIndex < subcategories.length &&
        subcategories[currentCategoryIndex].isNotEmpty &&
        subcategories[currentCategoryIndex].length > 1;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(5),
        vertical: AppSize.heightPercent(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryTabs(context),
          // Only show subcategories section if valid subcategories exist
          if (hasSubcategories) ...[
            SizedBox(height: AppSize.heightPercent(1.5)),
            _buildSubcategoryTabs(),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    // Calculate available width for category tabs
    final double availableWidth =
        MediaQuery.of(context).size.width -
        (AppSize.widthPercent(10)); // Account for horizontal margin

    // Calculate width per category based on number of categories
    // We'll set a minimum width to ensure readability
    final int categoryCount = categories.length;
    final double minCategoryWidth = AppSize.widthPercent(
      20,
    ); // Minimum width for a category
    final double connectorWidth = AppSize.widthPercent(
      10,
    ); // Width of connector line
    final double circleWidth = AppSize.widthPercent(7); // Width of circle

    // Calculate total width needed for all categories
    final double totalMinWidth =
        (categoryCount * (circleWidth + minCategoryWidth)) +
        ((categoryCount - 1) * connectorWidth);

    // If we have enough space, distribute evenly, otherwise use scrolling
    final bool needsScrolling = totalMinWidth > availableWidth;

    if (needsScrolling) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            categories.length,
            (index) => _buildCategoryTab(index),
          ),
        ),
      );
    } else {
      // Calculate equal width per category
      final double spacing =
          (availableWidth - (categoryCount * circleWidth)) /
          (categoryCount + (categoryCount - 1));

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          categories.length,
          (index) => _buildFlexCategoryTab(index, spacing),
        ),
      );
    }
  }

  Widget _buildFlexCategoryTab(int index, double spacing) {
    final bool isActive = index == currentCategoryIndex;
    final bool isCompleted =
        index < categoryCompletionStatus.length
            ? categoryCompletionStatus[index]
            : false;

    return Expanded(
      child: InkWell(
        onTap: () => onCategorySelected(index),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          isCompleted
                              ? Colors.green.shade500
                              : Colors.grey.shade300,
                    ),
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

  Widget _buildCategoryTab(int index) {
    final bool isActive = index == currentCategoryIndex;
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
    // Safety checks
    if (currentCategoryIndex >= subcategories.length) {
      return SizedBox.shrink();
    }

    final categorySubcats = subcategories[currentCategoryIndex];

    // Don't show anything if there are no subcategories
    if (categorySubcats.isEmpty) {
      return SizedBox.shrink();
    }

    final subcatCompletionStatus =
        currentCategoryIndex < subcategoryCompletionStatus.length
            ? subcategoryCompletionStatus[currentCategoryIndex]
            : <bool>[];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categorySubcats.length, (index) {
          final bool isActive = index == currentSubcategoryIndex;
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
