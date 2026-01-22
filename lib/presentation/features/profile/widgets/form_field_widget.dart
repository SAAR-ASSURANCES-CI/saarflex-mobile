import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool hasError;
  final Map<String, dynamic> originalData;
  final String originalKey;
  final Function()? onChanged;
  final double screenWidth;
  final double textScaleFactor;

  const FormFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.originalData,
    required this.originalKey,
    required this.screenWidth,
    required this.textScaleFactor,
    this.isRequired = false,
    this.keyboardType,
    this.maxLines = 1,
    this.hasError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isModified =
        originalKey.isNotEmpty &&
        controller.text.trim() != originalData[originalKey];

    final labelFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final modifiedFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final inputFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final hintFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final labelSpacing = screenWidth < 360 ? 6.0 : 8.0;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
    final verticalPadding = screenWidth < 360 ? 14.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: FontHelper.poppins(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              if (isModified)
                TextSpan(
                  text: ' (modifié)',
                  style: FontHelper.poppins(
                    fontSize: modifiedFontSize,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: labelSpacing),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) {
            onChanged?.call();
          },
          style: FontHelper.poppins(
            fontSize: inputFontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Saisir $label',
            hintStyle: FontHelper.poppins(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              fontSize: hintFontSize,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error.withOpacity(0.5)
                    : isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
          ),
        ),
      ],
    );
  }
}
