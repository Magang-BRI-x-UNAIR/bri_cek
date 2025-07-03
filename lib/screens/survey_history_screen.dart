import 'package:flutter/material.dart';
import 'package:bri_cek/services/survey_result_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bri_cek/screens/survey_detail_from_bank_screen.dart';

class SurveyHistoryScreen extends StatefulWidget {
  const SurveyHistoryScreen({super.key});

  @override
  State<SurveyHistoryScreen> createState() => _SurveyHistoryScreenState();
}

class _SurveyHistoryScreenState extends State<SurveyHistoryScreen> {
  final SurveyResultService _surveyResultService = SurveyResultService();
  List<Map<String, dynamic>> _surveyResults = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurveyResults();
  }

  Future<void> _loadSurveyResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await _surveyResultService.getUserSurveyResults(
        userId: null, // Fetch all survey results, not just current user's
      );

      // The results already come back grouped by date/bank from the service
      // due to the changes in the survey ID format, but we'll ensure it here too
      final Map<String, Map<String, dynamic>> uniqueSurveys = {};

      for (var survey in results) {
        final bank = survey['selectedBank'] as String?;
        final dateValue = survey['selectedDate'];

        if (bank != null && dateValue != null) {
          final date =
              dateValue is DateTime
                  ? dateValue
                  : (dateValue.toDate != null
                      ? dateValue.toDate()
                      : DateTime.now());
          final key = '${bank}_${date.toIso8601String().split('T')[0]}';
          // If we already have this survey, skip it
          if (!uniqueSurveys.containsKey(key)) {
            uniqueSurveys[key] = survey;
          }
        }
      }

      setState(() {
        _surveyResults = uniqueSurveys.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading survey results: $e');
      setState(() {
        _error = 'Failed to load survey results: $e';
        _isLoading = false;
      });
    }
  }

  // Format the date from a Timestamp
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Date not available';

    try {
      final date =
          timestamp is Timestamp
              ? timestamp.toDate()
              : (timestamp is DateTime ? timestamp : DateTime.now());

      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurveyResults,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadSurveyResults,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_surveyResults.isEmpty) {
      return const Center(child: Text('No survey history available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Survey History',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // View all surveys screen
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _surveyResults.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final survey = _surveyResults[index];
              final categories = List<String>.from(survey['categories'] ?? []);
              final stats = survey['statistics'] as Map<String, dynamic>? ?? {};

              // Get the contributors list
              List<Map<String, dynamic>> contributors = [];
              if (survey['contributors'] != null) {
                contributors = List<Map<String, dynamic>>.from(
                  survey['contributors'],
                );
              }

              // If no contributors field, fall back to the userName field
              String surveyor = '';
              if (contributors.isNotEmpty) {
                // Get the first contributor for display
                surveyor = contributors[0]['userName'] ?? 'Unknown';
              } else {
                surveyor = survey['userName'] ?? 'Unknown';
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SurveyDetailFromBankScreen(
                            surveyId: survey['id'],
                            surveyData: survey,
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(survey['selectedDate']),
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${categories.length} kategori',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.smallFontSize,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                contributors.length > 1
                                    ? 'Surveyors: ${contributors.length} people'
                                    : 'Surveyor: $surveyor',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.shade400),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${categories.length} Categories Done',
                                  style: AppSize.getTextStyle(
                                    fontSize: AppSize.smallFontSize,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (categories.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              categories.map((category) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: AppSize.getTextStyle(
                                      fontSize: AppSize.smallFontSize,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Total Questions: ${stats['totalQuestions'] ?? 0}',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Answered: ${stats['answeredQuestions'] ?? 0} | Skipped: ${stats['skippedQuestions'] ?? 0}',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.smallFontSize,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SurveyDetailFromBankScreen(
                                        surveyId: survey['id'],
                                        surveyData: survey,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility, size: 16),
                            label: const Text('Details'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
