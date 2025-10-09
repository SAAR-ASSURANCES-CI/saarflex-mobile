import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/core/constants/colors.dart';

class ImageUploadField extends StatelessWidget {
  final bool isRequired;
  final String label;
  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;
  final XFile? selectedImage;

  const ImageUploadField({
    super.key,
    this.isRequired = true,
    required this.label,
    required this.imageUrl,
    required this.isUploading,
    required this.onTap,
    required this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasExistingImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasNewImage = selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isUploading ? null : onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasNewImage
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
                width: hasNewImage ? 2 : 1,
              ),
            ),
            child: isUploading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : hasExistingImage || hasNewImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasNewImage
                        ? Image.file(
                            File(selectedImage!.path),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderContent(label);
                            },
                          ),
                  )
                : _buildPlaceholderContent(label),
          ),
        ),
        if (hasNewImage) ...[
          const SizedBox(height: 8),
          Text(
            'Nouvelle image sélectionnée',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderContent(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColors.textSecondary.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajouter $label',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
