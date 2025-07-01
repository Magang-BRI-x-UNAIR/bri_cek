import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class CategoryNavigator extends StatelessWidget {
  final List<String> subcategories; // Sebenarnya subcategories di database
  final List<List<String>> sections; // Sebenarnya sections di database
  final int currentSubcategoryIndex; // Index subcategory saat ini
  final int currentSectionIndex; // Index section saat ini
  final Function(int) onSubcategorySelected; // Callback untuk subcategory
  final Function(int) onSectionSelected; // Callback untuk section
  final List<bool> subcategoryCompletionStatus; // Status completion subcategory
  final List<List<bool>> sectionCompletionStatus; // Status completion section

  const CategoryNavigator({
    Key? key,
    required this.subcategories,
    required this.sections,
    required this.currentSubcategoryIndex,
    required this.currentSectionIndex,
    required this.onSubcategorySelected,
    required this.onSectionSelected,
    required this.subcategoryCompletionStatus,
    required this.sectionCompletionStatus,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    // Check if the current subcategory has valid sections
    bool hasSections =
        currentSubcategoryIndex < sections.length &&
        sections[currentSubcategoryIndex].isNotEmpty &&
        sections[currentSubcategoryIndex].length > 1;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(5),
        vertical: AppSize.heightPercent(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubcategoryTabs(context),
          // Only show sections if valid sections exist
          if (hasSections) ...[
            SizedBox(height: AppSize.heightPercent(1.5)),
            _buildSectionTabs(),
          ],
        ],
      ),
    );
  }

  Widget _buildSubcategoryTabs(BuildContext context) {
    // Calculate available width for subcategory tabs
    final double availableWidth =
        MediaQuery.of(context).size.width -
        (AppSize.widthPercent(10)); // Account for horizontal margin

    // Calculate width per subcategory based on number of subcategories
    // We'll set a minimum width to ensure readability
    final int subcategoryCount = subcategories.length;
    final double minSubcategoryWidth = AppSize.widthPercent(
      20,
    ); // Minimum width for a subcategory
    final double connectorWidth = AppSize.widthPercent(
      10,
    ); // Width of connector line
    final double circleWidth = AppSize.widthPercent(7); // Width of circle

    // Calculate total width needed for all subcategories
    final double totalMinWidth =
        (subcategoryCount * (circleWidth + minSubcategoryWidth)) +
        ((subcategoryCount - 1) * connectorWidth);

    // If we have enough space, distribute evenly, otherwise use scrolling
    final bool needsScrolling = totalMinWidth > availableWidth;

    if (needsScrolling) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            subcategories.length,
            (index) => _buildSubcategoryTab(index),
          ),
        ),
      );
    } else {
      // Calculate equal width per subcategory
      final double spacing =
          (availableWidth - (subcategoryCount * circleWidth)) /
          (subcategoryCount + (subcategoryCount - 1));

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          subcategories.length,
          (index) => _buildFlexSubcategoryTab(index, spacing),
        ),
      );
    }
  }

  Widget _buildFlexSubcategoryTab(int index, double spacing) {
    final bool isActive = index == currentSubcategoryIndex;
    final bool isCompleted =
        index < subcategoryCompletionStatus.length
            ? subcategoryCompletionStatus[index]
            : false;

    return Expanded(
      child: InkWell(
        onTap: () => onSubcategorySelected(index),
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
                if (index < subcategories.length - 1)
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
                subcategories[index],
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

  Widget _buildSubcategoryTab(int index) {
    final bool isActive = index == currentSubcategoryIndex;
    final bool isCompleted =
        index < subcategoryCompletionStatus.length
            ? subcategoryCompletionStatus[index]
            : false;

    return InkWell(
      onTap: () => onSubcategorySelected(index),
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
                if (index < subcategories.length - 1)
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
                subcategories[index],
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

  Widget _buildSectionTabs() {
    // Safety checks
    if (currentSubcategoryIndex >= sections.length) {
      return SizedBox.shrink();
    }

    final subcategorySections = sections[currentSubcategoryIndex];

    // Don't show anything if there are no sections
    if (subcategorySections.isEmpty) {
      return SizedBox.shrink();
    }

    final sectionCompletionStatusList =
        currentSubcategoryIndex < sectionCompletionStatus.length
            ? sectionCompletionStatus[currentSubcategoryIndex]
            : <bool>[];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(subcategorySections.length, (index) {
          final bool isActive = index == currentSectionIndex;
          final bool isCompleted =
              index < sectionCompletionStatusList.length
                  ? sectionCompletionStatusList[index]
                  : false;

          return InkWell(
            onTap: () => onSectionSelected(index),
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
                      subcategorySections[index],
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
