import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/presentation/features/beneficiaires/viewmodels/beneficiaire_viewmodel.dart';
import 'package:saarflex_app/data/models/beneficiaire_model.dart';

class SimpleBeneficiaireForm extends StatefulWidget {
  final String? simulationId;
  final String? contratId;
  final int maxBeneficiaires;

  const SimpleBeneficiaireForm({
    super.key,
    this.simulationId,
    this.contratId,
    this.maxBeneficiaires = 3,
  });

  @override
  State<SimpleBeneficiaireForm> createState() => _SimpleBeneficiaireFormState();
}

class _SimpleBeneficiaireFormState extends State<SimpleBeneficiaireForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _lienController = TextEditingController();

  String _selectedLien = 'Épouse';

  final List<String> _liensPredfinis = [
    'Épouse',
    'Époux',
    'Fils',
    'Fille',
    'Mère',
    'Père',
    'Frère',
    'Sœur',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BeneficiaireViewModel>();

      // Définir la limite dynamique
      provider.setMaxBeneficiaires(widget.maxBeneficiaires);

      if (widget.contratId != null) {
        provider.initializeForContrat(widget.contratId!);
      } else if (widget.simulationId != null) {
        provider.initializeForSimulation(widget.simulationId!);
      }

      // Charger les bénéficiaires existants
      provider.loadBeneficiaires();
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _lienController.dispose();
    super.dispose();
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
      ),
      body: Consumer<BeneficiaireViewModel>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(provider),
                const SizedBox(height: 24),
                _buildBeneficiairesList(provider),
                const SizedBox(height: 24),
                if (provider.canAddBeneficiaire) ...[
                  _buildAddForm(provider),
                  const SizedBox(height: 24),
                ] else ...[
                  _buildLimitReachedMessage(provider),
                  const SizedBox(height: 24),
                ],
                _buildActionButtons(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BeneficiaireViewModel provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bénéficiaires de l\'assurance',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${provider.beneficiairesCount}/${provider.maxBeneficiaires} bénéficiaire${provider.beneficiairesCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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

  Widget _buildBeneficiairesList(BeneficiaireViewModel provider) {
    if (provider.beneficiaires.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bénéficiaires ajoutés',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.beneficiaires.asMap().entries.map((entry) {
          final index = entry.key;
          final beneficiaire = entry.value;
          return _buildBeneficiaireCard(beneficiaire, index, provider);
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Aucun bénéficiaire ajouté',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des bénéficiaires pour votre assurance vie',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                beneficiaire.ordre.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiaire.nomComplet,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
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
          IconButton(
            onPressed: () => _showDeleteConfirmation(index, provider),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm(BeneficiaireViewModel provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter un bénéficiaire',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildNomField(),
            const SizedBox(height: 16),
            _buildLienField(),
            const SizedBox(height: 20),
            _buildAddButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildNomField() {
    return TextFormField(
      controller: _nomController,
      decoration: InputDecoration(
        labelText: 'Nom complet *',
        hintText: 'Ex: Marie Dupont',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le nom complet est obligatoire';
        }
        return null;
      },
    );
  }

  Widget _buildLienField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lien avec le souscripteur *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLien,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.family_restroom),
          ),
          items: _liensPredfinis.map((lien) {
            return DropdownMenuItem<String>(value: lien, child: Text(lien));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLien = newValue;
                if (newValue == 'Autre') {
                  _lienController.clear();
                } else {
                  _lienController.text = newValue;
                }
              });
            }
          },
        ),
        if (_selectedLien == 'Autre') ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _lienController,
            decoration: InputDecoration(
              labelText: 'Précisez le lien',
              hintText: 'Ex: Cousin, Ami...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (_selectedLien == 'Autre' &&
                  (value == null || value.trim().isEmpty)) {
                return 'Veuillez préciser le lien';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLimitReachedMessage(BeneficiaireViewModel provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limite atteinte',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  'Vous avez atteint le nombre maximum de ${provider.maxBeneficiaires} bénéficiaires pour ce produit.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BeneficiaireViewModel provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _addBeneficiaire(provider),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Ajouter le bénéficiaire',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BeneficiaireViewModel provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: provider.beneficiaires.isNotEmpty
                ? () => _saveAndClose(provider)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Terminer',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addBeneficiaire(BeneficiaireViewModel provider) {
    if (!_formKey.currentState!.validate()) return;

    final lien = _selectedLien == 'Autre'
        ? _lienController.text.trim()
        : _selectedLien;

    // Utiliser l'ordre séquentiel automatique
    final ordre = provider.beneficiaires.isEmpty
        ? 1
        : provider.beneficiaires
                  .map((b) => b.ordre)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    provider.addBeneficiaire(
      nomComplet: _nomController.text.trim(),
      lienSouscripteur: lien,
      ordre: ordre,
    );

    if (!provider.hasError) {
      _clearForm();
    }
  }

  void _clearForm() {
    _nomController.clear();
    _lienController.clear();
    _selectedLien = 'Épouse';
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

  void _saveAndClose(BeneficiaireViewModel provider) async {
    final success = await provider.saveBeneficiaires();
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sauvegarde des bénéficiaires'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
