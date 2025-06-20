class AssessmentSession {
  final String id;
  final String userId;
  final String bankBranchId;
  final DateTime sessionDate;
  final List<String> completedCategories;
  final bool isSessionCompleted;
  final double? totalSessionScore;
  final Map<String, double> categoryScores; // Ganti dari aspectScores
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssessmentSession({
    required this.id,
    required this.userId,
    required this.bankBranchId,
    required this.sessionDate,
    this.completedCategories = const [],
    this.isSessionCompleted = false,
    this.totalSessionScore,
    this.categoryScores = const {},
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Keep your existing helper methods
  String get formattedDate {
    final day = sessionDate.day.toString().padLeft(2, '0');
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
    final month = months[sessionDate.month - 1];
    final year = sessionDate.year;
    return '$day $month $year';
  }

  int get weekNumberInMonth {
    final dayOfMonth = sessionDate.day;
    return ((dayOfMonth - 1) ~/ 7) + 1;
  }

  String get formattedDateWithWeek {
    final weekNum = weekNumberInMonth;
    return '$formattedDate (Week $weekNum)';
  }

  double getCategoryScore(String categoryName) {
    return categoryScores[categoryName] ?? 0.0;
  }

  // Convert from Firestore
  factory AssessmentSession.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AssessmentSession(
      id: documentId,
      userId: map['userId'] ?? '',
      bankBranchId: map['bankBranchId'] ?? '',
      sessionDate: DateTime.fromMillisecondsSinceEpoch(map['sessionDate']),
      completedCategories: List<String>.from(map['completedCategories'] ?? []),
      isSessionCompleted: map['isSessionCompleted'] ?? false,
      totalSessionScore: map['totalSessionScore']?.toDouble(),
      categoryScores: Map<String, double>.from(map['categoryScores'] ?? {}),
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bankBranchId': bankBranchId,
      'sessionDate': sessionDate.millisecondsSinceEpoch,
      'completedCategories': completedCategories,
      'isSessionCompleted': isSessionCompleted,
      'totalSessionScore': totalSessionScore,
      'categoryScores': categoryScores,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
