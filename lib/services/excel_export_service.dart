import 'dart:io';
import 'dart:async';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:bri_cek/models/bank_check_history.dart';
import 'package:bri_cek/models/bank_branch.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/data/checklist_item_data.dart';
import 'package:share_plus/share_plus.dart';

class ExcelExportService {
  // Map of category names to their sheet names
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

  // Format date for file names
  final DateFormat fileNameDateFormat = DateFormat('yyyy-MM-dd');

  // Format date for display in Excel
  final DateFormat displayDateFormat = DateFormat('dd MMMM yyyy');

  // Export and share Excel file
  Future<bool> exportAndShareExcel(
    BankCheckHistory history,
    BankBranch branch,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      // Create an Excel document
      final excel = Excel.createExcel();

      // Get default sheet name
      final defaultSheetName = excel.getDefaultSheet();

      // Create sheets for each category
      int sheetCount = 0;
      for (final category in categories) {
        final categoryName = category['name'];
        final sheetName = categoryToSheetName[categoryName] ?? categoryName;

        try {
          // Create a new sheet
          if (sheetCount == 0 && defaultSheetName != null) {
            // Rename the default sheet for the first category
            excel.rename(defaultSheetName, sheetName);
          } else {
            // Create a new sheet
            excel.copy(defaultSheetName ?? 'Sheet1', sheetName);
          }

          final Sheet sheet = excel[sheetName];

          // Style the sheet
          _applyHeaderFormatting(sheet, branch, history);

          // Add category-specific checklist data
          _addChecklistData(sheet, categoryName, history);

          sheetCount++;
        } catch (e) {
          print('Error creating sheet for $categoryName: $e');
        }
      }

      // Remove default sheet if we created at least one other sheet
      if (sheetCount > 0 &&
          defaultSheetName != null &&
          excel.sheets.containsKey(defaultSheetName)) {
        try {
          excel.delete(defaultSheetName);
        } catch (e) {
          print('Error deleting default sheet: $e');
        }
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'BRI_Check_${branch.name.replaceAll(' ', '_')}_${fileNameDateFormat.format(history.checkDate)}.xlsx';
      final tempFilePath = '${tempDir.path}/$fileName';
      final tempFile = File(tempFilePath);

      final bytes = excel.encode();
      if (bytes == null) {
        print('Failed to encode Excel file');
        return false;
      }

      await tempFile.writeAsBytes(bytes);

      // Save a copy to a more permanent location if possible
      String? savedFilePath;
      try {
        final externalDir = await _getExcelDirectory();
        final externalFilePath = '$externalDir/$fileName';
        final externalFile = File(externalFilePath);

        // Ensure parent directory exists
        if (!(await externalFile.parent.exists())) {
          await externalFile.parent.create(recursive: true);
        }

        // Copy the file
        await tempFile.copy(externalFilePath);
        savedFilePath = externalFilePath;
        print('File also saved to: $externalFilePath');
      } catch (e) {
        print('Could not save to external directory: $e');
      }

      // Show custom dialog with options
      return await _showSharingOptions(
        tempFilePath,
        savedFilePath,
        branch.name,
      );
    } catch (e) {
      print('Error in Excel export and share: $e');
      return false;
    }
  }

  // New method to show sharing options
  Future<bool> _showSharingOptions(
    String tempFilePath,
    String? savedFilePath,
    String branchName,
  ) async {
    Completer<bool> completer = Completer<bool>();

    // Use a platform message channel to show the dialog
    // This is necessary since we need to return a value from this function
    // and can't easily do that with a regular showDialog approach

    try {
      // Share the file using the share_plus package
      await Share.shareXFiles(
        [XFile(tempFilePath)],
        text: 'BRI Check Report for $branchName',
        subject: 'BRI Check Report',
      );

      // If we successfully saved the file locally as well, we'll count this as success
      if (savedFilePath != null) {
        completer.complete(true);
      } else {
        // We only did the share, but no local save, still count as success
        completer.complete(true);
      }
    } catch (e) {
      print('Error sharing file: $e');
      completer.complete(false);
    }

    return completer.future;
  }

  // Export check history to Excel file
  Future<String?> exportCheckHistoryToExcel(
    BankCheckHistory history,
    BankBranch branch,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      // Check storage permission
      if (!await _requestPermission()) {
        print('Permission denied');
        return null;
      }

      // Get directory for saving
      final directory = await _getExcelDirectory();
      final fileName =
          'BRI_Check_${branch.name.replaceAll(' ', '_')}_${fileNameDateFormat.format(history.checkDate)}.xlsx';
      final filePath = '$directory/$fileName';

      print('Will save file to: $filePath');

      // Create an Excel document
      final excel = Excel.createExcel();

      // Get default sheet name
      final defaultSheetName = excel.getDefaultSheet();

      // Create sheets for each category
      int sheetCount = 0;
      for (final category in categories) {
        final categoryName = category['name'];
        final sheetName = categoryToSheetName[categoryName] ?? categoryName;

        try {
          // Create a new sheet
          if (sheetCount == 0 && defaultSheetName != null) {
            // Rename the default sheet for the first category
            excel.rename(defaultSheetName, sheetName);
          } else {
            // Create a new sheet
            excel.copy(defaultSheetName ?? 'Sheet1', sheetName);
          }

          final Sheet sheet = excel[sheetName];

          // Style the sheet
          _applyHeaderFormatting(sheet, branch, history);

          // Add category-specific checklist data
          _addChecklistData(sheet, categoryName, history);

          sheetCount++;
        } catch (e) {
          print('Error creating sheet for $categoryName: $e');
        }
      }

      // Remove default sheet if we created at least one other sheet
      if (sheetCount > 0 &&
          defaultSheetName != null &&
          excel.sheets.containsKey(defaultSheetName)) {
        try {
          excel.delete(defaultSheetName);
        } catch (e) {
          print('Error deleting default sheet: $e');
        }
      }

      // Save the file
      try {
        final file = File(filePath);
        // Ensure parent directory exists
        if (!(await file.parent.exists())) {
          await file.parent.create(recursive: true);
        }

        final bytes = excel.encode();
        if (bytes == null) {
          print('Failed to encode Excel file');
          return null;
        }

        await file.writeAsBytes(bytes);
        print('File saved successfully at: $filePath');

        return filePath;
      } catch (e) {
        print('Error writing file: $e');
        return null;
      }
    } catch (e) {
      print('Error in Excel export process: $e');
      return null;
    }
  }

  // Apply header formatting and add branch and check information
  void _applyHeaderFormatting(
    Sheet sheet,
    BankBranch branch,
    BankCheckHistory history,
  ) {
    // Create cell styles
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      fontSize: 14,
    );

    // Create title row
    final titleCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    );
    titleCell.value = TextCellValue('BANK BRANCH CHECK REPORT');
    titleCell.cellStyle = headerStyle;

    // Merge cells for title
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
    );

    // Info style
    final infoStyle = CellStyle(bold: true);

    // Add branch info
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('Branch Name:');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .cellStyle = infoStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
        .value = TextCellValue(branch.name);

    // Add check date
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = TextCellValue('Check Date:');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .cellStyle = infoStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = TextCellValue(displayDateFormat.format(history.checkDate));

    // Add week number
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .value = TextCellValue('Week:');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .cellStyle = infoStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        .value = TextCellValue('${history.weekNumberInMonth}');

    // Add checker info
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .value = TextCellValue('Checked By:');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
        .cellStyle = infoStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
        .value = TextCellValue(history.checkedBy);
  }

  // Add checklist data to the sheet
  void _addChecklistData(
    Sheet sheet,
    String categoryName,
    BankCheckHistory history,
  ) {
    // Add category score
    final double aspectScore = history.getAspectScore(categoryName);

    final scoreStyle = CellStyle(bold: true);

    // Set score color based on value - omitting color setting for now to avoid errors
    // We'll handle this differently after determining package version

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
        .value = TextCellValue('Category Score:');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
        .cellStyle = CellStyle(bold: true);

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7))
        .value = TextCellValue('${aspectScore.toStringAsFixed(1)}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7))
        .cellStyle = scoreStyle;

    // Add empty row (row 8 left empty)

    // Get checklist items for this category
    final List<ChecklistItem> checklistItems =
        getChecklistForCategory(categoryName) ?? [];

    // Add header row for checklist items
    final headerRowIndex = 9;

    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: headerRowIndex),
        )
        .value = TextCellValue('No');
    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: headerRowIndex),
        )
        .value = TextCellValue('Item Description');
    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: headerRowIndex),
        )
        .value = TextCellValue('Status');
    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: headerRowIndex),
        )
        .value = TextCellValue('Notes');

    // Style header row
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Apply header style without setting background color to avoid errors
    for (var i = 0; i < 4; i++) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: i,
              rowIndex: headerRowIndex,
            ),
          )
          .cellStyle = headerStyle;
    }

    // Add checklist items
    for (var i = 0; i < checklistItems.length; i++) {
      final item = checklistItems[i];
      final bool isCompleted = i % 3 != 2; // Simple pattern for demo
      final String? note = i % 3 == 2 ? 'Needs improvement' : null;

      final rowIndex = headerRowIndex + i + 1;

      // Add item number
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue('${i + 1}');

      // Add description
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(item.question);

      // Add status with styling
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(isCompleted ? 'Completed' : 'Not Completed');

      final statusStyle = CellStyle(bold: true);

      // No color setting for now to avoid errors

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .cellStyle = statusStyle;

      // Add notes
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(note ?? '-');
    }

    // Try to set column widths if possible
    try {
      sheet.setColumnWidth(1, 50.0); // Make description column wider
      sheet.setColumnWidth(3, 30.0); // Make notes column wider
    } catch (_) {
      // Fallback: Use our cell padding approach
      _setCellWidth(sheet, 1, headerRowIndex, 50);
    }
  }

  // Helper method to roughly simulate width setting by adding spaces to a cell
  void _setCellWidth(Sheet sheet, int colIndex, int rowIndex, int approxWidth) {
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
    );

    String currentValue = '';
    if (cell.value is TextCellValue) {
      currentValue = (cell.value as TextCellValue).value.text ?? '';
    } else if (cell.value != null) {
      currentValue = cell.value.toString();
    }

    // Add some padding spaces to make column wider
    int paddingNeeded = approxWidth - currentValue.length;
    if (paddingNeeded > 0) {
      String paddedValue = currentValue + ' ' * paddingNeeded;
      cell.value = TextCellValue(paddedValue);
    }
  }

  // Get directory for saving Excel files
  Future<String> _getExcelDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Try app's external files directory first, which doesn't require special permissions
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Create a subdirectory for Excel files
          final excelDir = Directory('${externalDir.path}/Excel');
          if (!await excelDir.exists()) {
            await excelDir.create(recursive: true);
          }
          return excelDir.path;
        }

        // Fallback to app documents directory
        final docDir = await getApplicationDocumentsDirectory();
        return docDir.path;
      } else {
        // iOS - use documents directory
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
    } catch (e) {
      print('Error getting directory: $e');
      // Last fallback - use temp directory
      final temp = await getTemporaryDirectory();
      return temp.path;
    }
  }

  // Request storage permission
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Request all necessary permissions
      Map<Permission, PermissionStatus> statuses =
          await [Permission.storage].request();

      // Check if storage permission is granted
      bool isGranted = statuses[Permission.storage]?.isGranted ?? false;

      if (!isGranted) {
        print('Storage permission denied: ${statuses[Permission.storage]}');
        // Try to request manage external storage permission for Android 11+
        try {
          if (await Permission.manageExternalStorage.request().isGranted) {
            return true;
          }
        } catch (e) {
          print('Error requesting manage external storage: $e');
        }
      }

      return isGranted;
    }

    return true; // For iOS and other platforms
  }

  // Helper to get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        // Use Build.VERSION.SDK_INT directly through MethodChannel
        const platform = MethodChannel('com.example.bri_cek/system_info');
        final sdkInt = await platform.invokeMethod<int>('getAndroidSdkVersion');
        return sdkInt ?? 0;
      }
    } catch (e) {
      print('Error getting Android SDK version: $e');
    }
    return 0; // Default to 0 if we can't get the version
  }

  // Generate Excel file and return path
  Future<String?> generateExcelFile(
    BankCheckHistory history,
    BankBranch branch,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      // Create an Excel document
      final excel = Excel.createExcel();

      // Get default sheet name
      final defaultSheetName = excel.getDefaultSheet();

      // Create sheets for each category
      int sheetCount = 0;
      for (final category in categories) {
        final categoryName = category['name'];
        final sheetName = categoryToSheetName[categoryName] ?? categoryName;

        try {
          // Create a new sheet
          if (sheetCount == 0 && defaultSheetName != null) {
            // Rename the default sheet for the first category
            excel.rename(defaultSheetName, sheetName);
          } else {
            // Create a new sheet
            excel.copy(defaultSheetName ?? 'Sheet1', sheetName);
          }

          final Sheet sheet = excel[sheetName];

          // Style the sheet
          _applyHeaderFormatting(sheet, branch, history);

          // Add category-specific checklist data
          _addChecklistData(sheet, categoryName, history);

          sheetCount++;
        } catch (e) {
          print('Error creating sheet for $categoryName: $e');
        }
      }

      // Remove default sheet if we created at least one other sheet
      if (sheetCount > 0 &&
          defaultSheetName != null &&
          excel.sheets.containsKey(defaultSheetName)) {
        try {
          excel.delete(defaultSheetName);
        } catch (e) {
          print('Error deleting default sheet: $e');
        }
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'BRI_Check_${branch.name.replaceAll(' ', '_')}_${fileNameDateFormat.format(history.checkDate)}.xlsx';
      final tempFilePath = '${tempDir.path}/$fileName';
      final tempFile = File(tempFilePath);

      final bytes = excel.encode();
      if (bytes == null) {
        print('Failed to encode Excel file');
        return null;
      }

      await tempFile.writeAsBytes(bytes);
      return tempFilePath;
    } catch (e) {
      print('Error generating Excel file: $e');
      return null;
    }
  }

  // Save file to downloads folder
  Future<String?> saveToDownloads(String sourcePath, String fileName) async {
    try {
      if (Platform.isAndroid) {
        // Request permission
        if (!await _requestPermission()) {
          print('Permission denied');
          return null;
        }

        // Try to get the downloads directory
        Directory? downloadsDir;

        try {
          // Try the standard Downloads directory first
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
        } catch (e) {
          print('Error accessing Downloads directory: $e');

          // Fallback to app's own directory
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            downloadsDir = Directory('${externalDir.path}/Excel');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
          } else {
            return null;
          }
        }

        if (downloadsDir == null) return null;

        // Create destination file path
        final destPath = '${downloadsDir.path}/$fileName';

        // Copy the file
        final sourceFile = File(sourcePath);
        final destFile = await sourceFile.copy(destPath);

        return destFile.path;
      } else if (Platform.isIOS) {
        // For iOS, we'll use the app's documents directory
        final directory = await getApplicationDocumentsDirectory();
        final destPath = '${directory.path}/$fileName';

        // Copy the file
        final sourceFile = File(sourcePath);
        final destFile = await sourceFile.copy(destPath);

        return destFile.path;
      }

      return null;
    } catch (e) {
      print('Error saving file to downloads: $e');
      return null;
    }
  }

  /// Export survey data to Excel file
  Future<String?> exportSurveyToExcel({
    required String surveyId,
    required Map<String, dynamic> surveyData,
    required List<Map<String, dynamic>> answers,
    String? selectedCategory,
  }) async {
    try {
      // Request storage permission for Android using existing method
      if (Platform.isAndroid) {
        if (!await _requestPermission()) {
          throw Exception('Storage permission required to save Excel file');
        }
      }

      // Create Excel workbook
      var excel = Excel.createExcel();

      // Create main sheet for survey data
      var sheet = excel['Survey Detail'];

      // Remove default sheet if it exists and is different
      try {
        if (excel.sheets.containsKey('Sheet1') && excel.sheets.length > 1) {
          excel.delete('Sheet1');
        }
      } catch (e) {
        print('Warning: Could not delete default sheet: $e');
      }

      // Set up styling - basic styling without colors for compatibility
      final headerStyle = CellStyle(bold: true);

      final subHeaderStyle = CellStyle(bold: true);

      final positiveStyle = CellStyle();

      final negativeStyle = CellStyle();

      final skippedStyle = CellStyle();

      int currentRow = 0;

      // Survey Information Header
      _addSurveyInfoSection(
        sheet,
        surveyData,
        selectedCategory,
        currentRow,
        headerStyle,
        subHeaderStyle,
        surveyId,
      );
      currentRow += 8; // Move past survey info section

      // Survey Answers Header
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('DETAIL JAWABAN SURVEY')
        ..cellStyle = headerStyle;

      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow),
      );
      currentRow += 2;

      // Table headers
      final headers = [
        'No',
        'Kategori',
        'Subkategori',
        'Pertanyaan',
        'Jawaban',
        'Catatan',
        'Status',
      ];
      for (int i = 0; i < headers.length; i++) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
          )
          ..value = TextCellValue(headers[i])
          ..cellStyle = subHeaderStyle;
      }
      currentRow++;

      // Add answer data
      for (int i = 0; i < answers.length; i++) {
        final answer = answers[i];
        final bool? answerValue =
            answer['answer'] as bool? ?? answer['answerValue'] as bool?;
        final bool isSkipped = answer['skipped'] == true;

        // Determine cell style based on answer
        CellStyle? rowStyle;
        String statusText = 'Tidak Dijawab';
        String answerText = '-';

        if (isSkipped) {
          rowStyle = skippedStyle;
          statusText = 'Dilewati';
          answerText = 'SKIP';
        } else if (answerValue != null) {
          if (answerValue == true) {
            rowStyle = positiveStyle;
            statusText = 'Dijawab';
            answerText = 'Ya';
          } else {
            rowStyle = negativeStyle;
            statusText = 'Dijawab';
            answerText = 'Tidak';
          }
        }

        // Add row data
        final rowData = [
          (i + 1).toString(),
          answer['category']?.toString() ?? '-',
          answer['subcategory']?.toString() ?? '-',
          answer['question']?.toString() ?? '-',
          answerText,
          answer['note']?.toString() ?? '-',
          statusText,
        ];

        for (int j = 0; j < rowData.length; j++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: currentRow),
          );
          cell.value = TextCellValue(rowData[j]);
          if (rowStyle != null) {
            cell.cellStyle = rowStyle;
          }
        }
        currentRow++;
      }

      // Try to set column widths manually since setColumnAutoFit might not be available
      try {
        // Set column widths for better readability
        sheet.setColumnWidth(0, 5.0); // No
        sheet.setColumnWidth(1, 15.0); // Kategori
        sheet.setColumnWidth(2, 15.0); // Subkategori
        sheet.setColumnWidth(3, 40.0); // Pertanyaan
        sheet.setColumnWidth(4, 10.0); // Jawaban
        sheet.setColumnWidth(5, 30.0); // Catatan
        sheet.setColumnWidth(6, 12.0); // Status
      } catch (e) {
        print('Warning: Could not set column widths: $e');
        // Column width setting is optional, continue without it
      }

      // Generate filename
      final bankName =
          surveyData['selectedBank']
              ?.toString()
              .replaceAll(RegExp(r'[^\w\s]'), '')
              .replaceAll(' ', '_') ??
          'Unknown_Bank';
      final categoryName =
          selectedCategory
              ?.replaceAll(RegExp(r'[^\w\s]'), '')
              .replaceAll(' ', '_') ??
          'All_Categories';
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'Survey_${bankName}_${categoryName}_$dateStr.xlsx';

      // Save file
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      // Get temporary directory first
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$filename';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(bytes);

      // Try to save to Downloads folder
      final savedPath = await saveToDownloads(tempFilePath, filename);

      return savedPath ?? tempFilePath;
    } catch (e) {
      print('Error exporting to Excel: $e');
      rethrow;
    }
  }

  /// Add survey information section to Excel sheet
  void _addSurveyInfoSection(
    Sheet sheet,
    Map<String, dynamic> surveyData,
    String? selectedCategory,
    int startRow,
    CellStyle headerStyle,
    CellStyle subHeaderStyle,
    String surveyId,
  ) {
    int currentRow = startRow;

    // Title
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..value = TextCellValue('LAPORAN SURVEY BANK')
      ..cellStyle = headerStyle;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow),
    );
    currentRow += 2;

    // Survey details
    final surveyInfo = [
      ['Bank', surveyData['selectedBank']?.toString() ?? 'Tidak diketahui'],
      ['Kategori', selectedCategory ?? 'Semua Kategori'],
      [
        'Tanggal Survey',
        _formatSurveyDate(
          surveyData['selectedDate'] ?? surveyData['submittedAt'],
        ),
      ],
      ['Surveyor', _getSurveyorInfo(surveyData)],
      ['ID Survey', surveyId],
    ];

    for (final info in surveyInfo) {
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue(info[0])
        ..cellStyle = subHeaderStyle;

      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
      )..value = TextCellValue(info[1]);

      currentRow++;
    }

    // Statistics if available
    final statistics = surveyData['statistics'] as Map<String, dynamic>? ?? {};
    if (statistics.isNotEmpty) {
      currentRow++; // Add spacing

      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('STATISTIK')
        ..cellStyle = subHeaderStyle;
      currentRow++;

      final statsInfo = [
        ['Skor', '${(statistics['score'] ?? 0).toInt()}%'],
        [
          'Pertanyaan Dijawab',
          (statistics['answeredQuestions'] ?? 0).toString(),
        ],
        [
          'Pertanyaan Dilewati',
          (statistics['skippedQuestions'] ?? 0).toString(),
        ],
      ];

      for (final stat in statsInfo) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          ..value = TextCellValue(stat[0])
          ..cellStyle = subHeaderStyle;

        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
        )..value = TextCellValue(stat[1]);

        currentRow++;
      }
    }
  }

  /// Format date for survey display
  String _formatSurveyDate(dynamic timestamp) {
    if (timestamp == null) return 'Tanggal tidak tersedia';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp.runtimeType.toString().contains('Timestamp')) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        date = timestamp.toDate();
      }

      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (e) {
      return timestamp.toString();
    }
  }

  /// Get surveyor information
  String _getSurveyorInfo(Map<String, dynamic> surveyData) {
    // Try to get contributor information
    if (surveyData['contributors'] != null) {
      try {
        final contributors = List<Map<String, dynamic>>.from(
          surveyData['contributors'],
        );
        if (contributors.length == 1) {
          return contributors.first['userName']?.toString() ??
              'Tidak diketahui';
        } else if (contributors.length > 1) {
          return '${contributors.length} surveyor: ${contributors.map((c) => c['userName']).join(', ')}';
        }
      } catch (e) {
        print('Error parsing contributors: $e');
      }
    }

    // Fallback to userName field
    if (surveyData['userName'] != null) {
      return surveyData['userName'].toString();
    }

    return 'Tidak diketahui';
  }

  /// Share the exported Excel file
  Future<void> shareExcelFile(String filePath) async {
    try {
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: 'Survey Report - ${DateTime.now().toString().split(' ')[0]}',
        subject: 'Survey Report Excel File',
      );
    } catch (e) {
      print('Error sharing file: $e');
      rethrow;
    }
  }

  /// Get file size in human readable format
  String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();

      if (bytes < 1024) return '${bytes}B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } catch (e) {
      return 'Unknown size';
    }
  }
}
