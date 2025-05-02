class BankCheckHistory {
  final String id;
  final String bankBranchId; // Reference to the BankBranch
  final DateTime checkDate;
  final bool isSuccessful;
  final double score; // Overall score for this check
  final Map<String, double> aspectScores; // Individual aspect scores
  final String? notes;
  final String checkedBy; // Person who performed the check

  BankCheckHistory({
    required this.id,
    required this.bankBranchId,
    required this.checkDate,
    required this.isSuccessful,
    required this.score,
    required this.aspectScores,
    this.notes,
    required this.checkedBy,
  });

  // Format the date as a string
  String get formattedDate {
    final day = checkDate.day.toString().padLeft(2, '0');
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[checkDate.month - 1];
    final year = checkDate.year;
    return '$day $month $year';
  }

  // Helper to get aspect score by name
  double getAspectScore(String aspectName) {
    return aspectScores[aspectName] ?? 0.0;
  }

  // Convert from Map (useful for JSON conversion)
  factory BankCheckHistory.fromMap(Map<String, dynamic> map) {
    return BankCheckHistory(
      id: map['id'],
      bankBranchId: map['bankBranchId'],
      checkDate: DateTime.parse(map['checkDate']),
      isSuccessful: map['isSuccessful'],
      score: map['score'],
      aspectScores: Map<String, double>.from(map['aspectScores']),
      notes: map['notes'],
      checkedBy: map['checkedBy'],
    );
  }

  // Convert to Map (useful for JSON conversion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankBranchId': bankBranchId,
      'checkDate': checkDate.toIso8601String(),
      'isSuccessful': isSuccessful,
      'score': score,
      'aspectScores': aspectScores,
      'notes': notes,
      'checkedBy': checkedBy,
    };
  }
}
