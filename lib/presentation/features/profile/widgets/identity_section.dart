import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/form_field_widget.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/date_field_widget.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/dropdown_field_widget.dart';

class IdentitySection extends StatelessWidget {
  final TextEditingController idNumberController;
  final String? selectedIdType;
  final DateTime? selectedExpirationDate;
  final List<String> idTypeOptions;
  final Map<String, String?> fieldErrors;
  final Map<String, dynamic> originalData;
  final Function(String?) onIdTypeChanged;
  final Function(DateTime?) onExpirationDateChanged;
  final Function() onDropdownChanged;
  final Function() onDateChanged;
  final double screenWidth;
  final double textScaleFactor;

  const IdentitySection({
    super.key,
    required this.idNumberController,
    required this.selectedIdType,
    required this.selectedExpirationDate,
    required this.idTypeOptions,
    required this.fieldErrors,
    required this.originalData,
    required this.onIdTypeChanged,
    required this.onExpirationDateChanged,
    required this.onDropdownChanged,
    required this.onDateChanged,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final fieldSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return _buildFormSection(
      title: "Pièce d'identité",
      icon: Icons.badge_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        DropdownFieldWidget(
          value: selectedIdType,
          items: idTypeOptions,
          label: 'Type de pièce',
          isRequired: true,
          hintText: 'Sélectionnez le type de pièce',
          onChanged: (value) {
            onIdTypeChanged(value);
            onDropdownChanged();
          },
          originalData: originalData,
          originalKey: 'type_piece_identite',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        FormFieldWidget(
          controller: idNumberController,
          label: 'Numéro de pièce',
          isRequired: true,
          originalData: originalData,
          originalKey: 'numero_piece_identite',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        DateFieldWidget(
          selectedDate: selectedExpirationDate,
          label: 'Date d\'expiration de la pièce',
          onDateSelected: (date) {
            onExpirationDateChanged(date);
            onDateChanged();
          },
          hasError: fieldErrors.containsKey('date_expiration_piece_identite'),
          isRequired: true,
          isExpirationDate: true,
          originalData: originalData,
          originalKey: 'date_expiration_piece_identite',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required double screenWidth,
    required double textScaleFactor,
  }) {
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final iconPadding = screenWidth < 360 ? 6.0 : 8.0;
    final iconSpacing = screenWidth < 360 ? 10.0 : 12.0;
    final titleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final sectionSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: iconSize),
            ),
            SizedBox(width: iconSpacing),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: sectionSpacing),
        ...children,
      ],
    );
  }
}
