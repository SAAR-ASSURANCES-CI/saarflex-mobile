import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/core/utils/format_helper.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';

class ResultDetailsCard extends StatelessWidget {
  final SimulationResponse resultat;
  final double screenWidth;
  final double textScaleFactor;

  const ResultDetailsCard({
    super.key,
    required this.resultat,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final padding = screenWidth < 360 ? 16.0 : 20.0;
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final titleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final textFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final expirationFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 6.0 : 8.0;
    final spacing2 = screenWidth < 360 ? 12.0 : 16.0;
    final expirationPadding = screenWidth < 360 ? 10.0 : 12.0;
    final expirationIconSize = screenWidth < 360 ? 14.0 : 16.0;
    final expirationSpacing = screenWidth < 360 ? 6.0 : 8.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: iconSize,
              ),
              SizedBox(width: spacing1),
              Expanded(
                child: Text(
                  'Détails du calcul',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing2),
          Text(
            _formatCalculationText(
              resultat.detailsCalcul?.explication ??
                  'Détails de calcul non disponibles',
            ),
            style: GoogleFonts.poppins(
              fontSize: textFontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (resultat.expiresAt != null) ...[
            SizedBox(height: spacing2),
            Container(
              padding: EdgeInsets.all(expirationPadding),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Colors.orange[700],
                    size: expirationIconSize,
                  ),
                  SizedBox(width: expirationSpacing),
                  Expanded(
                    child: Text(
                      'Ce devis expire le ${resultat.expiresAt!.formatDate()}',
                      style: GoogleFonts.poppins(
                        fontSize: expirationFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCalculationText(String text) {
    return FormatHelper.formatTexteCalcul(text);
  }
}
