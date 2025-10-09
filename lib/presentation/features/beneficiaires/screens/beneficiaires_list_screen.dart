import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/presentation/features/beneficiaires/viewmodels/beneficiaire_viewmodel.dart';
import 'package:saarflex_app/data/models/beneficiaire_model.dart';
import 'beneficiaire_form_screen.dart';

class BeneficiairesListScreen extends StatefulWidget {
  final String? contratId;
  final String? simulationId;
  final String? productName;

  const BeneficiairesListScreen({
    super.key,
    this.contratId,
    this.simulationId,
    this.productName,
  });

  @override
  State<BeneficiairesListScreen> createState() =>
      _BeneficiairesListScreenState();
}

class _BeneficiairesListScreenState extends State<BeneficiairesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BeneficiaireViewModel>();

      if (widget.contratId != null) {
        provider.initializeForContrat(widget.contratId!);
      } else if (widget.simulationId != null) {
        provider.initializeForSimulation(widget.simulationId!);
      }

      provider.loadBeneficiaires();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bénéficiaires',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<BeneficiaireViewModel>(
            builder: (context, provider, child) {
              if (provider.canAddBeneficiaire) {
                return IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: () => _showAddBeneficiaireDialog(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<BeneficiaireViewModel>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (provider.hasError) {
            return _buildErrorState(provider);
          }

          if (provider.beneficiaires.isEmpty) {
            return _buildEmptyState();
          }

          return _buildBeneficiairesList(provider);
        },
      ),
      floatingActionButton: Consumer<BeneficiaireViewModel>(
        builder: (context, provider, child) {
          if (!provider.canAddBeneficiaire) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () => _showAddBeneficiaireDialog(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BeneficiaireViewModel provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.loadBeneficiaires();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun bénéficiaire',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des bénéficiaires pour ce produit d\'assurance vie',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddBeneficiaireDialog(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Ajouter un bénéficiaire',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiairesList(BeneficiaireViewModel provider) {
    return Column(
      children: [
        _buildHeader(provider),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.beneficiaires.length,
            itemBuilder: (context, index) {
              final beneficiaire = provider.beneficiaires[index];
              return _buildBeneficiaireCard(beneficiaire, index, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BeneficiaireViewModel provider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.beneficiairesCount} bénéficiaire${provider.beneficiairesCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Maximum 3 bénéficiaires autorisés',
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

  Widget _buildBeneficiaireCard(
    Beneficiaire beneficiaire,
    int index,
    BeneficiaireViewModel provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Ordre ${beneficiaire.ordre}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(value, index, provider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(Icons.more_vert, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              beneficiaire.nomComplet,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              beneficiaire.lienSouscripteur,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBeneficiaireDialog() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BeneficiaireFormScreen(
              contratId: widget.contratId,
              simulationId: widget.simulationId,
            ),
          ),
        )
        .then((result) {
          if (result == true) {
            // Rafraîchir la liste si un bénéficiaire a été ajouté
            final provider = context.read<BeneficiaireViewModel>();
            provider.loadBeneficiaires();
          }
        });
  }

  void _showEditBeneficiaireDialog(int index) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BeneficiaireFormScreen(
              contratId: widget.contratId,
              simulationId: widget.simulationId,
              isEditing: true,
              editingIndex: index,
            ),
          ),
        )
        .then((result) {
          if (result == true) {
            // Rafraîchir la liste si un bénéficiaire a été modifié
            final provider = context.read<BeneficiaireViewModel>();
            provider.loadBeneficiaires();
          }
        });
  }

  void _handleMenuAction(
    String action,
    int index,
    BeneficiaireViewModel provider,
  ) {
    switch (action) {
      case 'edit':
        _showEditBeneficiaireDialog(index);
        break;
      case 'delete':
        _showDeleteConfirmation(index, provider);
        break;
    }
  }

  void _showDeleteConfirmation(int index, BeneficiaireViewModel provider) {
    final beneficiaire = provider.beneficiaires[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le bénéficiaire',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${beneficiaire.nomComplet} ?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.removeBeneficiaire(index);
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
