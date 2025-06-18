// file: services/excel_export_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Ganti dengan path model Anda yang benar
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/models/checklist_item.dart';

class ExcelExportService {
  final Map<String, String> categoryToSheetName = {
    'Satpam': 'Satpam',
    'Teller': 'Teller',
    'Customer Service': 'CS',
    'Banking Hall': 'Banking Hall',
    'Gallery e-Channel': 'Gallery E-Channel',
    'Fasad Gedung': 'Fasad Gedung',
    'Ruang BRIMEN': 'Ruang BRIMEN',
    'Toilet': 'Toilet',
  };

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
        backgroundColorHex: "#DDEBF7",
        verticalAlign: VerticalAlign.Center,
        wrap: true,
      );
      final CellStyle wrappedTextStyle = CellStyle(
        verticalAlign: VerticalAlign.Top,
        wrap: true,
      );

      final allCategories =
          allChecklistItems.map((e) => e.category).toSet().toList();

      for (var category in allCategories) {
        final sheetName = categoryToSheetName[category] ?? category;
        final sheet = excel[sheetName];
        final categoryItems =
            allChecklistItems
                .where((item) => item.category == category)
                .toList();
        categoryItems.sort((a, b) => a.subcategory.compareTo(b.subcategory));

        sheet.setColWidth(0, 5);
        sheet.setColWidth(1, 25);
        sheet.setColWidth(2, 40);
        sheet.setColWidth(3, 12);
        sheet.setColWidth(4, 35);
        sheet.setColWidth(5, 35);

        sheet.merge(
          CellIndex.indexByString("A1"),
          CellIndex.indexByString("F1"),
        );
        sheet.cell(CellIndex.indexByString("A1")).value = const TextCellValue(
          "CHECKLIST KELENGKAPAN DAN KONDISI LAYANAN UNIT KERJA OPERASIONAL",
        );
        sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;
        sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue(
          "TAHUN ${bankCheckHistory.checkDate.year}",
        );

        int currentRow = 4;
        sheet
            .cell(CellIndex.indexByString("A$currentRow"))
            .value = const TextCellValue("NAMA CABANG :");
        sheet
            .cell(CellIndex.indexByString("C$currentRow"))
            .value = TextCellValue(bankBranch.name);
        currentRow++;
        sheet
            .cell(CellIndex.indexByString("A$currentRow"))
            .value = const TextCellValue("TANGGAL PENGECEKAN :");
        sheet.cell(CellIndex.indexByString("C$currentRow")).value =
            TextCellValue(displayDateFormat.format(bankCheckHistory.checkDate));
        currentRow++;

        if (['Satpam', 'Teller', 'CS'].contains(sheetName)) {
          sheet
              .cell(CellIndex.indexByString("A$currentRow"))
              .value = const TextCellValue("NAMA PETUGAS :");
          sheet
              .cell(CellIndex.indexByString("C$currentRow"))
              .value = TextCellValue(bankCheckHistory.employeeName ?? '-');
          currentRow++;
          sheet
              .cell(CellIndex.indexByString("A$currentRow"))
              .value = const TextCellValue("JABATAN :");
          sheet
              .cell(CellIndex.indexByString("C$currentRow"))
              .value = TextCellValue(bankCheckHistory.employeePosition ?? '-');
          currentRow++;
        }

        sheet
            .cell(CellIndex.indexByString("A$currentRow"))
            .value = const TextCellValue("DIPERIKSA OLEH :");
        sheet
            .cell(CellIndex.indexByString("C$currentRow"))
            .value = TextCellValue(bankCheckHistory.checkedBy);
        currentRow += 2;

        int tableHeaderRow = currentRow;
        List<String> headers = [
          "NO",
          "ITEM",
          "SUB ITEM",
          "STATUS",
          "KETERANGAN",
          "FOTO",
        ];
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
        }

        String lastSubCategory = "";
        for (int i = 0; i < categoryItems.length; i++) {
          final item = categoryItems[i];
          final int rowIndex = tableHeaderRow + i;
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
              )
              .value = TextCellValue((i + 1).toString());
          if (item.subcategory.isNotEmpty &&
              item.subcategory != lastSubCategory) {
            sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 1,
                    rowIndex: rowIndex,
                  ),
                )
                .value = TextCellValue(item.subcategory);
            lastSubCategory = item.subcategory;
          }
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
              )
              .value = TextCellValue(item.question);
          String status = "Belum Diisi";
          if (item.skipped == true)
            status = "Dilewati";
          else if (item.answerValue != null)
            status = item.answerValue! ? "Ya" : "Tidak";
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
              )
              .value = TextCellValue(status);
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
              )
              .value = TextCellValue(item.note ?? '');
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
              )
              .value = const TextCellValue('');
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
              )
              .cellStyle = wrappedTextStyle;
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
              )
              .cellStyle = wrappedTextStyle;
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
              )
              .cellStyle = wrappedTextStyle;
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
      debugPrint("Error exporting Excel: $e");
      debugPrint("Stacktrace: $stacktrace");
    }
  }
}
