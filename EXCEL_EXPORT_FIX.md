# Fix: Excel Export Missing Categories

## Masalah yang Ditemukan:
Hanya sheet CS dan Satpam yang muncul di file Excel karena:

1. **Data dalam `checklist_item_data.dart` tidak memiliki field `category` yang diset**
   - Items seperti Banking Hall, Gallery e-Channel, dll hanya memiliki `id` dan `question`
   - Field `category` menjadi string kosong (`''`)

2. **Filter kategori di `excel_export_service.dart` terlalu ketat**
   - Hanya mendeteksi items yang memiliki `category` yang exact match
   - Tidak mendeteksi items berdasarkan `id` prefix untuk kategori selain CS dan Satpam

## Perbaikan yang Dilakukan:

### 1. `excel_export_service.dart`:
- **Updated category detection filter** untuk semua kategori:
  ```dart
  // Sekarang mendeteksi berdasarkan category field ATAU id prefix
  (category == 'Banking Hall' && (item.category.isEmpty && item.id.startsWith('hall')))
  (category == 'Gallery e-Channel' && (item.category.isEmpty && item.id.startsWith('channel')))
  // dst untuk semua kategori
  ```

- **Updated item filtering** untuk setiap kategori:
  ```dart
  // Sekarang setiap kategori dicek berdasarkan category field atau id prefix
  if (category == 'Banking Hall') {
    categoryItems = allChecklistItems.where((item) => 
        item.category == 'Banking Hall' || 
        (item.category.isEmpty && item.id.startsWith('hall'))).toList();
  }
  ```

- **Added debugging** untuk tracking:
  - Total items received
  - Categories detected
  - Sample items with their categories
  - Items count per category

- **Added empty category skip** untuk menghindari sheet kosong

### 2. `check_history_screen.dart`:
- **Fixed mock data creation**:
  ```dart
  // Pastikan category tidak kosong untuk mock data
  category: item.category.isEmpty ? category : item.category
  ```

## ID Prefixes yang Digunakan:
- `cs_*` → Customer Service
- `satpam_*` → Satpam  
- `teller_*` → Teller
- `hall_*` → Banking Hall
- `channel_*` → Gallery e-Channel
- `fasad_*` → Fasad Gedung
- `brimen_*` → Ruang BRIMEN
- `toilet_*` → Toilet

## Expected Result:
Sekarang semua 8 kategori akan muncul sebagai sheet terpisah:
1. CS (Customer Service)
2. Teller
3. Satpam
4. Banking Hall
5. Gallery E-Channel
6. Fasad Gedung
7. Ruang BRIMEN
8. Toilet

## Testing:
- Debug output akan menampilkan di console:
  - Total items yang diterima
  - Kategori yang terdeteksi
  - Sample items dengan category mereka
  - Jumlah items per kategori

## Next Steps:
1. Test export Excel untuk memverifikasi semua sheet muncul
2. Remove debug statements setelah konfirmasi fix berhasil
3. Dokumentasi final format Excel yang sudah benar
