# Excel Export Format Documentation

## Overview
File Excel hasil export memiliki format yang berbeda untuk setiap jenis kategori checklist.

## Sheet Order (Urutan Sheet)
1. **CS** - Customer Service
2. **Teller** - Teller
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

## Mock Data Implementation

### ⚠️ IMPORTANT - REPLACE WHEN FIRESTORE IS READY:

1. **File yang perlu diubah saat Firestore siap:**
   - `lib/screens/check_history_screen.dart`
   - Hapus import: `import 'package:bri_cek/data/checklist_item_data.dart' as MockData;`
   - Replace function `fetchChecklistItemsForHistory()`
   - Replace function `_getMockChecklistItems()`

2. **Sections yang ditandai untuk diganti:**
   - Semua blok kode dengan komentar `// MOCK DATA IMPLEMENTATION`
   - Uncomment template Firestore implementation
   - Update query Firestore sesuai struktur database

3. **Data Structure yang diharapkan dari Firestore:**
   ```dart
   ChecklistItem {
     String id,
     String question,
     String category,       // 'Grooming', 'Sigap', dll
     String subcategory,    // 'Wajah & Badan', 'Rambut', dll  
     bool? forHijab,        // true=wanita, false=pria, null=umum
     bool? answerValue,     // true/false jawaban user
     String? note,          // catatan user
     bool? skipped,         // true jika pertanyaan dilewati
   }
   ```

## Testing
- Export functionality sudah ditest dengan mock data
- Format Excel sesuai dengan spesifikasi yang diminta
- Urutan sheet dan kategori sudah sesuai
- Gender grouping untuk Grooming category sudah implemented

## Next Steps
1. Siapkan Firestore collection dan document structure
2. Implement Firestore queries menggantikan mock data
3. Test dengan data real dari Firestore
4. Adjust format jika diperlukan berdasarkan data real
