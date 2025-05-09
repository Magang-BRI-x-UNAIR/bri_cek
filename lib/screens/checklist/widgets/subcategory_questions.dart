import 'package:flutter/material.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/utils/app_size.dart';

class SubcategoryQuestions extends StatelessWidget {
  final String categoryName;
  final String subcategoryName;
  final List<ChecklistItem> questions;
  final Function(ChecklistItem, bool?) onAnswerChanged;
  final Function(ChecklistItem, String?) onNoteChanged;

  const SubcategoryQuestions({
    Key? key,
    required this.categoryName,
    required this.subcategoryName,
    required this.questions,
    required this.onAnswerChanged,
    required this.onNoteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        SizedBox(height: AppSize.heightPercent(1)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return _buildQuestionCard(questions[index], index);
          },
        ),
        // Add padding at bottom to ensure last card isn't cut off by navigation bar
        SizedBox(height: AppSize.heightPercent(2)),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: AppSize.getTextStyle(
              fontSize: AppSize.smallFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: AppSize.heightPercent(0.5)),
          Row(
            children: [
              Icon(
                Icons.list_alt_rounded,
                size: AppSize.iconSize * 0.9,
                color: Colors.blue.shade800,
              ),
              SizedBox(width: AppSize.widthPercent(2)),
              Expanded(
                child: Text(
                  subcategoryName,
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.5)),
          Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ChecklistItem item, int index) {
    final bool isAnswered = item.answerValue != null;

    return Card(
      margin: EdgeInsets.only(
        bottom: AppSize.heightPercent(1.5),
        left: AppSize.widthPercent(5),
        right: AppSize.widthPercent(5),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
        side:
            isAnswered
                ? BorderSide(
                  color:
                      item.answerValue!
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                  width: 1,
                )
                : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSize.widthPercent(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSize.widthPercent(7),
                  height: AppSize.widthPercent(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isAnswered
                            ? (item.answerValue!
                                ? Colors.green.shade100
                                : Colors.red.shade100)
                            : Colors.blue.shade50,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: AppSize.getTextStyle(
                        fontSize: AppSize.smallFontSize,
                        fontWeight: FontWeight.w600,
                        color:
                            isAnswered
                                ? (item.answerValue!
                                    ? Colors.green.shade700
                                    : Colors.red.shade700)
                                : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.widthPercent(3)),
                Expanded(
                  child: Text(
                    item.question,
                    style: AppSize.getTextStyle(
                      fontSize: AppSize.bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.heightPercent(2)),
            _buildAnswerOptions(item),
            if (item.answerValue != null) _buildNoteField(item),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(ChecklistItem item) {
    return Row(
      children: [
        _buildAnswerButton(item, true),
        SizedBox(width: AppSize.widthPercent(3)),
        _buildAnswerButton(item, false),
      ],
    );
  }

  Widget _buildAnswerButton(ChecklistItem item, bool value) {
    final bool isSelected = item.answerValue == value;
    final String label = value ? 'Ya' : 'Tidak';
    final Color backgroundColor =
        isSelected
            ? (value ? Colors.green.shade50 : Colors.red.shade50)
            : Colors.grey.shade50;
    final Color borderColor =
        isSelected
            ? (value ? Colors.green.shade400 : Colors.red.shade400)
            : Colors.grey.shade300;
    final Color textColor =
        isSelected
            ? (value ? Colors.green.shade700 : Colors.red.shade700)
            : Colors.grey.shade600;
    final IconData icon = value ? Icons.check_circle : Icons.cancel;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onAnswerChanged(item, value),
          borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(1.2)),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color:
                              value
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 1),
                        ),
                      ]
                      : null,
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
      ),
    );
  }

  Widget _buildNoteField(ChecklistItem item) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(top: AppSize.heightPercent(1.5)),
      child: TextFormField(
        initialValue: item.note,
        onChanged: (value) => onNoteChanged(item, value),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Tambahkan catatan (opsional)',
          hintStyle: AppSize.getTextStyle(
            fontSize: AppSize.smallFontSize,
            color: Colors.grey.shade500,
          ),
          filled: true,
          fillColor:
              item.answerValue == true
                  ? Colors.green.withOpacity(0.05)
                  : Colors.red.withOpacity(0.05),
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
              width: 1.5,
            ),
          ),
        ),
        style: AppSize.getTextStyle(fontSize: AppSize.bodyFontSize),
      ),
    );
  }
}
