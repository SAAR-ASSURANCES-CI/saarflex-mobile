import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class ResultSuccessHeader extends StatelessWidget {
  final double screenWidth;
  final double textScaleFactor;

  const ResultSuccessHeader({
    super.key,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final containerSize = screenWidth < 360 ? 64.0 : screenWidth < 600 ? 72.0 : 80.0;
    final iconSize = screenWidth < 360 ? 32.0 : screenWidth < 600 ? 36.0 : 40.0;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final subtitleFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final spacing1 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = screenWidth < 360 ? 6.0 : 8.0;
    
    return Center(
      child: Column(
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(containerSize / 2),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: iconSize,
              color: Colors.green,
            ),
          ),
          SizedBox(height: spacing1),
          Text(
            'Devis calculé avec succès !',
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing2),
          Text(
            'Voici votre devis personnalisé',
            style: GoogleFonts.poppins(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
