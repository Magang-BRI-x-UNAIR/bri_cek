import 'package:bri_cek/models/checklist_item.dart';

class ChecklistService {
  List<ChecklistItem> getFilteredItems(
    List<ChecklistItem> items,
    Map<String, dynamic>? employeeData,
  ) {
    if (employeeData == null) {
      return items;
    }

    final bool isHijabi = employeeData['isHijabi'] ?? false;

    return items.where((item) {
      // If forHijab is null, show to all
      if (item.forHijab == null) return true;

      // Show hijab-specific items only to hijabi employees
      if (item.forHijab == true) return isHijabi;

      // Show non-hijab items only to non-hijabi employees
      if (item.forHijab == false) return !isHijabi;

      return true;
    }).toList();
  }

  Map<String, Map<String, List<ChecklistItem>>> groupItems(
    List<ChecklistItem> items,
  ) {
    final Map<String, Map<String, List<ChecklistItem>>> result = {};

    for (var item in items) {
      final category = item.category.isEmpty ? 'Uncategorized' : item.category;
      final subcategory = item.subcategory;

      if (!result.containsKey(category)) {
        result[category] = {};
      }

      if (!result[category]!.containsKey(subcategory)) {
        result[category]![subcategory] = [];
      }

      result[category]![subcategory]!.add(item);
    }

    return result;
  }

  double calculateScore(List<ChecklistItem> items) {
    // Filter out skipped items
    final nonSkippedItems =
        items.where((item) => item.skipped != true).toList();

    // If all items are skipped
    if (nonSkippedItems.isEmpty) return 0;

    int totalPoints = 0;
    int totalItems = 0;

    for (var item in nonSkippedItems) {
      if (item.answerValue != null) {
        totalItems++;
        if (item.answerValue == true) {
          totalPoints++;
        }
      }
    }

    if (totalItems == 0) return 0;
    return totalPoints / totalItems * 100;
  }
}
