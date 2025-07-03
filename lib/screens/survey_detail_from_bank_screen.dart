import 'package:flutter/material.dart';
import 'package:bri_cek/services/survey_result_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyDetailFromBankScreen extends StatefulWidget {
  final String surveyId;
  final Map<String, dynamic> surveyData;
  final String? selectedCategory;

  const SurveyDetailFromBankScreen({
    Key? key,
    required this.surveyId,
    required this.surveyData,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<SurveyDetailFromBankScreen> createState() =>
      _SurveyDetailFromBankScreenState();
}

class _SurveyDetailFromBankScreenState
    extends State<SurveyDetailFromBankScreen> {
  final SurveyResultService _surveyResultService = SurveyResultService();
  List<Map<String, dynamic>> _answers = [];
  List<Map<String, dynamic>> _filteredAnswers = [];
  List<String> _subcategories = [];
  String? _selectedSubcategory;
  bool _isLoading = true;
  String? _error;

  // Mapping untuk mengatasi variasi penulisan subcategory
  final Map<String, List<String>> _subcategoryVariations = {
    'akurat': ['akurat', 'accurate', 'accurat', 'akurasi', 'accuracy', 'tepat'],
    'sigap': ['sigap', 'cepat', 'responsive', 'tanggap', 'responsif'],
    'grooming': ['grooming', 'groming', 'penampilan', 'appearance'],
    'ramah': ['ramah', 'friendly', 'sopan', 'santun', 'polite'],
    'mudah': ['mudah', 'easy', 'simple', 'sederhana'],
  };

  @override
  void initState() {
    super.initState();
    // Debug print survey data
    print('Survey ID: ${widget.surveyId}');
    print('Selected Category: ${widget.selectedCategory}');
    print('Survey Data: ${widget.surveyData.keys.toList()}');
    if (widget.surveyData['selectedDate'] != null) {
      print('Selected Date: ${widget.surveyData['selectedDate']}');
    }
    if (widget.surveyData['categories'] != null) {
      print('Categories: ${widget.surveyData['categories']}');
    }
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Map<String, dynamic>> answers = [];

      // Debug print for tracking
      print(
        'Loading answers for category: ${widget.selectedCategory ?? "all"}',
      );

      try {
        if (widget.selectedCategory != null) {
          // Load jawaban untuk kategori tertentu
          answers = await _surveyResultService.getSurveyAnswersByCategory(
            widget.surveyId,
            widget.selectedCategory!,
          );
        } else {
          // Load semua jawaban
          answers = await _surveyResultService.getSurveyAnswers(
            widget.surveyId,
          );
        }
      } catch (specificError) {
        print('First attempt failed: $specificError');

        // Fallback method: get all answers and filter manually if category-specific query fails
        final allAnswers = await _surveyResultService.getSurveyAnswers(
          widget.surveyId,
        );

        if (widget.selectedCategory != null) {
          print(
            'Trying client-side filtering for category: ${widget.selectedCategory}',
          );

          // Enhanced filtering with multiple strategies

          // 1. First try exact match
          answers =
              allAnswers
                  .where(
                    (answer) => answer['category'] == widget.selectedCategory,
                  )
                  .toList();

          // 2. If no results, try case insensitive match
          if (answers.isEmpty) {
            print('No exact matches, trying case-insensitive match');
            answers =
                allAnswers
                    .where(
                      (answer) =>
                          answer['category'] != null &&
                          answer['category'].toString().toLowerCase() ==
                              widget.selectedCategory!.toLowerCase(),
                    )
                    .toList();
          }

          // 3. If still no results, try substring match
          if (answers.isEmpty) {
            print('No case-insensitive matches, trying substring match');
            answers =
                allAnswers
                    .where(
                      (answer) =>
                          answer['category'] != null &&
                          (answer['category'].toString().toLowerCase().contains(
                                widget.selectedCategory!.toLowerCase(),
                              ) ||
                              widget.selectedCategory!.toLowerCase().contains(
                                answer['category'].toString().toLowerCase(),
                              )),
                    )
                    .toList();
          }

          // 4. Special handling for Satpam
          if (answers.isEmpty &&
              (widget.selectedCategory!.toLowerCase() == 'satpam' ||
                  widget.selectedCategory!.toLowerCase().contains('satpam'))) {
            print('Trying special match for Satpam');
            answers =
                allAnswers
                    .where(
                      (answer) =>
                          answer['category'] != null &&
                          answer['category'].toString().toLowerCase().contains(
                            'satpam',
                          ),
                    )
                    .toList();

            if (answers.isEmpty) {
              // Try with any security related terms
              print('Trying security related terms');
              answers =
                  allAnswers
                      .where(
                        (answer) =>
                            answer['category'] != null &&
                            (answer['category']
                                    .toString()
                                    .toLowerCase()
                                    .contains('securit') ||
                                answer['category']
                                    .toString()
                                    .toLowerCase()
                                    .contains('keamanan')),
                      )
                      .toList();
            }
          }
        } else {
          // If no category selected, use all answers
          answers = allAnswers;
        }

        // Print available categories for debugging
        if (answers.isEmpty) {
          final availableCategories =
              allAnswers
                  .map((a) => a['category']?.toString() ?? 'null')
                  .toSet()
                  .toList();
          print('Available categories in answers: $availableCategories');
        }

        // Sort by order if present
        answers.sort((a, b) {
          final orderA = a['order'] as num? ?? 0;
          final orderB = b['order'] as num? ?? 0;
          return orderA.compareTo(orderB);
        });
      }

      print('Found ${answers.length} answers for display');

      // Extract unique subcategories for filtering
      _subcategories = _extractSubcategories(answers);
      print('Found subcategories: $_subcategories');

      // Apply initial filtering (no filter)
      _updateFilteredAnswers(answers);

      setState(() {
        _answers = answers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading answers: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Extract all unique subcategories from answers
  List<String> _extractSubcategories(List<Map<String, dynamic>> answers) {
    final subcategories = <String>{};
    final Map<String, int> subcategoryCount = {};

    for (var answer in answers) {
      if (answer['subcategory'] != null &&
          answer['subcategory'].toString().isNotEmpty) {
        // Normalisasi subcategory untuk menghindari perbedaan penulisan
        String originalSubcategory = answer['subcategory'].toString();
        String normalizedSubcategory = _normalizeSubcategoryName(
          originalSubcategory,
        );

        // Jika sudah ada, pertahankan yang asli dengan jumlah tertinggi
        if (subcategoryCount.containsKey(normalizedSubcategory)) {
          subcategoryCount[normalizedSubcategory] =
              subcategoryCount[normalizedSubcategory]! + 1;
        } else {
          subcategoryCount[normalizedSubcategory] = 1;
          subcategories.add(originalSubcategory);
        }
      }
    }

    // Print subcategory counts for debugging
    subcategoryCount.forEach((key, value) {
      print('Subcategory: $key, Count: $value');
    });

    return ['Semua', ...subcategories.toList()..sort()];
  }

  // Helper method untuk normalisasi nama subcategory
  String _normalizeSubcategoryName(String subcategory) {
    return subcategory.toLowerCase().trim();
  }

  // Filter answers based on selected subcategory
  void _updateFilteredAnswers(List<Map<String, dynamic>> answers) {
    if (_selectedSubcategory == null || _selectedSubcategory == 'Semua') {
      _filteredAnswers = answers;
    } else {
      print('Filtering for subcategory: $_selectedSubcategory');

      // Normalized case-insensitive filtering with variation handling
      String normalizedTarget = _selectedSubcategory!.toLowerCase().trim();

      // Get all possible variations for the selected subcategory
      List<String> possibleVariations = [];

      // Cari key yang sesuai dengan target subcategory
      for (var key in _subcategoryVariations.keys) {
        if (normalizedTarget.contains(key) || key.contains(normalizedTarget)) {
          possibleVariations.addAll(_subcategoryVariations[key]!);
          break;
        }
      }

      // Jika tidak ada variasi yang ditemukan, gunakan subcategory asli
      if (possibleVariations.isEmpty) {
        possibleVariations = [normalizedTarget];
      }

      print('Looking for these variations: $possibleVariations');

      // Debug: print all subcategories for inspection
      print('All available subcategories in answers:');
      final uniqueSubcats =
          answers
              .map((a) => a['subcategory']?.toString())
              .where((s) => s != null && s.isNotEmpty)
              .toSet()
              .toList();
      print(uniqueSubcats);

      // Filter dengan memeriksa semua kemungkinan variasi
      _filteredAnswers =
          answers.where((answer) {
            if (answer['subcategory'] == null) return false;

            String answerSubcategory =
                answer['subcategory'].toString().toLowerCase().trim();

            // Periksa kecocokan dengan semua variasi yang mungkin
            for (var variation in possibleVariations) {
              if (answerSubcategory == variation ||
                  answerSubcategory.contains(variation) ||
                  variation.contains(answerSubcategory)) {
                return true;
              }
            }

            return false;
          }).toList();

      // Sort by order if present
      _filteredAnswers.sort((a, b) {
        final orderA = a['order'] as num? ?? 0;
        final orderB = b['order'] as num? ?? 0;
        return orderA.compareTo(orderB);
      });

      print(
        'Found ${_filteredAnswers.length} answers after filtering for $_selectedSubcategory',
      );

      // Debug: print questions found for "Akurat"
      if (normalizedTarget == 'akurat') {
        print('Questions matching "Akurat":');
        for (var answer in _filteredAnswers) {
          print(
            '- ${answer['question']} (subcategory: ${answer['subcategory']})',
          );
        }
      }
    }
  }

  // Handle subcategory filter change
  void _onSubcategoryChanged(String? subcategory) {
    setState(() {
      _selectedSubcategory = subcategory;
      _updateFilteredAnswers(_answers);

      // Debug: when filtering for "Akurat", let's print more details
      if (subcategory?.toLowerCase() == 'akurat') {
        print('=== DEBUG FOR AKURAT FILTER ===');
        print('Selected subcategory: $subcategory');
        print('Total answers before filter: ${_answers.length}');
        print('Total answers after filter: ${_filteredAnswers.length}');

        // Check for similar subcategories
        final possibleMatches =
            _answers
                .where(
                  (a) =>
                      a['subcategory'] != null &&
                      (a['subcategory'].toString().toLowerCase().contains(
                            'akur',
                          ) ||
                          a['subcategory'].toString().toLowerCase().contains(
                            'accur',
                          )),
                )
                .map((a) => '${a['subcategory']} (${a['question']})')
                .toSet()
                .toList();

        print('Possible similar subcategories: $possibleMatches');
        print('==============================');
      }
    });
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Tanggal tidak tersedia';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        // Try to parse the string as a date
        date = DateTime.parse(timestamp);
      } else {
        // Try to use toDate() method if available
        try {
          date = timestamp.toDate();
        } catch (e) {
          print('Error converting timestamp to date: $e');
          return 'Tanggal: ${timestamp.toString()}';
        }
      }

      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Tanggal survey: ${timestamp.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statistics =
        widget.surveyData['statistics'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Detail Survey',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSize.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(statistics),
            SizedBox(height: AppSize.heightPercent(2)),
            _buildAnswersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> statistics) {
    // Start with overall statistics
    num score = statistics['score'] ?? 0;
    Color scoreColor = _getScoreColor(score);

    // If we have category statistics for the selected category, use those instead
    if (widget.selectedCategory != null &&
        widget.surveyData['categoryStatistics'] != null) {
      final categoryStats =
          (widget.surveyData['categoryStatistics']
              as Map<String, dynamic>?)?[widget.selectedCategory];
      if (categoryStats != null) {
        final categoryScore = (categoryStats as Map<String, dynamic>)['score'];
        if (categoryScore != null) {
          score = categoryScore;
          scoreColor = _getScoreColor(score);
        }
      }
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Colors.blue.shade700,
                  size: AppSize.iconSize,
                ),
                SizedBox(width: AppSize.widthPercent(2)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.surveyData['selectedBank'] ??
                            'Bank tidak diketahui',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.selectedCategory ??
                            (widget.surveyData['categories'] != null &&
                                    (widget.surveyData['categories'] as List)
                                        .isNotEmpty
                                ? (widget.surveyData['categories'] as List)
                                    .first
                                    .toString()
                                : 'Kategori tidak diketahui'),
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildContributorsText(),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSize.heightPercent(1)),

            // Date display
            Text(
              _formatDate(
                widget.surveyData['selectedDate'] ??
                    widget.surveyData['submittedAt'] ??
                    widget.surveyData['createdAt'],
              ),
              style: AppSize.getTextStyle(
                fontSize: AppSize.smallFontSize,
                color: Colors.grey.shade600,
              ),
            ),

            // Contributors are already shown above
            SizedBox(height: AppSize.heightPercent(0.5)),

            SizedBox(height: AppSize.heightPercent(2)),

            // Score Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSize.paddingHorizontal),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scoreColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment,
                        color: scoreColor,
                        size: AppSize.iconSize,
                      ),
                      SizedBox(width: AppSize.widthPercent(2)),
                      Text(
                        'Skor Survey',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.heightPercent(1)),
                  Text(
                    '${score.toInt()}%',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.titleFontSize * 1.5,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSize.heightPercent(2)),

            // Statistics Grid
            Row(
              children: [
                // Total question stat removed as requested
                Expanded(
                  child: _buildStatCard(
                    'Dijawab',
                    (statistics['answeredQuestions'] ?? 0).toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: AppSize.widthPercent(2)),
                Expanded(
                  child: _buildStatCard(
                    'Dilewati',
                    (statistics['skippedQuestions'] ?? 0).toString(),
                    Icons.skip_next,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSize.iconSize * 0.9),
          SizedBox(height: AppSize.heightPercent(0.5)),
          Text(
            value,
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Display contributors of the survey
  Widget _buildContributorsText() {
    // We will get the actual contributor from the database
    // No more hardcoded values

    // First try to get category-specific contributor
    if (widget.selectedCategory != null &&
        widget.surveyData['categoryStatistics'] != null) {
      final categoryStats =
          widget.surveyData['categoryStatistics'] as Map<String, dynamic>?;

      // Try exact match first
      if (categoryStats != null &&
          categoryStats[widget.selectedCategory] != null) {
        final categoryData =
            categoryStats[widget.selectedCategory] as Map<String, dynamic>;

        // Check if this category has a specific contributor
        if (categoryData['contributor'] != null) {
          final contributor =
              categoryData['contributor'] as Map<String, dynamic>;

          print(
            'Found exact match for category contributor: ${contributor['userName']} for ${widget.selectedCategory}',
          );

          return Text(
            'Surveyor: ${contributor['userName'] ?? 'Unknown'}',
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize,
              color: Colors.grey.shade600,
            ),
          );
        }
      }

      // Try case insensitive match if exact match failed
      if (categoryStats != null) {
        final matchingCategoryKey = categoryStats.keys.firstWhere(
          (key) =>
              key.toString().toLowerCase() ==
              widget.selectedCategory!.toLowerCase(),
          orElse: () => '',
        );

        if (matchingCategoryKey.isNotEmpty) {
          final categoryData =
              categoryStats[matchingCategoryKey] as Map<String, dynamic>;
          if (categoryData['contributor'] != null) {
            final contributor =
                categoryData['contributor'] as Map<String, dynamic>;

            print(
              'Found case-insensitive match for category contributor: ${contributor['userName']} for ${widget.selectedCategory}',
            );

            return Text(
              'Surveyor: ${contributor['userName'] ?? 'Unknown'}',
              style: AppSize.getTextStyle(
                fontSize: AppSize.smallFontSize,
                color: Colors.grey.shade600,
              ),
            );
          }
        }

        // If still no match, try to find matching category names with substring
        for (final catKey in categoryStats.keys) {
          if (catKey.toString().toLowerCase().contains(
                widget.selectedCategory!.toLowerCase(),
              ) ||
              widget.selectedCategory!.toLowerCase().contains(
                catKey.toString().toLowerCase(),
              )) {
            final categoryData = categoryStats[catKey] as Map<String, dynamic>?;
            if (categoryData != null && categoryData['contributor'] != null) {
              final contributor =
                  categoryData['contributor'] as Map<String, dynamic>;

              print(
                'Found substring match for category contributor: ${contributor['userName']} from $catKey for ${widget.selectedCategory}',
              );

              return Text(
                'Surveyor: ${contributor['userName'] ?? 'Unknown'}',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  color: Colors.grey.shade600,
                ),
              );
            }
          }
        }
      }
    }

    // Fall back to general contributors if no category-specific one is found
    List<Map<String, dynamic>> contributors = [];
    if (widget.surveyData['contributors'] != null) {
      try {
        contributors = List<Map<String, dynamic>>.from(
          widget.surveyData['contributors'],
        );
      } catch (e) {
        print('Error parsing contributors: $e');
      }
    }

    // If no contributors field exists, use the old userName field
    if (contributors.isEmpty && widget.surveyData['userName'] != null) {
      return Text(
        'Surveyor: ${widget.surveyData['userName']}',
        style: AppSize.getTextStyle(
          fontSize: AppSize.smallFontSize,
          color: Colors.grey.shade600,
        ),
      );
    }

    // If we're showing a specific category but couldn't find a specific contributor,
    // just show the most recent contributor (assuming they probably did this category)
    if (widget.selectedCategory != null && contributors.isNotEmpty) {
      // Sort by timestamp if available
      contributors.sort((a, b) {
        if (a['timestamp'] == null || b['timestamp'] == null) return 0;
        return (b['timestamp'] as Timestamp).compareTo(
          a['timestamp'] as Timestamp,
        );
      });

      return Text(
        'Surveyor: ${contributors.first['userName'] ?? 'Unknown'}',
        style: AppSize.getTextStyle(
          fontSize: AppSize.smallFontSize,
          color: Colors.grey.shade600,
        ),
      );
    }

    // If multiple contributors for general survey view, show count and list them
    if (contributors.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Surveyors: ${contributors.length} people',
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            contributors.map((c) => c['userName']).join(', '),
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else if (contributors.length == 1) {
      // If only one contributor, show their name
      return Text(
        'Surveyor: ${contributors[0]['userName'] ?? 'Unknown'}',
        style: AppSize.getTextStyle(
          fontSize: AppSize.smallFontSize,
          color: Colors.grey.shade600,
        ),
      );
    } else {
      // No contributor info available
      return SizedBox.shrink();
    }
  }

  Widget _buildAnswersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Jawaban',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (_subcategories.length > 1)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 10, bottom: 5),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Filter Subcategory:',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.smallFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedSubcategory ?? 'Semua',
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blue.shade700,
                          ),
                          items:
                              _subcategories.map((String subcategory) {
                                // Hitung jumlah pertanyaan untuk subcategory ini
                                int count = _countQuestionsForSubcategory(
                                  subcategory,
                                );
                                bool isAkurat =
                                    subcategory != 'Semua' &&
                                    _isAkuratSubcategory(subcategory);

                                return DropdownMenuItem<String>(
                                  value: subcategory,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          if (isAkurat)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: Icon(
                                                Icons.check_circle_outline,
                                                size: 16,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          Text(
                                            subcategory,
                                            style: AppSize.getTextStyle(
                                              fontSize: AppSize.bodyFontSize,
                                              color:
                                                  subcategory ==
                                                          _selectedSubcategory
                                                      ? Colors.blue.shade700
                                                      : (isAkurat
                                                          ? Colors
                                                              .green
                                                              .shade700
                                                          : Colors.black87),
                                              fontWeight:
                                                  subcategory ==
                                                              _selectedSubcategory ||
                                                          isAkurat
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              subcategory ==
                                                      _selectedSubcategory
                                                  ? Colors.blue.shade100
                                                  : (isAkurat
                                                      ? Colors.green.shade100
                                                      : Colors.grey.shade200),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          count.toString(),
                                          style: AppSize.getTextStyle(
                                            fontSize: AppSize.smallFontSize - 1,
                                            color:
                                                subcategory ==
                                                        _selectedSubcategory
                                                    ? Colors.blue.shade700
                                                    : (isAkurat
                                                        ? Colors.green.shade700
                                                        : Colors.grey.shade700),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: _onSubcategoryChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: AppSize.heightPercent(1.5)),

        if (_isLoading)
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: AppSize.heightPercent(1)),
                Text(
                  'Memuat detail jawaban...',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else if (_error != null)
          Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: AppSize.heightPercent(1)),
                Text(
                  'Terjadi kesalahan saat memuat detail jawaban',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSize.heightPercent(0.5)),
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSize.paddingHorizontal,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!.contains('index')
                        ? 'Diperlukan pengaturan tambahan di Firebase. Silakan hubungi administrator sistem.'
                        : _error!,
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.smallFontSize,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: AppSize.heightPercent(2)),
                ElevatedButton.icon(
                  onPressed: _loadAnswers,
                  icon: Icon(Icons.refresh),
                  label: Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.paddingHorizontal,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_answers.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: AppSize.heightPercent(1)),
                Text(
                  widget.selectedCategory != null
                      ? 'Tidak ada jawaban untuk kategori "${widget.selectedCategory}"'
                      : 'Tidak ada jawaban ditemukan',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSize.heightPercent(1)),
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSize.paddingHorizontal,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Kemungkinan penyebab:',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.selectedCategory != null
                            ? '• Kategori "${widget.selectedCategory}" mungkin memiliki nama yang berbeda di sistem\n'
                                '• Data untuk kategori ini belum disimpan\n'
                                '• Adanya ketidakcocokan dalam penulisan nama kategori'
                            : '• Survey belum memiliki data jawaban\n'
                                '• Data mungkin belum disimpan dengan benar',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.smallFontSize,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSize.heightPercent(2)),
                ElevatedButton.icon(
                  onPressed: _loadAnswers,
                  icon: Icon(Icons.refresh),
                  label: Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.paddingHorizontal,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_filteredAnswers.isEmpty &&
            _selectedSubcategory != null &&
            _selectedSubcategory != 'Semua')
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.filter_alt_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: AppSize.heightPercent(1)),
                Text(
                  'Tidak ada jawaban untuk subkategori "$_selectedSubcategory"',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSize.heightPercent(1.5)),
                ElevatedButton.icon(
                  onPressed: () => _onSubcategoryChanged('Semua'),
                  icon: Icon(Icons.filter_list_off),
                  label: Text('Tampilkan Semua'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child:
                    _selectedSubcategory != null &&
                            _selectedSubcategory != 'Semua'
                        ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.filter_alt,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Filter: $_selectedSubcategory',
                                      style: AppSize.getTextStyle(
                                        fontSize: AppSize.smallFontSize,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _onSubcategoryChanged('Semua'),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.blue.shade700,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Reset Filter',
                                            style: AppSize.getTextStyle(
                                              fontSize:
                                                  AppSize.smallFontSize - 1,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    'Menampilkan ${_filteredAnswers.length} jawaban',
                                    style: AppSize.getTextStyle(
                                      fontSize: AppSize.smallFontSize - 1,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : (_subcategories.length >
                            2) // More than just "Semua" and one other option
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Menampilkan semua ${_filteredAnswers.length} jawaban. Gunakan filter untuk melihat berdasarkan subcategory.',
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.smallFontSize,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : SizedBox(), // No info needed if there aren't multiple subcategories
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _filteredAnswers.length,
                itemBuilder: (context, index) {
                  final answer = _filteredAnswers[index];
                  return _buildAnswerCard(answer, index + 1);
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAnswerCard(Map<String, dynamic> answer, int questionNumber) {
    final isAnswered = answer['answerValue'] != null;
    final isSkipped = answer['skipped'] == true;
    final answerValue = answer['answerValue'] as bool?;

    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = Colors.white;
    IconData? statusIcon;
    Color? statusColor;
    String statusText = 'Tidak Dijawab';

    if (isSkipped) {
      borderColor = Colors.orange;
      backgroundColor = Colors.orange.withOpacity(0.05);
      statusIcon = Icons.skip_next;
      statusColor = Colors.orange;
      statusText = 'Dilewati';
    } else if (isAnswered) {
      if (answerValue == true) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.05);
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Ya';
      } else {
        borderColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.05);
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusText = 'Tidak';
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: AppSize.heightPercent(1)),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(AppSize.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nomor dan status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: statusColor ?? Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      questionNumber.toString(),
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.widthPercent(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer['question'] ?? 'Pertanyaan tidak tersedia',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: AppSize.heightPercent(0.5)),
                      if (answer['category'] != null ||
                          answer['subcategory'] != null)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (answer['category'] != null)
                              Text(
                                answer['category'].toString(),
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (answer['category'] != null &&
                                answer['subcategory'] != null)
                              Text(
                                ' • ',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (answer['subcategory'] != null)
                              GestureDetector(
                                onTap: () {
                                  final subcategory =
                                      answer['subcategory'].toString();
                                  // If already selected, clear filter. Otherwise, apply filter
                                  _onSubcategoryChanged(
                                    _selectedSubcategory == subcategory
                                        ? 'Semua'
                                        : subcategory,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  margin: EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        _isAkuratSubcategory(
                                              answer['subcategory'],
                                            )
                                            ? Colors.green.shade50
                                            : (_selectedSubcategory ==
                                                    answer['subcategory']
                                                ? Colors.blue.shade50
                                                : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _isAkuratSubcategory(
                                                answer['subcategory'],
                                              )
                                              ? Colors.green.shade400
                                              : (_selectedSubcategory ==
                                                      answer['subcategory']
                                                  ? Colors.blue.shade300
                                                  : Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isAkuratSubcategory(
                                        answer['subcategory'],
                                      ))
                                        Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Icon(
                                            Icons.check_circle_outline,
                                            size: 12,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      Text(
                                        answer['subcategory'].toString(),
                                        style: AppSize.getTextStyle(
                                          fontSize: AppSize.smallFontSize - 1,
                                          fontWeight:
                                              _selectedSubcategory ==
                                                          answer['subcategory'] ||
                                                      _isAkuratSubcategory(
                                                        answer['subcategory'],
                                                      )
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              _isAkuratSubcategory(
                                                    answer['subcategory'],
                                                  )
                                                  ? Colors.green.shade700
                                                  : (_selectedSubcategory ==
                                                          answer['subcategory']
                                                      ? Colors.blue.shade700
                                                      : Colors.grey.shade700),
                                        ),
                                      ),
                                      if (_selectedSubcategory ==
                                              answer['subcategory'] &&
                                          !_isAkuratSubcategory(
                                            answer['subcategory'],
                                          ))
                                        Padding(
                                          padding: EdgeInsets.only(left: 3),
                                          child: Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (statusIcon != null)
                  Icon(statusIcon, color: statusColor, size: AppSize.iconSize),
              ],
            ),

            SizedBox(height: AppSize.heightPercent(1)),

            // Status jawaban
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (statusColor ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor ?? Colors.grey, width: 1),
              ),
              child: Text(
                statusText,
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  color: statusColor ?? Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Catatan jika ada
            if (answer['note'] != null &&
                answer['note'].toString().isNotEmpty) ...[
              SizedBox(height: AppSize.heightPercent(1)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan:',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      answer['note'].toString(),
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method untuk mengecek apakah subcategory termasuk "Akurat"
  bool _isAkuratSubcategory(dynamic subcategory) {
    if (subcategory == null) return false;

    String normalized = subcategory.toString().toLowerCase().trim();

    // Cek apakah subcategory termasuk variasi "Akurat"
    List<String> akuratVariations = _subcategoryVariations['akurat'] ?? [];

    return akuratVariations.any(
      (variation) =>
          normalized == variation ||
          normalized.contains(variation) ||
          variation.contains(normalized),
    );
  }

  Color _getScoreColor(dynamic score) {
    if (score == null) return Colors.grey;
    final scoreValue = (score as num).toDouble();
    if (scoreValue >= 80) return Colors.green;
    if (scoreValue >= 60) return Colors.orange;
    return Colors.red;
  }

  // Menghitung jumlah pertanyaan untuk subcategory tertentu
  int _countQuestionsForSubcategory(String subcategory) {
    if (subcategory == 'Semua') return _answers.length;

    String normalized = subcategory.toLowerCase().trim();

    // Cek apakah subcategory termasuk variasi yang diketahui
    for (var key in _subcategoryVariations.keys) {
      List<String> variations = _subcategoryVariations[key] ?? [];
      if (variations.any(
        (v) =>
            normalized == v || normalized.contains(v) || v.contains(normalized),
      )) {
        // Hitung pertanyaan yang cocok dengan semua variasi ini
        return _answers.where((answer) {
          if (answer['subcategory'] == null) return false;
          String answerSub =
              answer['subcategory'].toString().toLowerCase().trim();
          return variations.any(
            (v) =>
                answerSub == v ||
                answerSub.contains(v) ||
                v.contains(answerSub),
          );
        }).length;
      }
    }

    // Fallback ke pencocokan langsung
    return _answers
        .where(
          (answer) =>
              answer['subcategory'] != null &&
              answer['subcategory'].toString().toLowerCase().trim() ==
                  normalized,
        )
        .length;
  }
}
