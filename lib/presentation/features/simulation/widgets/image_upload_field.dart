import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/core/constants/colors.dart';

/// Widget de champ d'upload d'image réutilisable
class ImageUploadField extends StatelessWidget {
  final String label;
  final bool isUploading;
  final VoidCallback onTap;
  final XFile? selectedImage;

  const ImageUploadField({
    super.key,
    required this.label,
    required this.isUploading,
    required this.onTap,
    required this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isUploading ? null : onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: hasImage
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage ? AppColors.primary : AppColors.border,
                width: hasImage ? 2 : 1,
              ),
            ),
            child: isUploading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Traitement...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : hasImage
                ? _buildImagePreview()
                : _buildUploadPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            selectedImage!.path,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surface,
                child: Icon(Icons.image, color: AppColors.primary, size: 40),
              );
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check, color: AppColors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          'Appuyez pour sélectionner',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        Text(
          'une image',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
