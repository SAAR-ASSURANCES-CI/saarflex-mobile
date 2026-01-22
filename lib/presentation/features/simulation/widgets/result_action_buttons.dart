import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';

class ResultActionButtons extends StatelessWidget {
  final SimulationResponse resultat;
  final SimulationResultViewModel viewModel;
  final VoidCallback onSave;
  final VoidCallback onSubscribe;
  final double screenWidth;
  final double textScaleFactor;

  const ResultActionButtons({
    super.key,
    required this.resultat,
    required this.viewModel,
    required this.onSave,
    required this.onSubscribe,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final padding = screenWidth < 360 ? 16.0 : screenWidth < 600 ? 20.0 : 24.0;
    final buttonSpacing = screenWidth < 360 ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
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
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_shouldShowSaveButton()) ...[
              _buildSaveButton(context),
              SizedBox(height: buttonSpacing),
            ],
            _buildSubscribeButton(),
          ],
        ),
      ),
    );
  }

  bool _shouldShowSaveButton() {
    return resultat.statut != StatutDevis.sauvegarde;
  }

  Widget _buildSaveButton(BuildContext context) {
    final isAlreadySaved = resultat.statut == StatutDevis.sauvegarde;
    final isSaving = viewModel.isSaving;
    final buttonHeight = screenWidth < 360 ? 48.0 : 50.0;
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;

    return ElevatedButton(
      onPressed: isSaving || isAlreadySaved ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: isAlreadySaved
            ? AppColors.textSecondary
            : AppColors.secondary,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isSaving
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                strokeWidth: 2,
              ),
            )
          : Text(
              isAlreadySaved ? 'Déjà sauvegardé' : 'Sauvegarder',
              style: FontHelper.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  Widget _buildSubscribeButton() {
    final buttonHeight = screenWidth < 360 ? 48.0 : 50.0;
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);

    return ElevatedButton(
      onPressed: onSubscribe,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Souscrire',
        style: FontHelper.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
