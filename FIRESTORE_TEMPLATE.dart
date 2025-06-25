// FIRESTORE TEMPLATE FOR CHECK HISTORY SCREEN
// Replace the mock data implementation in check_history_screen.dart with this template

/*
===============================================================================
FIRESTORE INTEGRATION TEMPLATE FOR CHECK HISTORY SCREEN
===============================================================================

When Firestore is ready, replace the mock data sections in check_history_screen.dart
with the following implementations:

1. REPLACE THE fetchChecklistItemsForHistory() function:

```dart
Future<List<ChecklistItem>> fetchChecklistItemsForHistory(
  String historyId,
) async {
  try {
    // Query checklist responses for this specific history
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('checklist_responses')
        .where('historyId', isEqualTo: historyId)
        .get();
    
    List<ChecklistItem> items = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      ChecklistItem item = ChecklistItem(
        id: data['questionId'] ?? doc.id,
        question: data['question'] ?? '',
        category: data['category'] ?? '',
        subcategory: data['subcategory'] ?? '',
        uniformType: data['uniformType'],
        forHijab: data['forHijab'],
        answerValue: data['answerValue'],
        note: data['note'],
        skipped: data['skipped'] ?? false,
      );
      
      items.add(item);
    }
    
    return items;
  } catch (e) {
    print('Error fetching checklist items from Firestore: $e');
    return [];
  }
}
```

2. REPLACE THE _getMockChecklistItems() function:

```dart
List<Map<String, dynamic>> _getMockChecklistItems(String categoryName) {
  // This function should fetch actual answered questions from Firestore
  // based on the current history ID and category
  
  return _answeredChecklistItems
      .where((item) => item.category == categoryName)
      .map((item) {
        return {
          'id': item.id,
          'question': item.question,
          'completed': item.answerValue != null,
          'answer': item.answerValue ?? false,
          'note': item.note ?? '',
          'skipped': item.skipped ?? false,
        };
      }).toList();
}
```

3. ADD THIS FIRESTORE DATA STRUCTURE:

Expected Firestore collections structure:

/checklist_responses/{responseId}
- historyId: string (references bank_check_histories)
- questionId: string (references questions)
- question: string (denormalized for display)
- category: string ('Customer Service', 'Teller', etc.)
- subcategory: string ('Grooming', 'Sigap', etc.)
- uniformType: string? ('Korporat', 'Batik', 'Casual')
- forHijab: bool? (true=women, false=men, null=both)
- answerValue: bool? (true=Ya, false=Tidak, null=not answered)
- note: string? (optional note for "Tidak" answers)
- skipped: bool (true if question was skipped)
- answeredAt: timestamp
- answeredBy: string (user ID who answered)

/bank_check_histories/{historyId}
- bankBranchId: string
- checkDate: timestamp
- checkedBy: string
- employeeName: string?
- employeePosition: string?
- score: number
- aspectScores: map<string, number>
- isSuccessful: bool
- notes: string?
- createdAt: timestamp

4. QUESTIONS COLLECTION STRUCTURE:

/assessment_categories/{categoryId}/subcategories/{subcategoryId}/questions/{questionId}
- text: string (the question text)
- category: string (main category name)
- subcategory: string (subcategory name)
- uniformType: string? (for grooming questions)
- forHijab: bool? (gender specification)
- order: number (for ordering questions)
- isActive: bool
- createdAt: timestamp
- updatedAt: timestamp

Example for Customer Service Grooming questions:
/assessment_categories/customer_service/subcategories/grooming/questions/wajah_badan_1
{
  "text": "wajah & badan terlihat bersih, segar & wangi (soft)...",
  "category": "Grooming",
  "subcategory": "Wajah & Badan",
  "forHijab": true,
  "order": 1,
  "isActive": true
}

5. IMPORT STATEMENTS TO ADD:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
```

6. INSTANCE VARIABLES TO ADD:

```dart
class _CheckHistoryDetailScreenState extends State<CheckHistoryDetailScreen> {
  // Add this
  List<ChecklistItem> _answeredChecklistItems = [];
  
  // ... existing code
}
```

7. MODIFY _handleExportHistory() function:

```dart
void _handleExportHistory() async {
  // Show loading
  showDialog(context: context, barrierDismissible: false, builder: (context) => 
    Dialog(child: Padding(padding: EdgeInsets.all(20), child: Row(children: [
      CircularProgressIndicator(), SizedBox(width: 20), Text("Mengambil data...")
    ]))));

  try {
    // Fetch real data from Firestore
    final List<ChecklistItem> answeredItems = 
        await fetchChecklistItemsForHistory(widget.history.id);
    
    Navigator.of(context).pop(); // Close loading

    if (answeredItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada data checklist untuk diekspor'),
               backgroundColor: Colors.orange));
      return;
    }

    // Export with real data
    await _excelExportService.exportAndShareExcel(
      bankCheckHistory: widget.history,
      bankBranch: widget.branch,
      allChecklistItems: answeredItems,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ File Excel berhasil dibuat dan dibagikan!'),
             backgroundColor: Colors.green));
             
  } catch (e) {
    Navigator.of(context).pop(); // Close loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red));
  }
}
```

===============================================================================
STEPS TO IMPLEMENT:
===============================================================================

1. Set up Firestore collections as described above
2. Import CSV data into Firestore using the structure above
3. Replace mock data functions with Firestore queries
4. Test with real data
5. Remove all "MOCK DATA" comments and mock import statements

The Excel export will then use real Firestore data instead of mock data.
*/
