import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/profile_helpers.dart';
import 'package:saarflex_app/presentation/features/profile/widgets/image_viewer_dialog.dart';

class ImageDisplayWidget extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final VoidCallback onEdit;

  const ImageDisplayWidget({
    super.key,
    required this.label,
    required this.imageUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidImage = ProfileHelpers.isValidImage(imageUrl);
    final fullImageUrl = imageUrl != null
        ? ProfileHelpers.buildImageUrl(imageUrl!, ApiConstants.baseUrl)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(context, fullImageUrl),
          const SizedBox(height: 8),
          _buildImageContainer(context, fullImageUrl, hasValidImage),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context, String fullImageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showImageDialog(context, fullImageUrl),
              icon: const Icon(
                Icons.visibility,
                size: 20,
                color: AppColors.primary,
              ),
              tooltip: 'Voir en grand',
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: AppColors.secondary,
              ),
              tooltip: 'Modifier',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageContainer(
    BuildContext context,
    String fullImageUrl,
    bool hasValidImage,
  ) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, fullImageUrl),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasValidImage
              ? _buildNetworkImage(fullImageUrl)
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
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
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Image non disponible',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageViewerDialog(imageUrl: imageUrl, label: label);
      },
    );
  }
}
