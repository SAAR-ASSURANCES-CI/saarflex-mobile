import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';

class ResultAssureInfoCard extends StatelessWidget {
  final SimulationResponse resultat;
  final double screenWidth;
  final double textScaleFactor;

  const ResultAssureInfoCard({
    super.key,
    required this.resultat,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {

    if (resultat.assureEstSouscripteur || resultat.informationsAssure == null) {
      return const SizedBox.shrink(); // Ne rien afficher
    }

    final informations = resultat.informationsAssure!;

    final padding = screenWidth < 360 ? 16.0 : 20.0;
    final marginBottom = screenWidth < 360 ? 20.0 : 24.0;
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final iconPadding = screenWidth < 360 ? 6.0 : 8.0;
    final titleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final subtitleFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 10.0 : 12.0;
    final spacing2 = screenWidth < 360 ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.only(bottom: marginBottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
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
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacing1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de l\'assuré',
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Récapitulatif avant sauvegarde',
                      style: GoogleFonts.poppins(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing2),
          _buildInfoRow(
            'Nom complet',
            informations['nom_complet']?.toString() ?? '',
            Icons.person,
          ),
          SizedBox(height: spacing2),
          _buildInfoRow(
            'Date de naissance',
            informations['date_naissance']?.toString() ?? '',
            Icons.cake,
          ),
          SizedBox(height: spacing2),
          _buildInfoRow(
            'Type de pièce',
            informations['type_piece_identite']?.toString() ?? '',
            Icons.badge,
          ),
          SizedBox(height: spacing2),
          _buildInfoRow(
            'Numéro de pièce',
            informations['numero_piece_identite']?.toString() ?? '',
            Icons.credit_card,
          ),
          SizedBox(height: spacing2),
          _buildInfoRow(
            'Téléphone',
            informations['telephone']?.toString() ?? '',
            Icons.phone,
          ),
          SizedBox(height: spacing2),
          _buildInfoRow(
            'Adresse',
            informations['adresse']?.toString() ?? '',
            Icons.location_on,
          ),
          if (informations['email'] != null) ...[
            SizedBox(height: spacing2),
            _buildInfoRow(
              'Email',
              informations['email']!.toString(),
              Icons.email,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final iconSize = screenWidth < 360 ? 14.0 : 16.0;
    final fontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final spacing1 = screenWidth < 360 ? 6.0 : 8.0;
    final spacing2 = screenWidth < 360 ? 6.0 : 8.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize, color: AppColors.textSecondary),
        SizedBox(width: spacing1),
        Expanded(
          flex: 2,
          child: Text(
            '$label :',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: spacing2),
        Expanded(
          flex: 3,
          child: Text(
            value.isNotEmpty ? value : 'Non renseigné',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
