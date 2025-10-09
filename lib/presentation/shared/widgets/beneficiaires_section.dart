import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/presentation/features/beneficiaires/viewmodels/beneficiaire_viewmodel.dart';
import 'package:saarflex_app/data/models/beneficiaire_model.dart';
import 'package:saarflex_app/presentation/features/beneficiaires/screens/simple_beneficiaire_form.dart';

class BeneficiairesSection extends StatelessWidget {
  final String? simulationId;
  final String? contratId;
  final String productName;
  final int maxBeneficiaires;
  final bool isRequired;

  const BeneficiairesSection({
    super.key,
    this.simulationId,
    this.contratId,
    required this.productName,
    this.maxBeneficiaires = 3,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BeneficiaireViewModel>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRequired && provider.beneficiaires.isEmpty
                  ? Colors.orange.shade300
                  : AppColors.border,
              width: isRequired && provider.beneficiaires.isEmpty ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, provider),
              if (provider.beneficiaires.isNotEmpty)
                _buildBeneficiairesList(provider)
              else
                _buildEmptyState(context),
              if (isRequired && provider.beneficiaires.isEmpty)
                _buildRequiredWarning(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BeneficiaireViewModel provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bénéficiaires',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${provider.beneficiairesCount}/3 bénéficiaire${provider.beneficiairesCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (provider.canAddBeneficiaire)
            TextButton.icon(
              onPressed: () => _navigateToBeneficiairesList(context),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: Text(
                'Ajouter',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBeneficiairesList(BeneficiaireViewModel provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...provider.beneficiaires.asMap().entries.map((entry) {
            final index = entry.key;
            final beneficiaire = entry.value;
            return _buildBeneficiaireItem(beneficiaire, index);
          }).toList(),
          if (provider.canAddBeneficiaire) _buildAddMoreButton(),
        ],
      ),
    );
  }

  Widget _buildBeneficiaireItem(Beneficiaire beneficiaire, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                beneficiaire.ordre.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiaire.nomComplet,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  beneficiaire.lienSouscripteur,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton.icon(
        onPressed: () {}, // Sera géré par le parent
        icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
        label: Text(
          'Ajouter un autre bénéficiaire',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Aucun bénéficiaire ajouté',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez des bénéficiaires pour ce produit d\'assurance vie',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToBeneficiairesList(context),
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: Text(
              'Ajouter des bénéficiaires',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_outlined, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ce produit nécessite au moins un bénéficiaire',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBeneficiairesList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SimpleBeneficiaireForm(
          contratId: contratId,
          simulationId: simulationId,
          maxBeneficiaires: maxBeneficiaires,
        ),
      ),
    );
  }
}
