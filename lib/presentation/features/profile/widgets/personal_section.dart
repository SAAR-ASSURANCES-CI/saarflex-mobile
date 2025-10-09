import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/form_field_widget.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/date_field_widget.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/dropdown_field_widget.dart';

class PersonalSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController birthPlaceController;
  final TextEditingController nationalityController;
  final TextEditingController professionController;
  final String? selectedGender;
  final DateTime? selectedBirthDate;
  final List<String> genderOptions;
  final Map<String, String?> fieldErrors;
  final Map<String, dynamic> originalData;
  final Function(String?) onGenderChanged;
  final Function(DateTime?) onBirthDateChanged;
  final Function() onDropdownChanged;
  final Function() onDateChanged;

  const PersonalSection({
    super.key,
    required this.firstNameController,
    required this.birthPlaceController,
    required this.nationalityController,
    required this.professionController,
    required this.selectedGender,
    required this.selectedBirthDate,
    required this.genderOptions,
    required this.fieldErrors,
    required this.originalData,
    required this.onGenderChanged,
    required this.onBirthDateChanged,
    required this.onDropdownChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      children: [
        FormFieldWidget(
          controller: firstNameController,
          label: 'Nom complet',
          isRequired: true,
          hasError: fieldErrors.containsKey('nom'),
          originalData: originalData,
          originalKey: 'nom',
        ),
        const SizedBox(height: 20),
        DropdownFieldWidget(
          value: selectedGender,
          items: genderOptions,
          label: 'Sexe',
          isRequired: true,
          hintText: 'Sélectionnez votre sexe',
          onChanged: (value) {
            onGenderChanged(value);
            onDropdownChanged();
          },
          originalData: originalData,
          originalKey: 'sexe',
        ),
        const SizedBox(height: 20),
        DateFieldWidget(
          selectedDate: selectedBirthDate,
          label: 'Date de naissance',
          onDateSelected: (date) {
            onBirthDateChanged(date);
            onDateChanged();
          },
          hasError: fieldErrors.containsKey('date_naissance'),
          isRequired: false,
          originalData: originalData,
          originalKey: 'date_naissance',
        ),
        const SizedBox(height: 20),
        FormFieldWidget(
          controller: birthPlaceController,
          label: 'Lieu de naissance',
          isRequired: true,
          originalData: originalData,
          originalKey: 'lieu_naissance',
        ),
        const SizedBox(height: 20),
        FormFieldWidget(
          controller: nationalityController,
          label: 'Nationalité',
          isRequired: true,
          originalData: originalData,
          originalKey: 'nationalite',
        ),
        const SizedBox(height: 20),
        FormFieldWidget(
          controller: professionController,
          label: 'Profession',
          isRequired: true,
          originalData: originalData,
          originalKey: 'profession',
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
