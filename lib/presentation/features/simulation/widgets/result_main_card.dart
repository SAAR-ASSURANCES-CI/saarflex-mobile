import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';

/// Widget de la carte principale des résultats
class ResultMainCard extends StatelessWidget {
  final SimulationResponse resultat;

  const ResultMainCard({super.key, required this.resultat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildResultItem(
            'Prime ${resultat.periodicitePrimeFormatee}',
            resultat.primeFormatee,
            Icons.attach_money_rounded,
            isMainResult: true,
          ),
          const SizedBox(height: 16),
          _buildResultItem(
            'Franchise',
            resultat.franchiseFormatee,
            Icons.account_balance_wallet_rounded,
          ),
          if (resultat.plafondFormate != null) ...[
            const SizedBox(height: 16),
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
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMainResult ? 20 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
