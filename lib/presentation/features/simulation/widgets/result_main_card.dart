import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';

class ResultMainCard extends StatelessWidget {
  final SimulationResponse resultat;
  final double screenWidth;
  final double textScaleFactor;

  const ResultMainCard({
    super.key,
    required this.resultat,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final padding = screenWidth < 360 ? 16.0 : screenWidth < 600 ? 20.0 : 24.0;
    final titleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final spacing1 = screenWidth < 360 ? 20.0 : 24.0;
    final spacing2 = screenWidth < 360 ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Votre devis',
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: spacing1),
          _buildResultItem(
            'Prime ${resultat.periodicitePrimeFormatee}',
            resultat.primeFormatee,
            Icons.attach_money_rounded,
            isMainResult: true,
          ),
          SizedBox(height: spacing2),
          _buildResultItem(
            'Franchise',
            resultat.franchiseFormatee,
            Icons.account_balance_wallet_rounded,
          ),
          if (resultat.plafondFormate != null) ...[
            SizedBox(height: spacing2),
            _buildResultItem(
              'Plafond de couverture',
              resultat.plafondFormate!,
              Icons.security_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultItem(
    String label,
    String value,
    IconData icon, {
    bool isMainResult = false,
  }) {
    final iconContainerSize = screenWidth < 360 ? 36.0 : 40.0;
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final labelFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final mainValueFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final valueFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final spacing1 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = screenWidth < 360 ? 2.0 : 2.0;
    
    return Row(
      children: [
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(iconContainerSize / 2),
          ),
          child: Icon(icon, color: AppColors.white, size: iconSize),
        ),
        SizedBox(width: spacing1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMainResult ? mainValueFontSize : valueFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
