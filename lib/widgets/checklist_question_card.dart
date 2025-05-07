import 'package:flutter/material.dart';
import 'package:bri_cek/utils/app_size.dart';
import 'package:bri_cek/models/checklist_item.dart';

class QuestionCard extends StatelessWidget {
  final ChecklistItem item;
  final Function(bool?) onAnswerChanged;
  final Function(String) onNoteChanged;
  final int questionNumber;
  final GlobalKey<FormState>? formKey;

  const QuestionCard({
    Key? key,
    required this.item,
    required this.onAnswerChanged,
    required this.onNoteChanged,
    required this.questionNumber,
    this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.paddingHorizontal),
        child: Container(
          padding: EdgeInsets.all(AppSize.paddingHorizontal * 0.8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSize.cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question number
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.widthPercent(2.5),
                  vertical: AppSize.heightPercent(0.3),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Pertanyaan $questionNumber',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

              SizedBox(height: AppSize.heightPercent(1)),

              // Question text
              Text(
                item.question,
                style: AppSize.getTextStyle(
                  fontSize: AppSize.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),

              SizedBox(height: AppSize.heightPercent(2)),

              // Options
              Column(
                children:
                    item.options.map((option) {
                      final isSelected = item.answerValue == (option == 'Ya');
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: AppSize.heightPercent(1),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.blue.shade400
                                    : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSize.cardBorderRadius,
                          ),
                          color:
                              isSelected ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: RadioListTile<bool>(
                          title: Text(
                            option,
                            style: AppSize.getTextStyle(
                              fontSize: AppSize.bodyFontSize,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  isSelected
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade800,
                            ),
                          ),
                          value: option == 'Ya',
                          groupValue: item.answerValue,
                          activeColor: Colors.blue.shade700,
                          onChanged: onAnswerChanged,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSize.widthPercent(3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSize.cardBorderRadius,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              SizedBox(height: AppSize.heightPercent(1)),

              // Note field
              if (item.allowsNote) ...[
                Text(
                  'Catatan (opsional):',
                  style: AppSize.getTextStyle(
                    fontSize: AppSize.bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: AppSize.heightPercent(0.5)),
                TextFormField(
                  initialValue: item.note,
                  onChanged: onNoteChanged,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan jika perlu',
                    hintStyle: AppSize.getTextStyle(
                      fontSize: AppSize.smallFontSize,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSize.cardBorderRadius,
                      ),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSize.cardBorderRadius,
                      ),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSize.cardBorderRadius,
                      ),
                      borderSide: BorderSide(color: Colors.blue.shade400),
                    ),
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
