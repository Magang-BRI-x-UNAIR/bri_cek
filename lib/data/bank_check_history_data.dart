import 'package:bri_cek/models/bank_check_history.dart';

// Sample data for bank check history
final List<BankCheckHistory> checkHistories = [
  BankCheckHistory(
    id: '1',
    bankBranchId: '1', // KK Genteng Kali Surabaya
    checkDate: DateTime(2025, 4, 9),
    isSuccessful: true,
    score: 85.0,
    aspectScores: {
      'Pelayanan': 90.0,
      'Kerapihan': 80.0,
      'Kebersihan Kantor': 85.0,
      'Kelengkapan Kantor': 85.0,
    },
    notes: 'Overall good condition, but some areas need improvement.',
    checkedBy: 'John Doe',
  ),
  BankCheckHistory(
    id: '2',
    bankBranchId: '1', // KK Genteng Kali Surabaya
    checkDate: DateTime(2025, 4, 8),
    isSuccessful: false,
    score: 65.0,
    aspectScores: {
      'Pelayanan': 60.0,
      'Kerapihan': 70.0,
      'Kebersihan Kantor': 65.0,
      'Kelengkapan Kantor': 65.0,
    },
    notes: 'Multiple areas require immediate attention.',
    checkedBy: 'Jane Smith',
  ),
  BankCheckHistory(
    id: '3',
    bankBranchId: '1', // KK Genteng Kali Surabaya
    checkDate: DateTime(2025, 4, 7),
    isSuccessful: true,
    score: 88.0,
    aspectScores: {
      'Pelayanan': 90.0,
      'Kerapihan': 85.0,
      'Kebersihan Kantor': 90.0,
      'Kelengkapan Kantor': 87.0,
    },
    notes: 'Very good performance across all areas.',
    checkedBy: 'John Doe',
  ),
  BankCheckHistory(
    id: '4',
    bankBranchId: '1', // KK Genteng Kali Surabaya
    checkDate: DateTime(2025, 4, 5),
    isSuccessful: true,
    score: 92.0,
    aspectScores: {
      'Pelayanan': 95.0,
      'Kerapihan': 90.0,
      'Kebersihan Kantor': 90.0,
      'Kelengkapan Kantor': 93.0,
    },
    notes: 'Excellent overall condition.',
    checkedBy: 'Alice Johnson',
  ),
  // Add histories for other bank branches
  BankCheckHistory(
    id: '5',
    bankBranchId: '2', // KK Gubeng Surabaya
    checkDate: DateTime(2025, 4, 10),
    isSuccessful: true,
    score: 82.0,
    aspectScores: {
      'Pelayanan': 85.0,
      'Kerapihan': 80.0,
      'Kebersihan Kantor': 80.0,
      'Kelengkapan Kantor': 83.0,
    },
    notes: 'Good service, minor improvements needed in cleanliness.',
    checkedBy: 'John Doe',
  ),
  BankCheckHistory(
    id: '6',
    bankBranchId: '3', // KK Bulog Surabaya
    checkDate: DateTime(2025, 4, 11),
    isSuccessful: false,
    score: 68.0,
    aspectScores: {
      'Pelayanan': 65.0,
      'Kerapihan': 70.0,
      'Kebersihan Kantor': 60.0,
      'Kelengkapan Kantor': 77.0,
    },
    notes: 'Urgent improvements needed in service and cleanliness.',
    checkedBy: 'Jane Smith',
  ),
];

// Helper function to get histories for a specific bank branch
List<BankCheckHistory> getHistoriesForBranch(String branchId) {
  return checkHistories
      .where((history) => history.bankBranchId == branchId)
      .toList();
}

// Get week number in month for a given date (1-based)
int getWeekNumberInMonth(DateTime date) {
  final firstDayOfMonth = DateTime(date.year, date.month, 1);
  final dayOfMonth = date.day;
  return ((dayOfMonth - 1) ~/ 7) + 1;
}

// Check if a bank branch already has a check in a specific week of a month
bool hasCheckInWeek(String branchId, int year, int month, int weekNumber) {
  return checkHistories.any(
    (history) =>
        history.bankBranchId == branchId &&
        history.checkDate.year == year &&
        history.checkDate.month == month &&
        history.weekNumberInMonth == weekNumber,
  );
}

// Get the next available date for checking (first day of the next available week)
DateTime? getNextAvailableCheckDate(String branchId) {
  // Get the current date
  final now = DateTime.now();

  // Check if current week already has a check
  final currentWeekNumber = getWeekNumberInMonth(now);
  if (!hasCheckInWeek(branchId, now.year, now.month, currentWeekNumber)) {
    // Current week is available
    return now;
  }

  // Calculate the start of the next week
  int daysToAdd = 7 - (now.weekday % 7);
  if (daysToAdd == 7) daysToAdd = 0; // If today is Sunday
  final nextWeekStart = now.add(Duration(days: daysToAdd));

  return nextWeekStart;
}
