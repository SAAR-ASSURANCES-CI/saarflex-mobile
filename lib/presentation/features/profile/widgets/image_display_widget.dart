import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/profile_helpers.dart';

class ImageDisplayWidget extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final VoidCallback onEdit;
  final int? cacheTimestamp;

  const ImageDisplayWidget({
    super.key,
    required this.label,
    required this.imageUrl,
    required this.onEdit,
    this.cacheTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidImage = ProfileHelpers.isValidImage(imageUrl);
    final fullImageUrl = imageUrl != null
        ? ProfileHelpers.buildImageUrl(imageUrl!, ApiConstants.baseUrl)
        : '';
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(),
          const SizedBox(height: 8),
          _buildImageContainer(fullImageUrl, hasValidImage, screenWidth),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return Text(
      label,
      style: FontHelper.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildImageContainer(
    String fullImageUrl,
    bool hasValidImage,
    double screenWidth,
  ) {
    final imageHeight = screenWidth < 360 ? 180.0 : 220.0;
    
    return Container(
      height: imageHeight,
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
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    final cacheBuster = cacheTimestamp ?? imageUrl.hashCode;
    final imageUrlWithCache = imageUrl.contains('?')
        ? '$imageUrl&t=$cacheBuster'
        : '$imageUrl?t=$cacheBuster';
    
    return Image.network(
      imageUrlWithCache,
      key: ValueKey('profile_image_${imageUrl}_$cacheBuster'),
      fit: BoxFit.cover,
      cacheWidth: null,
      cacheHeight: null,
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
              style: FontHelper.poppins(
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

}
