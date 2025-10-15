import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_save_confirmation_dialog.dart';
import 'package:saarflex_app/presentation/features/contracts/screens/contracts_screen.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';

class ResultSaveSection extends StatefulWidget {
  final SimulationResponse resultat;
  final SimulationResultViewModel viewModel;

  const ResultSaveSection({
    super.key,
    required this.resultat,
    required this.viewModel,
  });

  @override
  State<ResultSaveSection> createState() => _ResultSaveSectionState();
}

class _ResultSaveSectionState extends State<ResultSaveSection> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Getters publics pour accéder aux contrôleurs
  TextEditingController get nomController => _nomController;
  TextEditingController get notesController => _notesController;

  @override
  void dispose() {
    _nomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resultat.statut == StatutDevis.sauvegarde) {
      return _buildAlreadySavedCard();
    }

    return _buildSaveForm();
  }

  /// Widget pour afficher que le devis est déjà sauvegardé
  Widget _buildAlreadySavedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ce devis a déjà été sauvegardé dans vos contrats',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour le formulaire de sauvegarde
  Widget _buildSaveForm() {
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
          Text(
            'Sauvegarder ce devis',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Message d'avertissement si simulation pour une autre personne
          if (!widget.resultat.assureEstSouscripteur &&
              widget.resultat.informationsAssure != null) ...[
            _buildAssureWarning(),
            const SizedBox(height: 16),
          ],

          _buildNomField(),
          const SizedBox(height: 16),
          _buildNotesField(),
          if (widget.viewModel.hasValidationErrors) ...[
            const SizedBox(height: 12),
            _buildValidationErrors(),
          ],
        ],
      ),
    );
  }

  /// Champ pour le nom du devis
  Widget _buildNomField() {
    final hasError =
        widget.viewModel.getValidationError('nom_personnalise') != null;

    return TextFormField(
      controller: _nomController,
      onChanged: (value) {
        // Validation en temps réel
        if (value.trim().isEmpty) {
          widget.viewModel.setValidationError(
            'nom_personnalise',
            'Le nom du devis est obligatoire',
          );
        } else {
          widget.viewModel.clearValidationError('nom_personnalise');
        }
      },
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: 'Nom du devis ',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: '*',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        hintText: 'Ex: Devis voiture familiale',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.primary,
          ),
        ),
        errorText: widget.viewModel.getValidationError('nom_personnalise'),
      ),
    );
  }

  /// Champ pour les notes
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes personnelles (optionnel)',
        hintText: 'Ajoutez vos commentaires...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  /// Widget pour afficher les erreurs de validation
  Widget _buildValidationErrors() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.viewModel.validationErrors.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${entry.value}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Widget d'avertissement pour les simulations pour une autre personne
  Widget _buildAssureWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vous simulez pour une autre personne. Vérifiez les informations de l\'assuré ci-dessus avant de sauvegarder.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Méthode pour déclencher la sauvegarde
  void triggerSave() {
    // Vérifier que le nom du devis est renseigné
    final nomDevis = _nomController.text.trim();

    if (nomDevis.isEmpty) {
      // Définir l'erreur de validation
      widget.viewModel.setValidationError(
        'nom_personnalise',
        'Le nom du devis est obligatoire',
      );
      return; // Empêcher l'ouverture du popup
    }

    // Ouvrir le popup seulement si le nom est renseigné
    ResultSaveConfirmationDialog.show(
      context: context,
      nomDevis: nomDevis,
      notes: _notesController.text.trim(),
      resultat: widget.resultat,
      viewModel: widget.viewModel,
      onNewSimulation: () {
        // Redirection vers nouvelle simulation
        Navigator.pushReplacementNamed(context, '/simulation');
      },
      onViewQuotes: () {
        // Navigation vers contrats
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ContractsScreen(initialTab: 0),
          ),
        );
      },
    );
  }
}
