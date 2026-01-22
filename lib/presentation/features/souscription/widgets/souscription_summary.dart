import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/utils/format_helper.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/models/saved_quote_model.dart';

class souscriptionSummary extends StatelessWidget {
  final SimulationResponse? simulationResult;
  final SavedQuote? savedQuote;
  final String source;
  final double screenWidth;
  final double textScaleFactor;

  const souscriptionSummary({
    super.key,
    this.simulationResult,
    this.savedQuote,
    required this.source,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final padding = screenWidth < 360 ? 16.0 : 20.0;
    final titleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final spacing = screenWidth < 360 ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: screenWidth < 360 ? 1.5 : 2,
        ),
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
            style: FontHelper.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: spacing),
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
    final labelWidth = screenWidth < 360 ? 70.0 : 80.0;
    final labelFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final valueFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final bottomPadding = screenWidth < 360 ? 10.0 : 12.0;
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: FontHelper.poppins(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: FontHelper.poppins(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
