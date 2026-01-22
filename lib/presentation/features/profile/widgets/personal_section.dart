import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/form_field_widget.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/date_field_widget.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/dropdown_field_widget.dart';

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
  final double screenWidth;
  final double textScaleFactor;

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
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final fieldSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return _buildFormSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        FormFieldWidget(
          controller: firstNameController,
          label: 'Nom complet',
          isRequired: true,
          hasError: fieldErrors.containsKey('nom'),
          originalData: originalData,
          originalKey: 'nom',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
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
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
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
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        FormFieldWidget(
          controller: birthPlaceController,
          label: 'Lieu de naissance',
          isRequired: true,
          originalData: originalData,
          originalKey: 'lieu_naissance',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        FormFieldWidget(
          controller: nationalityController,
          label: 'Nationalité',
          isRequired: true,
          originalData: originalData,
          originalKey: 'nationalite',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        FormFieldWidget(
          controller: professionController,
          label: 'Profession',
          isRequired: true,
          originalData: originalData,
          originalKey: 'profession',
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
                style: FontHelper.poppins(
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
