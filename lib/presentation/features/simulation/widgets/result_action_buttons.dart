import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';

class ResultActionButtons extends StatelessWidget {
  final SimulationResponse resultat;
  final SimulationResultViewModel viewModel;
  final VoidCallback onSave;
  final VoidCallback onSubscribe;

  const ResultActionButtons({
    super.key,
    required this.resultat,
    required this.viewModel,
    required this.onSave,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_shouldShowSaveButton()) ...[
              _buildSaveButton(context),
              const SizedBox(height: 12),
            ],
            _buildSubscribeButton(),
          ],
        ),
      ),
    );
  }

  /// Détermine si le bouton de sauvegarde doit être affiché
  bool _shouldShowSaveButton() {
    return resultat.statut != StatutDevis.sauvegarde;
  }

  /// Bouton de sauvegarde
  Widget _buildSaveButton(BuildContext context) {
    final isAlreadySaved = resultat.statut == StatutDevis.sauvegarde;
    final isSaving = viewModel.isSaving;

    return ElevatedButton(
      onPressed: isSaving || isAlreadySaved ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: isAlreadySaved
            ? AppColors.textSecondary
            : AppColors.secondary,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isSaving
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                strokeWidth: 2,
              ),
            )
          : Text(
              isAlreadySaved ? 'Déjà sauvegardé' : 'Sauvegarder',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Bouton de souscription
  Widget _buildSubscribeButton() {
    return ElevatedButton(
      onPressed: onSubscribe,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Souscrire',
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
