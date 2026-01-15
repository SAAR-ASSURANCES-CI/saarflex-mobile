import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_save_confirmation_dialog.dart';
import 'package:saarciflex_app/presentation/features/contracts/screens/contracts_screen.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';

class ResultSaveSection extends StatefulWidget {
  final SimulationResponse resultat;
  final SimulationResultViewModel viewModel;
  final double screenWidth;
  final double textScaleFactor;

  const ResultSaveSection({
    super.key,
    required this.resultat,
    required this.viewModel,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  State<ResultSaveSection> createState() => _ResultSaveSectionState();
}

class _ResultSaveSectionState extends State<ResultSaveSection> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

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

  Widget _buildAlreadySavedCard() {
    final padding = widget.screenWidth < 360 ? 16.0 : 20.0;
    final iconSize = widget.screenWidth < 360 ? 20.0 : 24.0;
    final fontSize = (14.0 / widget.textScaleFactor).clamp(12.0, 16.0);
    final spacing = widget.screenWidth < 360 ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: iconSize),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              'Ce devis a déjà été sauvegardé dans vos contrats',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveForm() {
    final padding = widget.screenWidth < 360 ? 16.0 : 20.0;
    final titleFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final spacing = widget.screenWidth < 360 ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
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
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: spacing),

          if (!widget.resultat.assureEstSouscripteur &&
              widget.resultat.informationsAssure != null) ...[
            _buildAssureWarning(),
            SizedBox(height: spacing),
          ],

          _buildNomField(),
          SizedBox(height: spacing),
          _buildNotesField(),
        
        ],
      ),
    );
  }

  Widget _buildNomField() {
    final hasError =
        widget.viewModel.getValidationError('nom_personnalise') != null;
    final fontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final horizontalPadding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final verticalPadding = widget.screenWidth < 360 ? 14.0 : 16.0;

    return TextFormField(
      controller: _nomController,
      style: GoogleFonts.poppins(fontSize: fontSize),
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: 'Nom du devis ',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: fontSize,
            ),
            children: [
              TextSpan(
                text: '*',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        hintText: 'Ex: Devis voiture familiale',
        hintStyle: GoogleFonts.poppins(fontSize: fontSize),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    final fontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final labelFontSize = (16.0 / widget.textScaleFactor).clamp(14.0, 18.0);
    final horizontalPadding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final verticalPadding = widget.screenWidth < 360 ? 14.0 : 16.0;

    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      style: GoogleFonts.poppins(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: 'Notes personnelles (optionnel)',
        labelStyle: GoogleFonts.poppins(fontSize: labelFontSize),
        hintText: 'Ajoutez vos commentaires...',
        hintStyle: GoogleFonts.poppins(fontSize: fontSize),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
      ),
    );
  }

  Widget _buildAssureWarning() {
    final padding = widget.screenWidth < 360 ? 12.0 : 16.0;
    final iconSize = widget.screenWidth < 360 ? 18.0 : 20.0;
    final fontSize = (13.0 / widget.textScaleFactor).clamp(11.0, 15.0);
    final spacing = widget.screenWidth < 360 ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: iconSize),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              'Vous simulez pour une autre personne. Vérifiez les informations de l\'assuré ci-dessus avant de sauvegarder.',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.warning,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void triggerSave() {

    final nomDevis = _nomController.text.trim();

    if (nomDevis.isEmpty) {

      widget.viewModel.setValidationError(
        'nom_personnalise',
        'Le nom du devis est obligatoire',
      );
      return; // Empêcher l'ouverture du popup
    }

    ResultSaveConfirmationDialog.show(
      context: context,
      nomDevis: nomDevis,
      notes: _notesController.text.trim(),
      resultat: widget.resultat,
      viewModel: widget.viewModel,
      onNewSimulation: () {

        Navigator.pushReplacementNamed(context, '/simulation');
      },
      onViewQuotes: () {

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
