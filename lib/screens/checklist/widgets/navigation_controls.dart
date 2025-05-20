import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';

class NavigationControls extends StatelessWidget {
  final bool isFirstItem;
  final bool isLastItem;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSave;
  final bool isValid;
  final bool isAnimating;

  const NavigationControls({
    Key? key,
    required this.isFirstItem,
    required this.isLastItem,
    required this.onPrevious,
    required this.onNext,
    required this.onSave,
    required this.isValid,
    this.isAnimating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(5),
        vertical: AppSize.heightPercent(1.8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Expanded(
            flex: 4,
            child: ElevatedButton.icon(
              onPressed: isFirstItem || isAnimating ? null : onPrevious,
              icon: Icon(Icons.arrow_back, size: AppSize.iconSize * 0.8),
              label: Text(
                'Sebelumnya',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: isFirstItem ? Colors.grey : Colors.blue.shade700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                backgroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.withOpacity(0.5),
                disabledBackgroundColor: Colors.grey.shade100,
                elevation: 0.5,
                side: BorderSide(color: Colors.blue.shade100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.heightPercent(1.5),
                ),
              ),
            ),
          ),

          SizedBox(width: AppSize.widthPercent(3)),

          // Next/Save button
          Expanded(
            flex: 5,
            child: FilledButton.icon(
              onPressed:
                  isAnimating || !isValid
                      ? null
                      : (isLastItem ? onSave : onNext),
              icon: Icon(
                isLastItem ? Icons.check : Icons.arrow_forward,
                size: AppSize.iconSize * 0.8,
              ),
              label: Text(
                isLastItem ? 'Simpan' : 'Selanjutnya',
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color:
                      isLastItem
                          ? Colors.white
                          : (isAnimating ? Colors.grey : Colors.white),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isLastItem ? Colors.green.shade600 : Colors.blue.shade700,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.heightPercent(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
