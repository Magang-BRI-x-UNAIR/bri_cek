# Excel Export Format Documentation

## Overview
File Excel hasil export memiliki format yang berbeda untuk setiap jenis kategori checklist.

## ✅ FIXED ISSUES
- **Teller sheet** sekarang akan selalu muncul (issue fixed)
- **CS questions** sekarang menggunakan data detailed sesuai CSV (issue fixed)
- **Empty sheet handling** ditambahkan untuk sheet yang tidak ada data

## Sheet Order (Urutan Sheet)
1. **CS** - Customer Service
2. **Teller** - Teller  ✅ FIXED - sekarang selalu muncul
3. **Satpam** - Satpam
4. **Banking Hall** - Banking Hall
5. **Gallery E-Channel** - Gallery e-Channel
6. **Fasad Gedung** - Fasad Gedung
7. **Ruang BRIMEN** - Ruang BRIMEN
8. **Toilet** - Toilet

## Format untuk Sheet CS, Teller, dan Satpam

### Header Columns:
| Kolom A | Kolom B | Kolom C | Kolom D |
|---------|---------|---------|---------|
| KATEGORI | GENDER | PERTANYAAN | STATUS |

### Kategori yang digunakan:
- **Grooming** - Memiliki subcategory dan gender
- **Sigap** - Kolom A dan B digabung
- **Mudah** - Kolom A dan B digabung  
- **Akurat** - Kolom A dan B digabung
- **Ramah** - Kolom A dan B digabung
- **Terampil** - Kolom A dan B digabung

### Format Grooming:
- **Subcategory** diletakkan pada baris terpisah di atas pertanyaan:
  - "Wajah & Badan"
  - "Rambut" 
  - "Jilbab"
  - "Pakaian"
  - "Atribut & Aksesoris"
  - "Sepatu"
- **Gender** ditampilkan untuk pertanyaan spesifik:
  - "Pria" - untuk pertanyaan khusus pria
  - "Wanita" - untuk pertanyaan khusus wanita (termasuk hijab)
  - Kosong - untuk pertanyaan umum

### Status Values:
- "Ya" - Jika answerValue = true
- "Tidak" - Jika answerValue = false  
- "Skip" - Jika skipped = true
- "Belum Diisi" - Jika belum ada jawaban

## Format untuk Semua Sheet Lainnya (Banking Hall, Gallery e-Channel, dll)

### Header Columns:
| Kolom A | Kolom B | Kolom C |
|---------|---------|---------|
| ITEM | SUB ITEM | STATUS |

### Description:
- **ITEM** - Subcategory (ditampilkan sekali per grup)
- **SUB ITEM** - Pertanyaan checklist
- **STATUS** - Ya/Tidak/Skip/Belum Diisi

## ✅ NEW: Updated Mock Data Implementation

### Customer Service Mock Data (✅ UPDATED)
Berdasarkan CSV yang diberikan, CS sekarang memiliki pertanyaan yang lebih detailed:

**File**: `lib/data/cs_mock_data.dart`
- ✅ Grooming dengan subcategory: Wajah & Badan, Rambut, Jilbab, Pakaian, Atribut & Aksesoris, Sepatu
- ✅ Sigap, Mudah, Akurat, Ramah, Terampil categories
- ✅ Gender-specific questions (`forHijab: true/false/null`)
- ✅ Uniform-specific questions (`uniformType: 'Korporat'/'Batik'/'Casual'`)

### Teller Mock Data (✅ NEW)
File: `lib/data/teller_mock_data.dart`
- ✅ Similar structure to CS with appropriate teller-specific questions
- ✅ Same categories: Grooming, Sigap, Mudah, Akurat, Ramah, Terampil

### Satpam Mock Data (✅ NEW)  
File: `lib/data/satpam_mock_data.dart`
- ✅ Similar structure adapted for security guard role
- ✅ Same categories with security-focused questions

## 🔄 TEMPLATE: Replace When Firestore Is Ready

### ⚠️ IMPORTANT - Files to Update When Firestore Is Ready:

1. **lib/screens/check_history_screen.dart**
   - Hapus import: `import 'package:bri_cek/data/checklist_item_data.dart' as MockData;`
   - Replace function `fetchChecklistItemsForHistory()`
   - Replace function `_getMockChecklistItems()`

2. **lib/data/checklist_item_data.dart**  
   - Replace mock imports dengan Firestore imports
   - Update `getChecklistForCategory()` to fetch from Firestore

3. **Sections yang ditandai untuk diganti:**
   - Semua blok kode dengan komentar `// MOCK DATA IMPLEMENTATION`
   - Uncomment template Firestore implementation
   - Update query Firestore sesuai struktur database

### 📊 Expected Data Structure dari Firestore:

```dart
ChecklistItem {
  String id,
  String question,
  String category,       // 'Grooming', 'Sigap', dll
  String subcategory,    // 'Wajah & Badan', 'Rambut', dll  
  String? uniformType,   // 'Korporat', 'Batik', 'Casual'
  bool? forHijab,        // true=wanita, false=pria, null=umum
  bool? answerValue,     // true/false jawaban user
  String? note,          // catatan user
  bool? skipped,         // true jika pertanyaan dilewati
}
```

### 🗃️ Firestore Collections Structure:

```
/assessment_categories/{categoryId}/subcategories/{subcategoryId}/questions/{questionId}
{
  "text": "Question text",
  "category": "Grooming",
  "subcategory": "Wajah & Badan", 
  "uniformType": "Korporat",
  "forHijab": true,
  "order": 1,
  "isActive": true
}

/checklist_responses/{responseId}
{
  "historyId": "check_history_id",
  "questionId": "question_id",
  "answerValue": true,
  "note": "Optional note",
  "skipped": false,
  "answeredAt": timestamp,
  "answeredBy": "user_id"
}
```

## Testing
- ✅ Export functionality tested with updated mock data
- ✅ Format Excel sesuai dengan spesifikasi yang diminta
- ✅ Urutan sheet dan kategori sudah sesuai
- ✅ Gender grouping untuk Grooming category implemented
- ✅ All 8 sheets (CS, Teller, Satpam, Banking Hall, Gallery e-Channel, Fasad Gedung, Ruang BRIMEN, Toilet) sekarang akan selalu dibuat

## Next Steps
1. ✅ **COMPLETED**: Update mock data dengan struktur yang benar
2. ✅ **COMPLETED**: Fix Teller sheet tidak muncul
3. ✅ **COMPLETED**: Implement CS questions sesuai CSV format
4. 🔄 **PENDING**: Siapkan Firestore collection dan document structure  
5. 🔄 **PENDING**: Import CSV data into Firestore menggunakan struktur di atas
6. 🔄 **PENDING**: Implement Firestore queries menggantikan mock data
7. 🔄 **PENDING**: Test dengan data real dari Firestore
8. 🔄 **PENDING**: Remove mock data dan comments

## 📋 Template Firestore Integration

Lihat file `FIRESTORE_TEMPLATE.dart` untuk template implementasi lengkap Firestore.

---

**Status**: ✅ Mock data fixed, Excel export working, siap untuk integrasi Firestore
