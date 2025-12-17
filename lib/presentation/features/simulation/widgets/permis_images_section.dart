import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/image_upload_field.dart';

class PermisImagesSection extends StatelessWidget {
  final bool isUploadingRecto;
  final bool isUploadingVerso;
  final VoidCallback onPickRecto;
  final VoidCallback onPickVerso;
  final XFile? rectoImage;
  final XFile? versoImage;
  final String? uploadedRectoUrl;
  final String? uploadedVersoUrl;

  const PermisImagesSection({
    super.key,
    required this.isUploadingRecto,
    required this.isUploadingVerso,
    required this.onPickRecto,
    required this.onPickVerso,
    required this.rectoImage,
    required this.versoImage,
    this.uploadedRectoUrl,
    this.uploadedVersoUrl,
  });

  @override
  Widget build(BuildContext context) {
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
              const TextSpan(text: 'Permis de conduire'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ImageUploadField(
          label: 'Recto du permis',
          isUploading: isUploadingRecto,
          onTap: onPickRecto,
          selectedImage: rectoImage,
          uploadedImageUrl: uploadedRectoUrl,
        ),
        const SizedBox(height: 20),
        ImageUploadField(
          label: 'Verso du permis',
          isUploading: isUploadingVerso,
          onTap: onPickVerso,
          selectedImage: versoImage,
          uploadedImageUrl: uploadedVersoUrl,
        ),
      ],
    );
  }
}


