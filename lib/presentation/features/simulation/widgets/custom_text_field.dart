import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String fieldName;
  final String label;
  final bool isRequired;
  final IconData icon;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final TextInputType? keyboardType;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.fieldName,
    required this.label,
    required this.isRequired,
    required this.icon,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Votre $label',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
