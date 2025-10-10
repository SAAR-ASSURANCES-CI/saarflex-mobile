import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/core/utils/image_labels.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/image_upload_field.dart';

/// Widget de section d'upload d'images d'identité
class IdentityImagesSection extends StatelessWidget {
  final String? identityType;
  final bool isUploadingRecto;
  final bool isUploadingVerso;
  final VoidCallback onPickRecto;
  final VoidCallback onPickVerso;
  final XFile? rectoImage;
  final XFile? versoImage;

  const IdentityImagesSection({
    super.key,
    required this.identityType,
    required this.isUploadingRecto,
    required this.isUploadingVerso,
    required this.onPickRecto,
    required this.onPickVerso,
    required this.rectoImage,
    required this.versoImage,
  });

  @override
  Widget build(BuildContext context) {
    final title = ImageLabels.getUploadTitle(identityType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: title),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ImageUploadField(
          label: ImageLabels.getRectoLabel(identityType),
          isUploading: isUploadingRecto,
          onTap: onPickRecto,
          selectedImage: rectoImage,
        ),
        const SizedBox(height: 20),
        ImageUploadField(
          label: ImageLabels.getVersoLabel(identityType),
          isUploading: isUploadingVerso,
          onTap: onPickVerso,
          selectedImage: versoImage,
        ),
      ],
    );
  }
}
