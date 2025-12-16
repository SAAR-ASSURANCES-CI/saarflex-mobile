import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class DropdownFieldWidget extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final bool isRequired;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final Map<String, dynamic> originalData;
  final String originalKey;
  final double screenWidth;
  final double textScaleFactor;

  const DropdownFieldWidget({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.originalData,
    required this.originalKey,
    required this.screenWidth,
    required this.textScaleFactor,
    this.isRequired = false,
    this.hintText = 'Sélectionner',
  });

  @override
  Widget build(BuildContext context) {
    bool isModified = value != originalData[originalKey];

    final labelFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final modifiedFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final textFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final labelSpacing = screenWidth < 360 ? 6.0 : 8.0;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
    final verticalPadding = screenWidth < 360 ? 14.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(
                    fontSize: modifiedFontSize,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: labelSpacing),
        DropdownButtonFormField<String>(
          value: value,
          items: _buildDropdownItems(items, hintText, textFontSize),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: textFontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
    List<String> items,
    String hintText,
    double fontSize,
  ) {
    return [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          hintText,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
        ),
      ),
      ...items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    ];
  }
}
