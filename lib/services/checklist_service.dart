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
    // Filter hanya item yang tidak di-skip dan memiliki jawaban
    final answeredItems =
        items
            .where((item) => item.skipped != true && item.answerValue != null)
            .toList();

    // Jika tidak ada item yang dijawab (semua di-skip), kembalikan 0
    if (answeredItems.isEmpty) {
      return 0.0;
    }

    // Hitung skor dari pertanyaan yang dijawab (bukan di-skip)
    final correctItems =
        answeredItems.where((item) => item.answerValue == true).length;
    return (correctItems / answeredItems.length) * 100.0;
  }
}
