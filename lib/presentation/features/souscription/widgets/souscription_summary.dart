import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/core/utils/format_helper.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/saved_quote_model.dart';

class souscriptionSummary extends StatelessWidget {
  final SimulationResponse? simulationResult;
  final SavedQuote? savedQuote;
  final String source;

  const souscriptionSummary({
    super.key,
    this.simulationResult,
    this.savedQuote,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryContent(),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    if (source == 'simulation' && simulationResult != null) {
      return _buildSimulationSummary();
    } else if (source == 'saved_quote' && savedQuote != null) {
      return _buildSavedQuoteSummary();
    }

    return const SizedBox.shrink();
  }

  Widget _buildSimulationSummary() {
    final result = simulationResult!;

    return Column(
      children: [
        _buildSummaryRow('Produit', result.nomProduit),
        _buildSummaryRow(
          'Prime',
          FormatHelper.formatMontant(result.primeCalculee),
        ),
        if (result.franchiseCalculee != null && result.franchiseCalculee! > 0)
          _buildSummaryRow(
            'Franchise',
            FormatHelper.formatMontant(result.franchiseCalculee!),
          ),
      ],
    );
  }

  Widget _buildSavedQuoteSummary() {
    final quote = savedQuote!;

    return Column(
      children: [
        _buildSummaryRow('Produit', quote.nomProduit),
        _buildSummaryRow(
          'Prime',
          FormatHelper.formatMontant(quote.primeCalculee),
        ),
        if (quote.franchiseCalculee > 0)
          _buildSummaryRow(
            'Franchise',
            FormatHelper.formatMontant(quote.franchiseCalculee),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
