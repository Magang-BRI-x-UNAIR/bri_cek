import 'package:flutter/material.dart';
import 'package:bri_cek/services/survey_result_service.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:intl/intl.dart';

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
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Map<String, dynamic>> answers;

      if (widget.selectedCategory != null) {
        // Load jawaban untuk kategori tertentu
        answers = await _surveyResultService.getSurveyAnswersByCategory(
          widget.surveyId,
          widget.selectedCategory!,
        );
      } else {
        // Load semua jawaban
        answers = await _surveyResultService.getSurveyAnswers(widget.surveyId);
      }

      setState(() {
        _answers = answers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Tanggal tidak tersedia';

    DateTime date;
    if (timestamp is DateTime) {
      date = timestamp;
    } else {
      date = timestamp.toDate();
    }

    return DateFormat('dd MMMM yyyy, HH:mm').format(date);
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
    final score = statistics['score'] ?? 0;
    final scoreColor = _getScoreColor(score);

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
                        widget.surveyData['selectedCategory'] ??
                            'Kategori tidak diketahui',
                        style: AppSize.getTextStyle(
                          fontSize: AppSize.bodyFontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSize.heightPercent(1)),

            Text(
              _formatDate(widget.surveyData['submittedAt']),
              style: AppSize.getTextStyle(
                fontSize: AppSize.smallFontSize,
                color: Colors.grey.shade600,
              ),
            ),

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
                    '${(score as num).toInt()}%',
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
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    (statistics['totalQuestions'] ?? 0).toString(),
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: AppSize.widthPercent(2)),
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

  Widget _buildAnswersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Jawaban',
          style: AppSize.getTextStyle(
            fontSize: AppSize.subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
                  'Error: $_error',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSize.heightPercent(1)),
                ElevatedButton(
                  onPressed: _loadAnswers,
                  child: Text('Coba Lagi'),
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
                  'Tidak ada jawaban ditemukan',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _answers.length,
            itemBuilder: (context, index) {
              final answer = _answers[index];
              return _buildAnswerCard(answer, index + 1);
            },
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
                        Text(
                          '${answer['category'] ?? ''} ${answer['subcategory'] != null ? '• ${answer['subcategory']}' : ''}',
                          style: AppSize.getTextStyle(
                            fontSize: AppSize.smallFontSize,
                            color: Colors.grey.shade600,
                          ),
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

  Color _getScoreColor(dynamic score) {
    if (score == null) return Colors.grey;
    final scoreValue = (score as num).toDouble();
    if (scoreValue >= 80) return Colors.green;
    if (scoreValue >= 60) return Colors.orange;
    return Colors.red;
  }
}
