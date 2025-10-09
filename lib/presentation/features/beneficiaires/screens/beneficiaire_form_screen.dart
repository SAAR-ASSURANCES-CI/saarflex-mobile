import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/presentation/features/beneficiaires/viewmodels/beneficiaire_viewmodel.dart';

class BeneficiaireFormScreen extends StatefulWidget {
  final String? contratId;
  final String? simulationId;
  final bool isEditing;
  final int? editingIndex;

  const BeneficiaireFormScreen({
    super.key,
    this.contratId,
    this.simulationId,
    this.isEditing = false,
    this.editingIndex,
  });

  @override
  State<BeneficiaireFormScreen> createState() => _BeneficiaireFormScreenState();
}

class _BeneficiaireFormScreenState extends State<BeneficiaireFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCompletController = TextEditingController();
  final _lienSouscripteurController = TextEditingController();

  int _selectedOrdre = 1;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BeneficiaireViewModel>();

      if (widget.contratId != null) {
        provider.initializeForContrat(widget.contratId!);
      } else if (widget.simulationId != null) {
        provider.initializeForSimulation(widget.simulationId!);
      }

      // Si on est en mode édition, pré-remplir les champs
      if (widget.isEditing && widget.editingIndex != null) {
        final beneficiaire = provider.beneficiaires[widget.editingIndex!];
        _nomCompletController.text = beneficiaire.nomComplet;
        _lienSouscripteurController.text = beneficiaire.lienSouscripteur;
        _selectedOrdre = beneficiaire.ordre;
      } else {
        // Sinon, utiliser le prochain ordre disponible
        _selectedOrdre = provider.nextAvailableOrdre;
      }

      _isInitialized = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nomCompletController.dispose();
    _lienSouscripteurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Modifier le bénéficiaire'
              : 'Ajouter un bénéficiaire',
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
          if (!_isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 32),
                  _buildActionButtons(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du bénéficiaire',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Renseignez les informations du bénéficiaire. Vous pouvez ajouter jusqu\'à 3 bénéficiaires.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildNomCompletField(),
        const SizedBox(height: 20),
        _buildLienSouscripteurField(),
        const SizedBox(height: 20),
        _buildOrdreField(),
      ],
    );
  }

  Widget _buildNomCompletField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom complet *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nomCompletController,
          decoration: InputDecoration(
            hintText: 'Ex: Marie Dupont',
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
              return 'Le nom complet est obligatoire';
            }
            if (value.length > 255) {
              return 'Le nom ne peut pas dépasser 255 caractères';
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
        Text(
          'Lien avec le souscripteur *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
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

  Widget _buildOrdreField() {
    return Consumer<BeneficiaireViewModel>(
      builder: (context, provider, child) {
        final availableOrdres = provider.availableOrdres;

        // S'assurer qu'il n'y a pas de doublons
        final uniqueOrdres = availableOrdres.toSet().toList()..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordre de priorité *',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: uniqueOrdres.contains(_selectedOrdre)
                      ? _selectedOrdre
                      : uniqueOrdres.first,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  items: uniqueOrdres.map((ordre) {
                    return DropdownMenuItem<int>(
                      value: ordre,
                      child: Text(
                        '${_getOrdreLabel(ordre)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedOrdre = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'L\'ordre détermine la priorité en cas de décès (1er = priorité la plus élevée)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getOrdreLabel(int ordre) {
    switch (ordre) {
      case 1:
        return '1er bénéficiaire (priorité la plus élevée)';
      case 2:
        return '2ème bénéficiaire';
      case 3:
        return '3ème bénéficiaire';
      default:
        return 'Ordre $ordre';
    }
  }

  Widget _buildActionButtons(BeneficiaireViewModel provider) {
    return Column(
      children: [
        if (provider.hasError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: provider.isSaving ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: provider.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'Modifier' : 'Ajouter',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<BeneficiaireViewModel>();

    if (widget.isEditing && widget.editingIndex != null) {
      provider.updateBeneficiaire(
        widget.editingIndex!,
        nomComplet: _nomCompletController.text.trim(),
        lienSouscripteur: _lienSouscripteurController.text.trim(),
        ordre: _selectedOrdre,
      );
    } else {
      provider.addBeneficiaire(
        nomComplet: _nomCompletController.text.trim(),
        lienSouscripteur: _lienSouscripteurController.text.trim(),
        ordre: _selectedOrdre,
      );
    }

    if (!provider.hasError) {
      Navigator.of(context).pop(true);
    }
  }
}
