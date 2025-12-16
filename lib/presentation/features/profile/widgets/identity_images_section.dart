import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/utils/image_labels.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/image_upload_field.dart';

class IdentityImagesSection extends StatelessWidget {
  final String? currentIdentityType;
  final String? frontDocumentPath;
  final String? backDocumentPath;
  final bool isUploadingRecto;
  final bool isUploadingVerso;
  final XFile? rectoImage;
  final XFile? versoImage;
  final Function(bool) onPickImage;
  final double screenWidth;
  final double textScaleFactor;

  const IdentityImagesSection({
    super.key,
    required this.currentIdentityType,
    required this.frontDocumentPath,
    required this.backDocumentPath,
    required this.isUploadingRecto,
    required this.isUploadingVerso,
    required this.rectoImage,
    required this.versoImage,
    required this.onPickImage,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final fieldSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return _buildFormSection(
      title: ImageLabels.getUploadTitle(currentIdentityType),
      icon: Icons.photo_library_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        ImageUploadField(
          label: ImageLabels.getRectoLabel(currentIdentityType),
          imageUrl: frontDocumentPath,
          isUploading: isUploadingRecto,
          onTap: () => onPickImage(true),
          selectedImage: rectoImage,
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        SizedBox(height: fieldSpacing),
        ImageUploadField(
          label: ImageLabels.getVersoLabel(currentIdentityType),
          imageUrl: backDocumentPath,
          isUploading: isUploadingVerso,
          onTap: () => onPickImage(false),
          selectedImage: versoImage,
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
