// file: services/excel_export_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Ganti dengan path model Anda yang benar
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/models/checklist_item.dart';

class ExcelExportService {
  final Map<String, String> categoryToSheetName = {
    'Customer Service': 'CS',
    'Teller': 'Teller',
    'Satpam': 'Satpam',
    'Banking Hall': 'Banking Hall',
    'Gallery e-Channel': 'Gallery E-Channel',
    'Fasad Gedung': 'Fasad Gedung',
    'Ruang BRIMEN': 'Ruang BRIMEN',
    'Toilet': 'Toilet',
  };

  // Define sheet order - CS first, then Teller, then Satpam, etc.
  final List<String> sheetOrder = [
    'Customer Service',
    'Teller',
    'Satpam',
    'Banking Hall',
    'Gallery e-Channel',
    'Fasad Gedung',
    'Ruang BRIMEN',
    'Toilet',
  ];

  final DateFormat fileNameDateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat displayDateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  Future<void> exportAndShareExcel({
    required BankCheckHistory bankCheckHistory,
    required BankBranch bankBranch,
    required List<ChecklistItem> allChecklistItems,
  }) async {
    try {
      var excel = Excel.createExcel();
      final CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 12,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      final CellStyle headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      final CellStyle wrappedTextStyle = CellStyle(
        verticalAlign: VerticalAlign.Top,
      );
      final allCategories =
          sheetOrder
              .where(
                (category) => allChecklistItems.any(
                  (item) =>
                      item.category == category ||
                      (category == 'Customer Service' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('cs')) ||
                      (category == 'Satpam' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('satpam')) ||
                      (category == 'Teller' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('teller')) ||
                      (category == 'Banking Hall' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('hall')) ||
                      (category == 'Gallery e-Channel' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('channel')) ||
                      (category == 'Fasad Gedung' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('fasad')) ||
                      (category == 'Ruang BRIMEN' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('brimen')) ||
                      (category == 'Toilet' &&
                          (item.category == '' || item.category.isEmpty) &&
                          item.id.startsWith('toilet')),
                ),
              )
              .toList();
      for (var category in allCategories) {
        final sheetName = categoryToSheetName[category] ?? category;
        final sheet = excel[sheetName];

        // Filter items for this category
        List<ChecklistItem> categoryItems = [];

        if (category == 'Customer Service') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Customer Service' ||
                        (item.category.isEmpty && item.id.startsWith('cs')),
                  )
                  .toList();
        } else if (category == 'Satpam') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Satpam' ||
                        (item.category.isEmpty && item.id.startsWith('satpam')),
                  )
                  .toList();
        } else if (category == 'Teller') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Teller' ||
                        (item.category.isEmpty && item.id.startsWith('teller')),
                  )
                  .toList();
        } else if (category == 'Banking Hall') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Banking Hall' ||
                        (item.category.isEmpty && item.id.startsWith('hall')),
                  )
                  .toList();
        } else if (category == 'Gallery e-Channel') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Gallery e-Channel' ||
                        (item.category.isEmpty &&
                            item.id.startsWith('channel')),
                  )
                  .toList();
        } else if (category == 'Fasad Gedung') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Fasad Gedung' ||
                        (item.category.isEmpty && item.id.startsWith('fasad')),
                  )
                  .toList();
        } else if (category == 'Ruang BRIMEN') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Ruang BRIMEN' ||
                        (item.category.isEmpty && item.id.startsWith('brimen')),
                  )
                  .toList();
        } else if (category == 'Toilet') {
          categoryItems =
              allChecklistItems
                  .where(
                    (item) =>
                        item.category == 'Toilet' ||
                        (item.category.isEmpty && item.id.startsWith('toilet')),
                  )
                  .toList();
        } else {
          categoryItems =
              allChecklistItems
                  .where((item) => item.category == category)
                  .toList();
        }

        // Skip empty categories
        if (categoryItems.isEmpty) {
          continue;
        }

        categoryItems.sort(
          (a, b) => a.subcategory.compareTo(b.subcategory),
        ); // Note: Column width setting may depend on the Excel package version
        // sheet.setColumnWidth(0, 5);
        // sheet.setColumnWidth(1, 25);
        // sheet.setColumnWidth(2, 40);
        // sheet.setColumnWidth(3, 12);
        // sheet.setColumnWidth(4, 35);
        // sheet.setColumnWidth(5, 35);

        sheet.merge(
          CellIndex.indexByString("A1"),
          CellIndex.indexByString("F1"),
        );
        sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(
          "CHECKLIST KELENGKAPAN DAN KONDISI LAYANAN UNIT KERJA OPERASIONAL",
        );
        sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;
        sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue(
          "TAHUN ${bankCheckHistory.checkDate.year}",
        );

        int currentRow = 4;
        sheet
            .cell(CellIndex.indexByString("A$currentRow"))
            .value = TextCellValue("NAMA CABANG :");
        sheet
            .cell(CellIndex.indexByString("C$currentRow"))
            .value = TextCellValue(bankBranch.name);
        currentRow++;
        sheet
            .cell(CellIndex.indexByString("A$currentRow"))
            .value = TextCellValue("TANGGAL PENGECEKAN :");
        sheet.cell(CellIndex.indexByString("C$currentRow")).value =
            TextCellValue(displayDateFormat.format(bankCheckHistory.checkDate));
        currentRow++;

        if (['Satpam', 'Teller', 'CS'].contains(sheetName)) {
          sheet
              .cell(CellIndex.indexByString("A$currentRow"))
              .value = TextCellValue("NAMA PETUGAS :");
          sheet
              .cell(CellIndex.indexByString("C$currentRow"))
              .value = TextCellValue(bankCheckHistory.employeeName ?? '-');
          currentRow++;
          sheet
              .cell(CellIndex.indexByString("A$currentRow"))
              .value = TextCellValue("JABATAN :");
          sheet
              .cell(CellIndex.indexByString("C$currentRow"))
              .value = TextCellValue(bankCheckHistory.employeePosition ?? '-');
          currentRow++;
        }

        sheet
            .cell(CellIndex.indexByString("A$currentRow"))
            .value = TextCellValue("DIPERIKSA OLEH :");
        sheet
            .cell(CellIndex.indexByString("C$currentRow"))
            .value = TextCellValue(bankCheckHistory.checkedBy);
        currentRow += 2;
        int tableHeaderRow = currentRow;
        List<String> headers; // Different headers for different sheet types
        if (['CS', 'Teller', 'Satpam'].contains(sheetName)) {
          headers = ["KATEGORI", "GENDER", "PERTANYAAN", "STATUS"];
        } else {
          headers = ["ITEM", "SUB ITEM", "STATUS"];
        }

        sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());
        for (var i = 0; i < headers.length; i++) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: i,
                  rowIndex: tableHeaderRow - 1,
                ),
              )
              .cellStyle = headerStyle;
        } // Fill data based on sheet type
        if (['CS', 'Teller', 'Satpam'].contains(sheetName)) {
          _fillPersonnelSheetData(
            sheet,
            categoryItems,
            tableHeaderRow,
            wrappedTextStyle,
          );
        } else {
          _fillGeneralSheetData(
            sheet,
            categoryItems,
            tableHeaderRow,
            wrappedTextStyle,
          );
        }
      }

      excel.delete('Sheet1');
      final fileName =
          'Ceklis_${bankBranch.name.replaceAll(' ', '_')}_${fileNameDateFormat.format(bankCheckHistory.checkDate)}.xlsx';
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Laporan Ceklis Kualitas Layanan: ${bankBranch.name} - ${displayDateFormat.format(bankCheckHistory.checkDate)}',
        );
      }
    } catch (e, stacktrace) {
      print("Error exporting Excel: $e");
      print("Stacktrace: $stacktrace");
    }
  }

  // Helper method to fill data for personnel sheets (CS, Teller, Satpam)
  void _fillPersonnelSheetData(
    Sheet sheet,
    List<ChecklistItem> categoryItems,
    int tableHeaderRow,
    CellStyle wrappedTextStyle,
  ) {
    int currentRowIndex = tableHeaderRow;

    // Group items by main category and subcategory
    Map<String, List<ChecklistItem>> categoryGroups = {};
    for (var item in categoryItems) {
      String mainCategory = item.category.isEmpty ? 'Umum' : item.category;
      if (!categoryGroups.containsKey(mainCategory)) {
        categoryGroups[mainCategory] = [];
      }
      categoryGroups[mainCategory]!.add(item);
    }

    // Define the order for categories
    List<String> categoryOrder = [
      'Grooming',
      'Sigap',
      'Mudah',
      'Akurat',
      'Ramah',
      'Terampil',
      'Umum',
    ];

    for (String categoryName in categoryOrder) {
      if (!categoryGroups.containsKey(categoryName)) continue;

      List<ChecklistItem> items = categoryGroups[categoryName]!;
      if (categoryName == 'Grooming') {
        // For Grooming, group by subcategory and gender
        Map<String, List<ChecklistItem>> subcategoryGroups = {};
        for (var item in items) {
          String subcat = item.subcategory.isEmpty ? 'Umum' : item.subcategory;
          if (!subcategoryGroups.containsKey(subcat)) {
            subcategoryGroups[subcat] = [];
          }
          subcategoryGroups[subcat]!.add(item);
        }

        // Define subcategory order
        List<String> subcategoryOrder = [
          'Wajah & Badan',
          'Rambut',
          'Jilbab',
          'Pakaian',
          'Atribut & Aksesoris',
          'Umum',
        ];

        for (String subcategoryName in subcategoryOrder) {
          if (!subcategoryGroups.containsKey(subcategoryName)) continue;

          List<ChecklistItem> subcategoryItems =
              subcategoryGroups[subcategoryName]!;
          // Add subcategory header row
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 0,
                  rowIndex: currentRowIndex,
                ),
              )
              .value = TextCellValue(categoryName);
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 1,
                  rowIndex: currentRowIndex,
                ),
              )
              .value = TextCellValue(subcategoryName);
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 2,
                  rowIndex: currentRowIndex,
                ),
              )
              .value = TextCellValue('');
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: 3,
                  rowIndex: currentRowIndex,
                ),
              )
              .value = TextCellValue('');
          currentRowIndex++;

          // Group by gender
          Map<String, List<ChecklistItem>> genderGroups = {
            'Pria': [],
            'Wanita': [],
            'Umum': [],
          };

          for (var item in subcategoryItems) {
            if (item.forHijab == true) {
              genderGroups['Wanita']!.add(item);
            } else if (item.forHijab == false) {
              if (item.question.toLowerCase().contains('pria:')) {
                genderGroups['Pria']!.add(item);
              } else if (item.question.toLowerCase().contains('wanita:')) {
                genderGroups['Wanita']!.add(item);
              } else {
                genderGroups['Umum']!.add(item);
              }
            } else {
              genderGroups['Umum']!.add(item);
            }
          }

          // Fill gender-specific items
          for (String gender in ['Pria', 'Wanita', 'Umum']) {
            for (var item in genderGroups[gender]!) {
              String displayGender = gender == 'Umum' ? '' : gender;
              _fillItemRow(
                sheet,
                item,
                currentRowIndex,
                '',
                displayGender,
                wrappedTextStyle,
              );
              currentRowIndex++;
            }
          }
        }
      } else {
        // For non-Grooming categories, merge category and gender columns
        for (var item in items) {
          _fillItemRow(
            sheet,
            item,
            currentRowIndex,
            categoryName,
            '',
            wrappedTextStyle,
          );
          currentRowIndex++;
        }
      }
    }
  }

  // Helper method to fill data for general sheets (Banking Hall, etc.)
  void _fillGeneralSheetData(
    Sheet sheet,
    List<ChecklistItem> categoryItems,
    int tableHeaderRow,
    CellStyle wrappedTextStyle,
  ) {
    String lastSubCategory = "";
    for (int i = 0; i < categoryItems.length; i++) {
      final item = categoryItems[i];
      final int rowIndex = tableHeaderRow + i;

      // ITEM column (subcategory) - Column A
      if (item.subcategory.isNotEmpty && item.subcategory != lastSubCategory) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .value = TextCellValue(item.subcategory);
        lastSubCategory = item.subcategory;
      }

      // SUB ITEM column (question) - Column B
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(item.question);

      // STATUS column - Column C
      String status = "Belum Diisi";
      if (item.skipped == true) {
        status = "Dilewati";
      } else if (item.answerValue != null) {
        status = item.answerValue! ? "Ya" : "Tidak";
      }
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(status);

      // Apply styles
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .cellStyle = wrappedTextStyle;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .cellStyle = wrappedTextStyle;
    }
  }

  // Helper method to fill a single item row for personnel sheets
  void _fillItemRow(
    Sheet sheet,
    ChecklistItem item,
    int rowIndex,
    String category,
    String gender,
    CellStyle wrappedTextStyle,
  ) {
    // KATEGORI column
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(category);

    // GENDER column
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = TextCellValue(gender);

    // PERTANYAAN column
    String question = item.question;
    // Remove gender prefixes if present
    question = question.replaceAll(RegExp(r'^(Pria:|Wanita:)\s*'), '');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = TextCellValue(question);

    // STATUS column
    String status = "Belum Diisi";
    if (item.skipped == true) {
      status = "Skip";
    } else if (item.answerValue != null) {
      status = item.answerValue! ? "Ya" : "Tidak";
    }
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = TextCellValue(status);

    // Apply styles
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .cellStyle = wrappedTextStyle;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .cellStyle = wrappedTextStyle;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .cellStyle = wrappedTextStyle;
  }
}
