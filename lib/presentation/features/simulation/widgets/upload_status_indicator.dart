import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';

class UploadStatusIndicator extends StatelessWidget {
  final bool isUploading;
  final bool hasUploadedImages;
  final VoidCallback? onRetry;

  const UploadStatusIndicator({
    super.key,
    required this.isUploading,
    required this.hasUploadedImages,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUploading && !hasUploadedImages) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(width: 8),
          _buildText(),
          if (onRetry != null && !isUploading && !hasUploadedImages) ...[
            const SizedBox(width: 8),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (isUploading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    } else if (hasUploadedImages) {
      return Icon(Icons.check_circle, size: 16, color: AppColors.success);
    }

    return Icon(Icons.error, size: 16, color: AppColors.error);
  }

  Widget _buildText() {
    String text;
    Color textColor;

    if (isUploading) {
      text = 'Upload des images en cours...';
      textColor = AppColors.primary;
    } else if (hasUploadedImages) {
      text = 'Images uploadées avec succès';
      textColor = AppColors.success;
    } else {
      text = 'Erreur lors de l\'upload';
      textColor = AppColors.error;
    }

    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Réessayer',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isUploading) {
      return AppColors.primary.withOpacity(0.1);
    } else if (hasUploadedImages) {
      return AppColors.success.withOpacity(0.1);
    }
    return AppColors.error.withOpacity(0.1);
  }

  Color _getBorderColor() {
    if (isUploading) {
      return AppColors.primary.withOpacity(0.3);
    } else if (hasUploadedImages) {
      return AppColors.success.withOpacity(0.3);
    }
    return AppColors.error.withOpacity(0.3);
  }
}
