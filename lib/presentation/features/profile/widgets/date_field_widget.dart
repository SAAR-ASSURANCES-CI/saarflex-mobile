import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';

class DateFieldWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final String label;
  final Function(DateTime?) onDateSelected;
  final bool isRequired;
  final bool hasError;
  final bool isExpirationDate;
  final Map<String, dynamic> originalData;
  final String originalKey;
  final Function()? onChanged;

  const DateFieldWidget({
    super.key,
    required this.selectedDate,
    required this.label,
    required this.onDateSelected,
    required this.originalData,
    required this.originalKey,
    this.isRequired = false,
    this.hasError = false,
    this.isExpirationDate = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? originalDate = originalData[originalKey];
    bool isModified = !_areDatesEqual(selectedDate, originalDate);

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
        InkWell(
          onTap: () => _selectDate(
            context,
            selectedDate,
            onDateSelected,
            isExpirationDate,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withOpacity(0.5)
                    : isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: hasError ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Sélectionner $label',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onDateSelected,
    bool isExpirationDate,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = isExpirationDate
        ? now
        : DateTime(now.year - 120, now.month, now.day);
    final DateTime lastDate = isExpirationDate
        ? DateTime(now.year + 20, now.month, now.day)
        : DateTime(now.year - 16, now.month, now.day);

    DateTime initialDate;
    if (currentDate != null) {
      if (currentDate.isBefore(firstDate)) {

        initialDate = firstDate;
      } else if (currentDate.isAfter(lastDate)) {

        initialDate = lastDate;
      } else {
        initialDate = currentDate;
      }
    } else {
      initialDate = isExpirationDate ? now : lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
      onChanged?.call();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
