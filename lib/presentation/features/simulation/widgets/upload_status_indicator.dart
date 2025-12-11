import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';

class UploadStatusIndicator extends StatelessWidget {
  final bool isUploading;
  final bool hasUploadedImages;
  final VoidCallback? onRetry;
  final double screenWidth;
  final double textScaleFactor;

  const UploadStatusIndicator({
    super.key,
    required this.isUploading,
    required this.hasUploadedImages,
    required this.screenWidth,
    required this.textScaleFactor,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUploading && !hasUploadedImages) {
      return const SizedBox.shrink();
    }

    final margin = screenWidth < 360 ? 6.0 : 8.0;
    final horizontalPadding = screenWidth < 360 ? 10.0 : 12.0;
    final verticalPadding = screenWidth < 360 ? 6.0 : 8.0;
    final spacing = screenWidth < 360 ? 6.0 : 8.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: margin),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          SizedBox(width: spacing),
          Flexible(child: _buildText()),
          if (onRetry != null && !isUploading && !hasUploadedImages) ...[
            SizedBox(width: spacing),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final iconSize = screenWidth < 360 ? 14.0 : 16.0;
    
    if (isUploading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    } else if (hasUploadedImages) {
      return Icon(Icons.check_circle, size: iconSize, color: AppColors.success);
    }

    return Icon(Icons.error, size: iconSize, color: AppColors.error);
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

    final fontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);

    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRetryButton() {
    final paddingH = screenWidth < 360 ? 6.0 : 8.0;
    final paddingV = screenWidth < 360 ? 3.0 : 4.0;
    final fontSize = (10.0 / textScaleFactor).clamp(9.0, 12.0);

    return GestureDetector(
      onTap: onRetry,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: paddingH,
          vertical: paddingV,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Réessayer',
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
