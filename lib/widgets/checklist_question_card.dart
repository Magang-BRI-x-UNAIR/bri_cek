import 'package:flutter/material.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/utils/app_size.dart';

class ChecklistQuestionCard extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onAnswerChanged;
  final ValueChanged<String?> onNoteChanged;
  final AnimationController animationController;
  final Animation<double> animation;
  final Animation<double> fadeAnimation;

  const ChecklistQuestionCard({
    Key? key,
    required this.item,
    required this.onAnswerChanged,
    required this.onNoteChanged,
    required this.animationController,
    required this.animation,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, 20 * (1.0 - animation.value)),
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Card(
              margin: EdgeInsets.symmetric(
                horizontal: AppSize.widthPercent(5),
                vertical: AppSize.heightPercent(1),
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSize.widthPercent(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.bodyFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(2)),

                    _buildAnswerOptions(),

                    if (item.answerValue != null) _buildNoteField(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerOptions() {
    return Row(
      children: [
        _buildAnswerButton(true),
        SizedBox(width: AppSize.widthPercent(3)),
        _buildAnswerButton(false),
      ],
    );
  }

  Widget _buildAnswerButton(bool value) {
    final bool isSelected = item.answerValue == value;
    final String label = value ? 'Ya' : 'Tidak';
    final Color backgroundColor =
        isSelected
            ? (value ? Colors.green.shade50 : Colors.red.shade50)
            : Colors.grey.shade100;
    final Color borderColor =
        isSelected ? (value ? Colors.green : Colors.red) : Colors.grey.shade300;
    final Color textColor =
        isSelected
            ? (value ? Colors.green.shade700 : Colors.red.shade700)
            : Colors.grey.shade600;
    final IconData icon = value ? Icons.check : Icons.close;

    return Expanded(
      child: InkWell(
        onTap: () => onAnswerChanged(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(1)),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: AppSize.iconSize * 0.8),
              SizedBox(width: AppSize.widthPercent(1)),
              Text(
                label,
                style: AppSize.getTextStyle(
                  fontSize: AppSize.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(top: AppSize.heightPercent(2)),
      child: TextFormField(
        initialValue: item.note,
        onChanged: onNoteChanged,
        maxLines: 2,
        decoration: InputDecoration(
          hintText:
              item.answerValue == true
                  ? 'Tambahkan catatan (opsional)'
                  : 'Tambahkan catatan (opsional)', // Changed to make optional
          hintStyle: AppSize.getTextStyle(
            fontSize: AppSize.smallFontSize,
            color: Colors.grey.shade500,
          ),
          contentPadding: EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius / 2),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius / 2),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius / 2),
            borderSide: BorderSide(
              color:
                  item.answerValue == true
                      ? Colors.blue.shade400
                      : Colors.red.shade400,
            ),
          ),
        ),
        style: AppSize.getTextStyle(fontSize: AppSize.bodyFontSize),
        // Remove validator to make notes optional
      ),
    );
  }
}
