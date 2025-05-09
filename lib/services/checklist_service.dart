import 'package:bri_cek/models/checklist_item.dart';

class ChecklistService {
  // Filter checklist items based on employee data
  List<ChecklistItem> getFilteredItems(
    List<ChecklistItem> items,
    Map<String, dynamic>? employeeData,
  ) {
    if (employeeData == null) return items;

    final bool isWoman = employeeData['gender'] == 'Wanita';
    final bool hasHijab = employeeData['hasHijab'] == true;
    final String uniformType = employeeData['uniformType'] ?? 'Korporat';

    return items.where((item) {
      // Skip items that are gender-specific and don't match
      if (item.question.startsWith('Wanita:') && !isWoman) return false;
      if (item.question.startsWith('Pria:') && isWoman) return false;

      // Skip items based on hijab
      if (item.forHijab == true && !hasHijab) return false;
      if (item.forHijab == false && hasHijab) return false;

      // Skip items that are uniform-specific if they don't match current uniform
      if (item.uniformType.isNotEmpty &&
          !item.uniformType.contains(uniformType))
        return false;

      return true;
    }).toList();
  }

  // Group items by category and subcategory
  Map<String, Map<String, List<ChecklistItem>>> groupItems(
    List<ChecklistItem> filteredItems,
  ) {
    final Map<String, Map<String, List<ChecklistItem>>> groupedItems = {};

    for (var item in filteredItems) {
      // Create category map if it doesn't exist
      if (!groupedItems.containsKey(item.category)) {
        groupedItems[item.category] = {};
      }

      // Create subcategory list if it doesn't exist
      if (!groupedItems[item.category]!.containsKey(item.subcategory)) {
        groupedItems[item.category]![item.subcategory] = [];
      }

      // Add item to its category and subcategory
      groupedItems[item.category]![item.subcategory]!.add(item);
    }

    return groupedItems;
  }

  // Calculate score from checklist results
  double calculateScore(List<ChecklistItem> items) {
    if (items.isEmpty) return 0;

    int positiveAnswers = 0;
    for (var item in items) {
      if (item.answerValue == true) positiveAnswers++;
    }

    return (positiveAnswers / items.length) * 100;
  }
}
