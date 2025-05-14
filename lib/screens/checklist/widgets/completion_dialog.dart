import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class CompletionDialog extends StatelessWidget {
  final double score;
  final String categoryName;
  final VoidCallback onBackToDetails;
  final VoidCallback onFinish;
  final bool hasEmployeeData;
  final int skippedCount;

  const CompletionDialog({
    Key? key,
    required this.score,
    required this.categoryName,
    required this.onBackToDetails,
    required this.onFinish,
    this.hasEmployeeData = false,
    this.skippedCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scoreInt = score.toInt();
    final bool isPassing = scoreInt >= 75;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
      ),
      title: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child:
                    isPassing
                        ? Transform.rotate(
                          angle: value * 2 * 3.14 * 0.05,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: AppSize.iconSize * 2,
                          ),
                        )
                        : Icon(
                          Icons.warning,
                          color: Colors.amber,
                          size: AppSize.iconSize * 2,
                        ),
              );
            },
          ),
          SizedBox(height: AppSize.heightPercent(1)),
          Text(
            isPassing ? 'Checklist Selesai' : 'Checklist Perlu Perhatian',
            style: AppSize.getTextStyle(
              fontSize: AppSize.subtitleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score display and animation
          _buildScoreIndicator(score, isPassing, scoreInt),
          SizedBox(height: AppSize.heightPercent(2)),
          _buildSummaryText(isPassing, categoryName),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onBackToDetails,
          child: Text(
            'Kembali ke Detail Bank',
            style: AppSize.getTextStyle(
              fontSize: AppSize.bodyFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        FilledButton(
          onPressed: onFinish,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
            ),
          ),
          child: Text('Selesai'),
        ),
      ],
    );
  }

  Widget _buildScoreIndicator(double score, bool isPassing, int scoreInt) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score / 100),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: AppSize.widthPercent(25),
              height: AppSize.widthPercent(25),
              child: CircularProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                color: isPassing ? Colors.green : Colors.amber,
                strokeWidth: 10,
              ),
            ),
            Column(
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: scoreInt),
                  duration: Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Text(
                      '$value%',
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: isPassing ? Colors.green : Colors.amber,
                      ),
                    );
                  },
                ),
                Text(
                  'Score',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryText(bool isPassing, String categoryName) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              Text(
                isPassing
                    ? 'Checklist $categoryName telah selesai dengan hasil yang baik.'
                    : 'Checklist $categoryName memerlukan perhatian lebih lanjut.',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              if (skippedCount > 0)
                Padding(
                  padding: EdgeInsets.only(top: AppSize.heightPercent(1)),
                  child: Text(
                    '$skippedCount pertanyaan di-skip dan tidak dihitung dalam skor.',
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.smallFontSize,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
