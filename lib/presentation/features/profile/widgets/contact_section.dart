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
  final double screenWidth;
  final double textScaleFactor;

  const ContactSection({
    super.key,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.fieldErrors,
    required this.originalData,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final fieldSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return _buildFormSection(
      title: "Coordonnées",
      icon: Icons.contact_phone_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        FormFieldWidget(
          controller: emailController,
          label: 'Adresse email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          hasError: fieldErrors.containsKey('email'),
          originalData: originalData,
          originalKey: 'email',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        FormFieldWidget(
          controller: phoneController,
          label: 'Numéro de téléphone',
          isRequired: true,
          keyboardType: TextInputType.phone,
          hasError: fieldErrors.containsKey('telephone'),
          originalData: originalData,
          originalKey: 'telephone',
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        FormFieldWidget(
          controller: addressController,
          label: 'Adresse de résidence',
          isRequired: true,
          maxLines: 3,
          originalData: originalData,
          originalKey: 'adresse',
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
