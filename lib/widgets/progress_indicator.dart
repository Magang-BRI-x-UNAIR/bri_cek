import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;

  const ProgressIndicatorWidget({Key? key, required this.progress})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.paddingHorizontal,
        vertical: AppSize.heightPercent(1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.smallFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.3)),

          // Animasi pada progress bar
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade700,
                minHeight: AppSize.heightPercent(0.6),
                borderRadius: BorderRadius.circular(10),
              );
            },
          ),
        ],
      ),
    );
  }
}
