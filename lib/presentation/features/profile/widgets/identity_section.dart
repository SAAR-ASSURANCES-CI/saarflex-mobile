import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/form_field_widget.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/date_field_widget.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/dropdown_field_widget.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormSection(
      title: "Pièce d'identité",
      icon: Icons.badge_rounded,
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
        ),
        const SizedBox(height: 20),
        FormFieldWidget(
          controller: idNumberController,
          label: 'Numéro de pièce',
          isRequired: true,
          originalData: originalData,
          originalKey: 'numero_piece_identite',
        ),
        const SizedBox(height: 20),
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
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}
