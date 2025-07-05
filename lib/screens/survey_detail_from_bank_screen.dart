import 'package:flutter/material.dart';
import 'package:bri_cek/services/survey_result_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyDetailFromBankScreen extends StatefulWidget {
  final String surveyId;
  final Map<String, dynamic> surveyData;
  final String? selectedCategory;
  final bool isEditMode;

  const SurveyDetailFromBankScreen({
    Key? key,
    required this.surveyId,
    required this.surveyData,
    this.selectedCategory,
    this.isEditMode = false,
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
  List<String> _categories = [];
  List<String> _subcategories = [];
  String? _selectedCategory;
  String? _selectedSubcategory;
  bool _isLoading = true;
  String? _error;

  // Variables for edit mode
  bool _isEditMode = false;
  bool _isSaving = false;
  Map<String, dynamic> _editedAnswers = {};
  Map<String, String> _editedNotes = {};
  Map<String, bool> _editedSkipped = {}; // Track skipped questions

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditMode;

    // Initialize filter values
    _selectedCategory = 'Semua';
    _selectedSubcategory = 'Semua';

    // Debug print survey data
    print('Survey ID: ${widget.surveyId}');
    print('Selected Category: ${widget.selectedCategory}');
    print('Is Edit Mode: $_isEditMode');
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

      // Extract unique categories and subcategories for filtering
      _categories = _extractCategories(answers);
      _subcategories = _extractSubcategories(answers);
      print('Found categories: $_categories');
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

  // Extract subcategories for a specific category
  List<String> _extractSubcategoriesForCategory(
    List<Map<String, dynamic>> answers,
  ) {
    final subcategories = <String>{};

    for (var answer in answers) {
      if (answer['subcategory'] != null &&
          answer['subcategory'].toString().isNotEmpty) {
        subcategories.add(answer['subcategory'].toString());
      }
    }

    return ['Semua', ...subcategories.toList()..sort()];
  }

  // Filter answers based on selected category and subcategory
  void _updateFilteredAnswers(List<Map<String, dynamic>> answers) {
    List<Map<String, dynamic>> filtered = answers;

    // First filter by category if selected (for "all categories" view)
    if (widget.selectedCategory == null &&
        _selectedCategory != null &&
        _selectedCategory != 'Semua') {
      filtered =
          filtered.where((answer) {
            return answer['category'] != null &&
                answer['category'].toString().toLowerCase() ==
                    _selectedCategory!.toLowerCase();
          }).toList();

      // Update subcategories based on selected category
      _subcategories = _extractSubcategoriesForCategory(filtered);

      // Reset subcategory selection if it's not available in new category
      if (_selectedSubcategory != null &&
          _selectedSubcategory != 'Semua' &&
          !_subcategories.contains(_selectedSubcategory)) {
        _selectedSubcategory = 'Semua';
      }
    }

    // Then filter by subcategory if selected
    if (_selectedSubcategory != null && _selectedSubcategory != 'Semua') {
      filtered =
          filtered.where((answer) {
            return answer['subcategory'] != null &&
                answer['subcategory'].toString().toLowerCase() ==
                    _selectedSubcategory!.toLowerCase();
          }).toList();
    }

    // Sort by order if present
    filtered.sort((a, b) {
      final orderA = a['order'] as num? ?? 0;
      final orderB = b['order'] as num? ?? 0;
      return orderA.compareTo(orderB);
    });

    _filteredAnswers = filtered;

    print(
      'Applied filters - Category: $_selectedCategory, Subcategory: $_selectedSubcategory',
    );
    print(
      'Filtered results: ${_filteredAnswers.length} out of ${answers.length} answers',
    );
  }

  // Handle category filter change
  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = 'Semua'; // Reset subcategory when category changes
      _updateFilteredAnswers(_answers);
    });
  }

  // Handle subcategory filter change
  void _onSubcategoryChanged(String? subcategory) {
    setState(() {
      _selectedSubcategory = subcategory;
      _updateFilteredAnswers(_answers);
    });
  }

  // Handle subcategory filter change
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
          _isEditMode ? 'Edit Survey' : 'Detail Survey',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            _isEditMode ? Colors.orange.shade700 : Colors.blue.shade700,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_isEditMode) ...[
            // Save button in edit mode
            if (_isSaving)
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            else
              IconButton(
                onPressed: _saveEdit,
                icon: Icon(Icons.save),
                tooltip: 'Simpan Perubahan',
              ),
            IconButton(
              onPressed: _cancelEdit,
              icon: Icon(Icons.close),
              tooltip: 'Batal Edit',
            ),
          ] else ...[
            // Edit button in view mode
            IconButton(
              onPressed: _enterEditMode,
              icon: Icon(Icons.edit),
              tooltip: 'Edit Survey',
            ),
          ],
        ],
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
    return FutureBuilder<String?>(
      future: _getLastEditorFullName(),
      builder: (context, snapshot) {
        String? lastEditedBy;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          lastEditedBy = snapshot.data;
        } else {
          // Fallback to current logic while loading
          final lastEditedData = widget.surveyData['lastEditedBy'];
          if (lastEditedData is String) {
            lastEditedBy = lastEditedData;
            if (lastEditedBy.contains('@')) {
              lastEditedBy = lastEditedBy.split('@').first;
            }
          } else if (lastEditedData is Map<String, dynamic>) {
            lastEditedBy = lastEditedData['userName'] as String?;
            if (lastEditedBy != null && lastEditedBy.contains('@')) {
              lastEditedBy = lastEditedBy.split('@').first;
            }
          }
        }

        return _buildContributorsTextContent(lastEditedBy);
      },
    );
  }

  // Get full name for last editor
  Future<String?> _getLastEditorFullName() async {
    try {
      final lastEditedData = widget.surveyData['lastEditedBy'];
      if (lastEditedData is String) {
        return await _surveyResultService.getFullNameFromUser(lastEditedData);
      } else if (lastEditedData is Map<String, dynamic>) {
        final userName = lastEditedData['userName'] as String?;
        final userId = lastEditedData['userId'] as String?;
        if (userId != null) {
          return await _surveyResultService.getFullNameFromUser(userId);
        } else if (userName != null) {
          return await _surveyResultService.getFullNameFromUser(userName);
        }
      }
      return null;
    } catch (e) {
      print('Error getting last editor full name: $e');
      return null;
    }
  }

  // Build contributors text content
  Widget _buildContributorsTextContent(String? lastEditedBy) {
    // We will get the actual contributor from the database
    // No more hardcoded values

    // First try to get category-specific contributor
    String? surveyorName;
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

          surveyorName = contributor['userName'] ?? 'Unknown';
        }
      }

      // Try case insensitive match if exact match failed
      if (surveyorName == null && categoryStats != null) {
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

            surveyorName = contributor['userName'] ?? 'Unknown';
          }
        }

        // If still no match, try to find matching category names with substring
        if (surveyorName == null) {
          for (final catKey in categoryStats.keys) {
            if (catKey.toString().toLowerCase().contains(
                  widget.selectedCategory!.toLowerCase(),
                ) ||
                widget.selectedCategory!.toLowerCase().contains(
                  catKey.toString().toLowerCase(),
                )) {
              final categoryData =
                  categoryStats[catKey] as Map<String, dynamic>?;
              if (categoryData != null && categoryData['contributor'] != null) {
                final contributor =
                    categoryData['contributor'] as Map<String, dynamic>;

                print(
                  'Found substring match for category contributor: ${contributor['userName']} from $catKey for ${widget.selectedCategory}',
                );

                surveyorName = contributor['userName'] ?? 'Unknown';
                break;
              }
            }
          }
        }
      }
    }

    // Fall back to general contributors if no category-specific one is found
    if (surveyorName == null) {
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
        surveyorName = widget.surveyData['userName'];
      } else if (widget.selectedCategory != null && contributors.isNotEmpty) {
        // If we're showing a specific category but couldn't find a specific contributor,
        // just show the most recent contributor (assuming they probably did this category)
        // Sort by timestamp if available
        contributors.sort((a, b) {
          if (a['timestamp'] == null || b['timestamp'] == null) return 0;
          return (b['timestamp'] as Timestamp).compareTo(
            a['timestamp'] as Timestamp,
          );
        });

        surveyorName = contributors.first['userName'] ?? 'Unknown';
      } else if (contributors.length == 1) {
        // If only one contributor, show their name
        surveyorName = contributors[0]['userName'] ?? 'Unknown';
      } else if (contributors.length > 1) {
        // Multiple contributors - we'll handle this case below
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
            // Show last editor if available and different from contributors
            if (lastEditedBy != null &&
                !contributors.any((c) => c['userName'] == lastEditedBy)) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.edit, size: 14, color: Colors.orange.shade700),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Last Editor: $lastEditedBy',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      }
    }

    // Build the result widget for single surveyor case
    if (surveyorName != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Surveyor: $surveyorName',
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize,
              color: Colors.grey.shade600,
            ),
          ),
          // Show last editor if available and different from surveyor
          if (lastEditedBy != null && lastEditedBy != surveyorName) ...[
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.edit, size: 14, color: Colors.orange.shade700),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Last Editor: $lastEditedBy',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.smallFontSize,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    } else {
      // No contributor info available - just show last editor if available
      if (lastEditedBy != null) {
        return Row(
          children: [
            Icon(Icons.edit, size: 14, color: Colors.orange.shade700),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'Last Editor: $lastEditedBy',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    }
  }

  // Extract all unique categories from answers
  List<String> _extractCategories(List<Map<String, dynamic>> answers) {
    final categories = <String>{};

    for (var answer in answers) {
      if (answer['category'] != null &&
          answer['category'].toString().isNotEmpty) {
        categories.add(answer['category'].toString());
      }
    }

    return ['Semua', ...categories.toList()..sort()];
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
            // Add filters only for "all categories" view
            if (widget.selectedCategory == null) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 10, bottom: 5),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                          'Filter Kategori & Subkategori:',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.smallFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Category filter
                    Text(
                      'Kategori:',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade600,
                      ),
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
                          value: _selectedCategory ?? 'Semua',
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blue.shade700,
                          ),
                          items:
                              _categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: AppSize.getTextStyle(
                                      fontSize: AppSize.bodyFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: _onCategoryChanged,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Subcategory filter
                    Text(
                      'Subkategori:',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade600,
                      ),
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
                                return DropdownMenuItem<String>(
                                  value: subcategory,
                                  child: Text(
                                    subcategory,
                                    style: AppSize.getTextStyle(
                                      fontSize: AppSize.bodyFontSize,
                                      color: Colors.black87,
                                    ),
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
                          child: Row(
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
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : SizedBox(),
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
    final String questionId = answer['id'] ?? '';

    // Get current answer value (either from edited answers or original)
    // Use 'answer' field as primary, fallback to 'answerValue' for backward compatibility
    final bool? originalAnswer =
        answer['answer'] as bool? ?? answer['answerValue'] as bool?;
    final bool? currentAnswerValue =
        _isEditMode && _editedAnswers.containsKey(questionId)
            ? _editedAnswers[questionId]
            : originalAnswer;

    // Get current note (either from edited notes or original)
    final String currentNote =
        _isEditMode && _editedNotes.containsKey(questionId)
            ? _editedNotes[questionId] ?? ''
            : answer['note']?.toString() ?? '';

    // Check skip status (either from edited skip status or original)
    final bool isSkipped =
        _isEditMode && _editedSkipped.containsKey(questionId)
            ? _editedSkipped[questionId] ?? false
            : (answer['skipped'] == true);

    final isAnswered = currentAnswerValue != null && !isSkipped;

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
      if (currentAnswerValue == true) {
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
                              Text(
                                answer['subcategory'].toString(),
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (statusIcon != null && !_isEditMode)
                  Icon(statusIcon, color: statusColor, size: AppSize.iconSize),
              ],
            ),

            SizedBox(height: AppSize.heightPercent(1)),

            // Edit mode answer buttons or view mode status
            if (_isEditMode) ...[
              _buildEditAnswerButtons(questionId, currentAnswerValue),
              SizedBox(height: AppSize.heightPercent(1)),
              _buildEditNoteField(questionId, currentNote),
            ] else ...[
              // Status jawaban
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (statusColor ?? Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor ?? Colors.grey,
                    width: 1,
                  ),
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
              if (currentNote.isNotEmpty) ...[
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
                        currentNote,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEditAnswerButtons(String questionId, bool? currentAnswer) {
    // Check if current question is skipped
    final bool isSkipped =
        _editedSkipped[questionId] == true ||
        (currentAnswer == null &&
            _editedSkipped.containsKey(questionId) == false &&
            _answers.firstWhere(
                  (answer) => answer['id'] == questionId,
                  orElse: () => {},
                )['skipped'] ==
                true);

    return Row(
      children: [
        // Ya button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _updateAnswer(questionId, true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      currentAnswer == true
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                  border: Border.all(
                    color:
                        currentAnswer == true
                            ? Colors.green
                            : Colors.grey.shade300,
                    width: currentAnswer == true ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color:
                          currentAnswer == true
                              ? Colors.green
                              : Colors.grey.shade600,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Ya',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.bodyFontSize * 0.9,
                        fontWeight:
                            currentAnswer == true
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color:
                            currentAnswer == true
                                ? Colors.green
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),

        // Tidak button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _updateAnswer(questionId, false),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      currentAnswer == false
                          ? Colors.red.shade50
                          : Colors.grey.shade50,
                  border: Border.all(
                    color:
                        currentAnswer == false
                            ? Colors.red
                            : Colors.grey.shade300,
                    width: currentAnswer == false ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel,
                      color:
                          currentAnswer == false
                              ? Colors.red
                              : Colors.grey.shade600,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Tidak',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.bodyFontSize * 0.9,
                        fontWeight:
                            currentAnswer == false
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color:
                            currentAnswer == false
                                ? Colors.red
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),

        // Skip button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _updateAnswerToSkip(questionId),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSkipped ? Colors.orange.shade50 : Colors.grey.shade50,
                  border: Border.all(
                    color: isSkipped ? Colors.orange : Colors.grey.shade300,
                    width: isSkipped ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.skip_next,
                      color: isSkipped ? Colors.orange : Colors.grey.shade600,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Skip',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.bodyFontSize * 0.9,
                        fontWeight:
                            isSkipped ? FontWeight.bold : FontWeight.normal,
                        color: isSkipped ? Colors.orange : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditNoteField(String questionId, String currentNote) {
    final TextEditingController noteController = TextEditingController(
      text: currentNote,
    );

    return TextField(
      controller: noteController,
      decoration: InputDecoration(
        labelText: 'Catatan (opsional)',
        hintText: 'Tambahkan catatan untuk jawaban ini...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.all(12),
      ),
      maxLines: 2,
      onChanged: (value) => _updateNote(questionId, value),
      style: AppSize.getTextStyle(fontSize: AppSize.bodyFontSize),
    );
  }

  // Helper method untuk mengecek apakah subcategory termasuk "Akurat"
  Color _getScoreColor(dynamic score) {
    if (score == null) return Colors.grey;
    final scoreValue = (score as num).toDouble();
    if (scoreValue >= 80) return Colors.green;
    if (scoreValue >= 60) return Colors.orange;
    return Colors.red;
  }

  // Edit mode functions
  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      // Initialize edited answers with current answers
      _editedAnswers = {};
      _editedNotes = {};
      _editedSkipped = {};
      for (var answer in _answers) {
        if (answer['id'] != null) {
          // Use 'answer' field as primary, fallback to 'answerValue' for backward compatibility
          final originalAnswer = answer['answer'] ?? answer['answerValue'];
          _editedAnswers[answer['id']] = originalAnswer;

          // Initialize notes
          _editedNotes[answer['id']] = answer['note'] ?? '';

          // Initialize skipped status
          _editedSkipped[answer['id']] = answer['skipped'] ?? false;
        }
      }
    });
  }

  void _updateAnswer(String questionId, dynamic value) {
    setState(() {
      _editedAnswers[questionId] = value;
      _editedSkipped[questionId] = false; // If answering, it's not skipped
    });
  }

  void _updateNote(String questionId, String note) {
    setState(() {
      _editedNotes[questionId] = note;
    });
  }

  void _updateAnswerToSkip(String questionId) {
    setState(() {
      _editedSkipped[questionId] = true;
      _editedAnswers[questionId] = null; // Clear answer when skipping
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _editedAnswers = {};
      _editedNotes = {};
      _editedSkipped = {};
    });
  }

  Future<void> _saveEdit() async {
    try {
      await _surveyResultService.updateSurveyAnswers(
        widget.surveyId,
        _editedAnswers,
        _editedNotes,
        updatedSkipped: _editedSkipped,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Survey berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditMode = false;
          _editedAnswers = {};
          _editedNotes = {};
          _editedSkipped = {};
        });

        // Refresh data
        _loadAnswers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui survey: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
