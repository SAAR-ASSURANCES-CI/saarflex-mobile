import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController birthPlaceController;
  final TextEditingController nationalityController;
  final TextEditingController professionController;
  final TextEditingController addressController;
  final String? selectedGender;
  final DateTime? selectedBirthDate;
  final List<String> genderOptions;
  final Map<String, String?> fieldErrors;
  final Function(String?) onGenderChanged;
  final Function(DateTime?) onBirthDateChanged;

  const PersonalInfoSection({
    super.key,
    required this.firstNameController,
    required this.emailController,
    required this.phoneController,
    required this.birthPlaceController,
    required this.nationalityController,
    required this.professionController,
    required this.addressController,
    required this.selectedGender,
    required this.selectedBirthDate,
    required this.genderOptions,
    required this.fieldErrors,
    required this.onGenderChanged,
    required this.onBirthDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      children: [
        _buildTextField(
          controller: firstNameController,
          label: "Nom complet",
          hint: "Votre nom complet",
          icon: Icons.person_outline,
          error: fieldErrors['nom'],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: emailController,
          label: "Email",
          hint: "votre.email@exemple.com",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          error: fieldErrors['email'],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: phoneController,
          label: "Téléphone",
          hint: "Votre numéro de téléphone",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          error: fieldErrors['telephone'],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: birthPlaceController,
          label: "Lieu de naissance",
          hint: "Ville de naissance",
          icon: Icons.location_city_outlined,
          error: fieldErrors['lieu_naissance'],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: nationalityController,
          label: "Nationalité",
          hint: "Votre nationalité",
          icon: Icons.flag_outlined,
          error: fieldErrors['nationalite'],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: professionController,
          label: "Profession",
          hint: "Votre profession",
          icon: Icons.work_outline,
          error: fieldErrors['profession'],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: addressController,
          label: "Adresse",
          hint: "Votre adresse complète",
          icon: Icons.home_outlined,
          maxLines: 2,
          error: fieldErrors['adresse'],
        ),
        const SizedBox(height: 20),
        _buildGenderDropdown(),
        const SizedBox(height: 20),
        _buildBirthDateField(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: BorderSide(
                color: error != null ? AppColors.error : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sexe",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedGender,
          onChanged: onGenderChanged,
          decoration: InputDecoration(
            hintText: "Sélectionnez votre sexe",
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
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
          items: genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(
                gender,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date de naissance",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectBirthDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedBirthDate != null
                          ? "${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}"
                          : "Sélectionnez votre date de naissance",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: selectedBirthDate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedBirthDate) {
      onBirthDateChanged(picked);
    }
  }
}
