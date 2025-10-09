import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/core/utils/image_labels.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/image_upload_field.dart';

class IdentityImagesSection extends StatelessWidget {
  final String? currentIdentityType;
  final String? frontDocumentPath;
  final String? backDocumentPath;
  final bool isUploadingRecto;
  final bool isUploadingVerso;
  final XFile? rectoImage;
  final XFile? versoImage;
  final Function(bool) onPickImage;

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
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormSection(
      title: ImageLabels.getUploadTitle(currentIdentityType),
      icon: Icons.photo_library_rounded,
      children: [
        ImageUploadField(
          label: ImageLabels.getRectoLabel(currentIdentityType),
          imageUrl: frontDocumentPath,
          isUploading: isUploadingRecto,
          onTap: () => onPickImage(true),
          selectedImage: rectoImage,
        ),
        const SizedBox(height: 20),
        ImageUploadField(
          label: ImageLabels.getVersoLabel(currentIdentityType),
          imageUrl: backDocumentPath,
          isUploading: isUploadingVerso,
          onTap: () => onPickImage(false),
          selectedImage: versoImage,
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
