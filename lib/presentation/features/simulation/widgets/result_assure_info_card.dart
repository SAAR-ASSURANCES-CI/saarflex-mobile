import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';

class ResultAssureInfoCard extends StatelessWidget {
  final SimulationResponse resultat;

  const ResultAssureInfoCard({super.key, required this.resultat});

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'assuré n'est pas le souscripteur ET si les informations existent
    if (resultat.assureEstSouscripteur || resultat.informationsAssure == null) {
      return const SizedBox.shrink(); // Ne rien afficher
    }

    final informations = resultat.informationsAssure!;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de l\'assuré',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Récapitulatif avant sauvegarde',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Nom complet',
            informations['nom_complet']?.toString() ?? '',
            Icons.person,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Date de naissance',
            informations['date_naissance']?.toString() ?? '',
            Icons.cake,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Type de pièce',
            informations['type_piece_identite']?.toString() ?? '',
            Icons.badge,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Numéro de pièce',
            informations['numero_piece_identite']?.toString() ?? '',
            Icons.credit_card,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Téléphone',
            informations['telephone']?.toString() ?? '',
            Icons.phone,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Adresse',
            informations['adresse']?.toString() ?? '',
            Icons.location_on,
          ),
          if (informations['email'] != null) ...[
            const SizedBox(height: 12),
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

  /// Helper pour afficher une ligne d'information avec icône
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            '$label :',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value.isNotEmpty ? value : 'Non renseigné',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
