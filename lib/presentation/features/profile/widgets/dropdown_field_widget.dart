import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';

class DropdownFieldWidget extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final bool isRequired;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final Map<String, dynamic> originalData;
  final String originalKey;

  const DropdownFieldWidget({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.originalData,
    required this.originalKey,
    this.isRequired = false,
    this.hintText = 'Sélectionner',
  });

  @override
  Widget build(BuildContext context) {
    bool isModified = value != originalData[originalKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
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
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: _buildDropdownItems(items, hintText),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
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
  ) {
    return [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          hintText,
          style: GoogleFonts.poppins(
            fontSize: 16,
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    ];
  }
}
