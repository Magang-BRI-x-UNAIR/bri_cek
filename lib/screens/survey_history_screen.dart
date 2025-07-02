import 'package:flutter/material.dart';
import 'package:bri_cek/services/survey_result_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';

class SurveyHistoryScreen extends StatefulWidget {
  const SurveyHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SurveyHistoryScreen> createState() => _SurveyHistoryScreenState();
}

class _SurveyHistoryScreenState extends State<SurveyHistoryScreen> {
  final SurveyResultService _surveyResultService = SurveyResultService();
  List<Map<String, dynamic>> _surveyResults = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _selectedCategory;

  final List<String> _categories = [
    'Semua',
    'Customer Service',
    'Teller',
    'Satpam',
    'Gallery E-Channel',
    'Ruang Brimen',
    'Toilet',
  ];

  @override
  void initState() {
    super.initState();
    _loadSurveyResults();
    _loadStatistics();
  }

  Future<void> _loadSurveyResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _surveyResultService.getUserSurveyResults(
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
        limit: 50,
      );

      setState(() {
        _surveyResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat history survey: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _surveyResultService.getSurveyStatistics(
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
      );

      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      // Error loading statistics - tidak perlu menampilkan error
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadSurveyResults();
    _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Survey'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Statistics Card
          if (_statistics != null)
            Container(
              margin: EdgeInsets.all(AppSize.paddingM),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(AppSize.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistik Survey',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.subtitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSize.heightPercent(1)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Survey',
                              _statistics!['totalSurveys'].toString(),
                              Icons.assessment,
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: AppSize.paddingS),
                          Expanded(
                            child: _buildStatCard(
                              'Rata-rata Skor',
                              '${_statistics!['averageScore'].toStringAsFixed(1)}%',
                              Icons.grade,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Category Filter
          Container(
            margin: EdgeInsets.symmetric(horizontal: AppSize.paddingM),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filter Kategori',
                border: OutlineInputBorder(),
              ),
              items:
                  _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: _onCategoryChanged,
            ),
          ),

          SizedBox(height: AppSize.paddingM),

          // Survey Results List
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _surveyResults.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: AppSize.iconSize * 2,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: AppSize.heightPercent(2)),
                          Text(
                            'Belum ada history survey',
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.subtitleFontSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadSurveyResults,
                      child: ListView.builder(
                        padding: EdgeInsets.all(AppSize.paddingM),
                        itemCount: _surveyResults.length,
                        itemBuilder: (context, index) {
                          final result = _surveyResults[index];
                          return _buildSurveyCard(result);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSize.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSize.iconSize),
          SizedBox(height: AppSize.heightPercent(0.5)),
          Text(
            value,
            style: AppSize.getTextStyle(
              fontSize: AppSize.subtitleFontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppSize.getTextStyle(
              fontSize: AppSize.captionFontSize,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyCard(Map<String, dynamic> result) {
    final statistics = result['statistics'] as Map<String, dynamic>? ?? {};
    final score = (statistics['score'] as num?)?.toDouble() ?? 0;
    final selectedDate = result['selectedDate']?.toDate() as DateTime?;
    final lastUpdatedAt = result['lastUpdatedAt']?.toDate() as DateTime?;
    final categories = List<String>.from(result['categories'] ?? []);

    return Card(
      margin: EdgeInsets.only(bottom: AppSize.paddingM),
      elevation: 2,
      child: InkWell(
        onTap: () => _showSurveyDetail(result),
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(AppSize.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['selectedCategory'] ?? 'Unknown',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(0.5)),
                        Text(
                          result['selectedBank'] ?? 'Unknown Bank',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.bodyFontSize,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.paddingS,
                      vertical: AppSize.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: score >= 75 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(
                        AppSize.cardBorderRadius,
                      ),
                    ),
                    child: Text(
                      '${score.toInt()}%',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.bodyFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSize.heightPercent(1)),

              // Kategori yang telah dikerjakan
              if (categories.isNotEmpty) ...[
                Wrap(
                  spacing: AppSize.paddingXS,
                  runSpacing: AppSize.paddingXS,
                  children:
                      categories
                          .map(
                            (category) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSize.paddingS,
                                vertical: AppSize.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppSize.cardBorderRadius,
                                ),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                category,
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.captionFontSize,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                SizedBox(height: AppSize.heightPercent(1)),
              ],

              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppSize.iconSize * 0.8,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: AppSize.paddingXS),
                  Text(
                    selectedDate != null
                        ? DateFormat('dd MMM yyyy').format(selectedDate)
                        : 'Unknown Date',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.captionFontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (lastUpdatedAt != null) ...[
                    SizedBox(width: AppSize.paddingS),
                    Text(
                      '(Update: ${DateFormat('HH:mm').format(lastUpdatedAt)})',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.captionFontSize,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  Spacer(),
                  Text(
                    '${statistics['totalQuestions'] ?? 0} pertanyaan',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.captionFontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSurveyDetail(Map<String, dynamic> result) {
    final categories = List<String>.from(result['categories'] ?? []);

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada kategori ditemukan untuk survey ini'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    if (categories.length == 1) {
      // Jika hanya satu kategori, langsung buka detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SurveyDetailScreen(
                surveyResult: result,
                selectedCategory: categories.first,
              ),
        ),
      );
    } else {
      // Jika lebih dari satu kategori, tampilkan dialog pilihan
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pilih Kategori'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Survey ini memiliki ${categories.length} kategori:'),
                SizedBox(height: AppSize.heightPercent(1)),
                ...categories
                    .map(
                      (category) => ListTile(
                        title: Text(category),
                        leading: Icon(Icons.folder),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SurveyDetailScreen(
                                    surveyResult: result,
                                    selectedCategory: category,
                                  ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
                SizedBox(height: AppSize.heightPercent(1)),
                ListTile(
                  title: Text('Lihat Semua Kategori'),
                  leading: Icon(Icons.list_alt),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SurveyDetailScreen(
                              surveyResult: result,
                              selectedCategory:
                                  null, // null berarti tampilkan semua
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }
}

class SurveyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> surveyResult;
  final String? selectedCategory;

  const SurveyDetailScreen({
    Key? key,
    required this.surveyResult,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> {
  final SurveyResultService _surveyResultService = SurveyResultService();
  List<Map<String, dynamic>> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    try {
      List<Map<String, dynamic>> answers;

      if (widget.selectedCategory != null) {
        // Load jawaban untuk kategori tertentu
        answers = await _surveyResultService.getSurveyAnswersByCategory(
          widget.surveyResult['id'],
          widget.selectedCategory!,
        );
      } else {
        // Load semua jawaban
        answers = await _surveyResultService.getSurveyAnswers(
          widget.surveyResult['id'],
        );
      }

      setState(() {
        _answers = answers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail jawaban: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statistics =
        widget.surveyResult['statistics'] as Map<String, dynamic>? ?? {};
    final categoryStatistics =
        widget.surveyResult['categoryStatistics'] as Map<String, dynamic>? ??
        {};
    final categories = List<String>.from(
      widget.surveyResult['categories'] ?? [],
    );
    final selectedDate =
        widget.surveyResult['selectedDate']?.toDate() as DateTime?;

    // Gunakan statistik kategori yang dipilih atau statistik keseluruhan
    final displayStats =
        widget.selectedCategory != null &&
                categoryStatistics.containsKey(widget.selectedCategory)
            ? categoryStatistics[widget.selectedCategory!]
                as Map<String, dynamic>
            : statistics;
    final score = (displayStats['score'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedCategory != null
              ? 'Detail Survey - ${widget.selectedCategory}'
              : 'Detail Survey - Semua Kategori',
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: EdgeInsets.all(AppSize.paddingM),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(AppSize.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.selectedCategory != null
                                    ? widget.selectedCategory!
                                    : 'Semua Kategori (${categories.length} kategori)',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.titleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppSize.heightPercent(0.5)),
                              Text(
                                widget.surveyResult['selectedBank'] ??
                                    'Unknown Bank',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.subtitleFontSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (selectedDate != null) ...[
                                SizedBox(height: AppSize.heightPercent(0.5)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: AppSize.iconSize * 0.8,
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(width: AppSize.paddingXS),
                                    Text(
                                      DateFormat(
                                        'dd MMMM yyyy',
                                      ).format(selectedDate),
                                      style: AppSize.getTextStyle(
                                        fontSize: AppSize.bodyFontSize,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(AppSize.paddingM),
                          decoration: BoxDecoration(
                            color: score >= 75 ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(
                              AppSize.cardBorderRadius,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${score.toInt()}%',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Skor',
                                style: AppSize.getTextStyle(
                                  fontSize: AppSize.captionFontSize,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSize.heightPercent(1)),

                    // Statistics
                    Row(
                      children: [
                        _buildStatChip(
                          'Total',
                          displayStats['totalQuestions']?.toString() ?? '0',
                        ),
                        SizedBox(width: AppSize.paddingS),
                        _buildStatChip(
                          'Benar',
                          displayStats['passedQuestions']?.toString() ?? '0',
                          Colors.green,
                        ),
                        SizedBox(width: AppSize.paddingS),
                        _buildStatChip(
                          'Salah',
                          displayStats['failedQuestions']?.toString() ?? '0',
                          Colors.red,
                        ),
                        SizedBox(width: AppSize.paddingS),
                        _buildStatChip(
                          'Skip',
                          displayStats['skippedQuestions']?.toString() ?? '0',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Answers List
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _answers.isEmpty
                    ? Center(child: Text('Tidak ada jawaban'))
                    : ListView.builder(
                      padding: EdgeInsets.all(AppSize.paddingM),
                      itemCount: _answers.length,
                      itemBuilder: (context, index) {
                        final answer = _answers[index];
                        return _buildAnswerCard(answer, index + 1);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, [Color? color]) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.paddingS,
        vertical: AppSize.paddingXS,
      ),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
        border: Border.all(color: (color ?? Colors.grey).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey.shade700,
            ),
          ),
          Text(
            label,
            style: AppSize.getTextStyle(
              fontSize: AppSize.captionFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(Map<String, dynamic> answer, int questionNumber) {
    final bool? answerValue = answer['answerValue'];
    final bool skipped = answer['skipped'] ?? false;
    final String? note = answer['note'];

    Color borderColor;
    Color backgroundColor;
    IconData icon;
    String statusText;

    if (skipped) {
      borderColor = Colors.orange;
      backgroundColor = Colors.orange.withOpacity(0.1);
      icon = Icons.skip_next;
      statusText = 'SKIP';
    } else if (answerValue == true) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
      icon = Icons.check_circle;
      statusText = 'YA';
    } else if (answerValue == false) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
      icon = Icons.cancel;
      statusText = 'TIDAK';
    } else {
      borderColor = Colors.grey;
      backgroundColor = Colors.grey.withOpacity(0.1);
      icon = Icons.help;
      statusText = 'TIDAK DIJAWAB';
    }

    return Card(
      margin: EdgeInsets.only(bottom: AppSize.paddingM),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          border: Border.all(color: borderColor, width: 2),
          color: backgroundColor,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSize.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSize.iconSize,
                    height: AppSize.iconSize,
                    decoration: BoxDecoration(
                      color: borderColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        questionNumber.toString(),
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.captionFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSize.paddingS),
                  Expanded(
                    child: Text(
                      answer['question'] ?? 'Pertanyaan tidak tersedia',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.bodyFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(icon, color: borderColor, size: AppSize.iconSize),
                ],
              ),

              SizedBox(height: AppSize.heightPercent(1)),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.paddingS,
                      vertical: AppSize.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(
                        AppSize.cardBorderRadius,
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.captionFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  if (answer['section'] != null) ...[
                    SizedBox(width: AppSize.paddingS),
                    Text(
                      '${answer['section']}',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.captionFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],

                  if (answer['uniformType'] != null) ...[
                    SizedBox(width: AppSize.paddingS),
                    Text(
                      '• ${answer['uniformType']}',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.captionFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),

              if (note != null && note.isNotEmpty) ...[
                SizedBox(height: AppSize.heightPercent(1)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSize.paddingS),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppSize.cardBorderRadius,
                    ),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catatan:',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.captionFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: AppSize.heightPercent(0.5)),
                      Text(
                        note,
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
