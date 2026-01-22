import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';

class ResultProductInfo extends StatelessWidget {
  final Product produit;
  final SimulationResponse resultat;
  final double screenWidth;
  final double textScaleFactor;

  const ResultProductInfo({
    super.key,
    required this.produit,
    required this.resultat,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final padding = screenWidth < 360 ? 16.0 : 20.0;
    final iconContainerSize = screenWidth < 360 ? 44.0 : 50.0;
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    final nameFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final typeFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final statusFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = screenWidth < 360 ? 3.0 : 4.0;
    final statusPaddingH = screenWidth < 360 ? 10.0 : 12.0;
    final statusPaddingV = screenWidth < 360 ? 5.0 : 6.0;
    
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
      child: Row(
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: produit.type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              produit.type.icon,
              color: produit.type.color,
              size: iconSize,
            ),
          ),
          SizedBox(width: spacing1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produit.nom,
                  style: FontHelper.poppins(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing2),
                Text(
                  produit.type.label,
                  style: FontHelper.poppins(
                    fontSize: typeFontSize,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: statusPaddingH,
              vertical: statusPaddingV,
            ),
            decoration: BoxDecoration(
              color: resultat.statut.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              resultat.statut.label,
              style: FontHelper.poppins(
                fontSize: statusFontSize,
                fontWeight: FontWeight.w500,
                color: resultat.statut.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
