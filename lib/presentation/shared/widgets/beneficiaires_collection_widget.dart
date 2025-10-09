import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

class BeneficiairesCollectionWidget extends StatefulWidget {
  final int maxBeneficiaires;
  final String productName;

  const BeneficiairesCollectionWidget({
    super.key,
    required this.maxBeneficiaires,
    required this.productName,
  });

  @override
  State<BeneficiairesCollectionWidget> createState() =>
      _BeneficiairesCollectionWidgetState();
}

class _BeneficiairesCollectionWidgetState
    extends State<BeneficiairesCollectionWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomCompletController = TextEditingController();
  final _lienSouscripteurController = TextEditingController();
  bool _isEditing = false;
  int? _editingIndex;

  @override
  void dispose() {
    _nomCompletController.dispose();
    _lienSouscripteurController.dispose();
    super.dispose();
  }

  // Validation des bénéficiaires requis
  bool _areBeneficiairesValid(SimulationViewModel provider) {
    final beneficiaires = provider.beneficiaires;
    return beneficiaires.length == widget.maxBeneficiaires;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationViewModel>(
      builder: (context, provider, child) {
        final beneficiaires = provider.beneficiaires;
        final isValid = _areBeneficiairesValid(provider);

        return Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              if (provider.beneficiaires.isEmpty)
                _buildEmptyState()
              else
                _buildBeneficiairesList(provider),
              const SizedBox(height: 20),
              if (provider.beneficiaires.length < widget.maxBeneficiaires)
                _buildAddButton(provider),

              // Message d'alerte si les bénéficiaires ne sont pas complets
              if (!isValid && beneficiaires.isNotEmpty)
                _buildValidationMessage(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bénéficiaires ',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Ajoutez ${widget.maxBeneficiaires} bénéficiaire(s) pour ${widget.productName}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48,
            color: AppColors.textSecondary,
          ),
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
            'Cliquez sur "Ajouter un bénéficiaire" pour commencer',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiairesList(SimulationViewModel provider) {
    return Column(
      children: provider.beneficiaires.asMap().entries.map((entry) {
        final index = entry.key;
        final beneficiaire = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beneficiaire['nom_complet'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      beneficiaire['lien_souscripteur'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _editBeneficiaire(index, beneficiaire),
                    icon: Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeBeneficiaire(index),
                    icon: Icon(
                      Icons.delete_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddButton(SimulationViewModel provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showBeneficiaireForm(),
        icon: Icon(Icons.add_rounded, color: AppColors.white, size: 20),
        label: Text(
          'Ajouter un bénéficiaire',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vous devez ajouter ${widget.maxBeneficiaires} bénéficiaire(s) pour ce produit avant de pouvoir simuler votre devis.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBeneficiaireForm() {
    _resetForm();
    _isEditing = false;
    _editingIndex = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBeneficiaireForm(),
    );
  }

  Widget _buildBeneficiaireForm() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing
                          ? 'Modifier le bénéficiaire'
                          : 'Nouveau bénéficiaire',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildNomCompletField(),
              const SizedBox(height: 20),
              _buildLienSouscripteurField(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNomCompletField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Nom complet ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: '*',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nomCompletController,
          decoration: InputDecoration(
            hintText: 'Ex: Marie Dupont',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom complet est obligatoire';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLienSouscripteurField() {
    final liensPredfinis = [
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Lien avec le souscripteur ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: '*',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: liensPredfinis.contains(_lienSouscripteurController.text)
                  ? _lienSouscripteurController.text
                  : 'Autre',
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              items: liensPredfinis.map((lien) {
                return DropdownMenuItem<String>(
                  value: lien,
                  child: Text(
                    lien,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    if (newValue == 'Autre') {
                      _lienSouscripteurController.clear();
                    } else {
                      _lienSouscripteurController.text = newValue;
                    }
                  });
                }
              },
            ),
          ),
        ),
        if (_lienSouscripteurController.text.isEmpty ||
            _lienSouscripteurController.text == 'Autre') ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _lienSouscripteurController,
            decoration: InputDecoration(
              hintText: 'Précisez le lien...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le lien avec le souscripteur est obligatoire';
              }
              if (value.length > 100) {
                return 'Le lien ne peut pas dépasser 100 caractères';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isEditing ? 'Modifier' : 'Ajouter',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SimulationViewModel>(context, listen: false);

      if (_isEditing && _editingIndex != null) {
        provider.updateBeneficiaire(
          _editingIndex!,
          nomComplet: _nomCompletController.text.trim(),
          lienSouscripteur: _lienSouscripteurController.text.trim(),
        );
      } else {
        provider.addBeneficiaire(
          nomComplet: _nomCompletController.text.trim(),
          lienSouscripteur: _lienSouscripteurController.text.trim(),
        );
      }

      _resetForm();
      Navigator.pop(context);
    }
  }

  void _editBeneficiaire(int index, Map<String, dynamic> beneficiaire) {
    _nomCompletController.text = beneficiaire['nom_complet'] ?? '';
    _lienSouscripteurController.text = beneficiaire['lien_souscripteur'] ?? '';
    _isEditing = true;
    _editingIndex = index;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBeneficiaireForm(),
    );
  }

  void _removeBeneficiaire(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le bénéficiaire',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce bénéficiaire ?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              Provider.of<SimulationViewModel>(
                context,
                listen: false,
              ).removeBeneficiaire(index);
              Navigator.pop(context);
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _nomCompletController.clear();
    _lienSouscripteurController.clear();
    _isEditing = false;
    _editingIndex = null;
  }
}
