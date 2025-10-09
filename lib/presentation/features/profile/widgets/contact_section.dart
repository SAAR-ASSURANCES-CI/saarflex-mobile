import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/form_field_widget.dart';

class ContactSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final Map<String, String?> fieldErrors;
  final Map<String, dynamic> originalData;

  const ContactSection({
    super.key,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.fieldErrors,
    required this.originalData,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormSection(
      title: "Coordonnées",
      icon: Icons.contact_phone_rounded,
      children: [
        FormFieldWidget(
          controller: emailController,
          label: 'Adresse email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          hasError: fieldErrors.containsKey('email'),
          originalData: originalData,
          originalKey: 'email',
        ),
        const SizedBox(height: 20),
        FormFieldWidget(
          controller: phoneController,
          label: 'Numéro de téléphone',
          isRequired: true,
          keyboardType: TextInputType.phone,
          hasError: fieldErrors.containsKey('telephone'),
          originalData: originalData,
          originalKey: 'telephone',
        ),
        const SizedBox(height: 20),
        FormFieldWidget(
          controller: addressController,
          label: 'Adresse de résidence',
          isRequired: true,
          maxLines: 3,
          originalData: originalData,
          originalKey: 'adresse',
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
