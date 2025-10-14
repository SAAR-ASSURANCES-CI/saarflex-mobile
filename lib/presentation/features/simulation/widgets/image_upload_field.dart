import 'dart:io';
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
  final String? uploadedImageUrl;

  const ImageUploadField({
    super.key,
    required this.label,
    required this.isUploading,
    required this.onTap,
    required this.selectedImage,
    this.uploadedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImage != null || uploadedImageUrl != null;

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
                          'Upload en cours...',
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
        if (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Image uploadée avec succès',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty
              ? Image.network(
                  uploadedImageUrl!,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surface,
                      child: Icon(
                        Icons.image,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    );
                  },
                )
              : selectedImage != null
              ? Image.file(
                  File(selectedImage!.path),
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: AppColors.surface,
                  child: Icon(Icons.image, color: AppColors.primary, size: 40),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty
                  ? AppColors.success
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty
                  ? Icons.cloud_done
                  : Icons.check,
              color: AppColors.white,
              size: 16,
            ),
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
