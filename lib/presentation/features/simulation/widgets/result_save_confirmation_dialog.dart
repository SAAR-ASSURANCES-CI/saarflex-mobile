import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

class ResultSaveConfirmationDialog extends StatelessWidget {
  final String nomDevis;
  final String notes;
  final SimulationResponse resultat;
  final SimulationResultViewModel viewModel;
  final VoidCallback onNewSimulation;
  final VoidCallback onViewQuotes;

  const ResultSaveConfirmationDialog({
    super.key,
    required this.nomDevis,
    required this.notes,
    required this.resultat,
    required this.viewModel,
    required this.onNewSimulation,
    required this.onViewQuotes,
  });

  void _triggerImageUpload(BuildContext context, String devisId) {
    try {
      final simulationViewModel = context.read<SimulationViewModel>();
      if (simulationViewModel.hasTempImages) {
        simulationViewModel.uploadImagesAfterSave(devisId, null);
      }
    } catch (e) {

    }
  }

  void _clearTempImagesAfterSave(BuildContext context) {
    try {
      final simulationViewModel = context.read<SimulationViewModel>();
      simulationViewModel.clearTempImagesAfterSave();
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final padding = screenWidth < 360 ? 20.0 : screenWidth < 600 ? 24.0 : 32.0;
    final iconContainerSize = screenWidth < 360 ? 64.0 : screenWidth < 600 ? 72.0 : 80.0;
    final iconSize = screenWidth < 360 ? 32.0 : screenWidth < 600 ? 36.0 : 40.0;
    final closeIconSize = screenWidth < 360 ? 20.0 : 24.0;
    final titleFontSize = (24.0 / textScaleFactor).clamp(20.0, 28.0);
    final bodyFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final buttonFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final spacing1 = screenWidth < 360 ? 20.0 : 24.0;
    final spacing2 = screenWidth < 360 ? 10.0 : 12.0;
    final spacing3 = screenWidth < 360 ? 24.0 : 32.0;
    final buttonSpacing = screenWidth < 360 ? 10.0 : 12.0;
    final buttonPadding = screenWidth < 360 ? 14.0 : 16.0;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: closeIconSize,
                  ),
                ),
              ],
            ),

            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.save_rounded,
                color: AppColors.primary,
                size: iconSize,
              ),
            ),
            SizedBox(height: spacing1),

            Text(
              'Sauvegarder le devis',
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing2),

            Text(
              'Votre devis "$nomDevis" sera sauvegardé. Que souhaitez-vous faire ensuite ?',
              style: GoogleFonts.poppins(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing3),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {

                      final success = await viewModel.sauvegarderDevis(
                        devisId: resultat.id,
                        nomPersonnalise: nomDevis,
                        notes: notes.isEmpty ? null : notes,
                        context: context,
                      );

                      if (success) {

                        _triggerImageUpload(context, resultat.id);

                        _clearTempImagesAfterSave(context);
                        Navigator.pop(context);
                        onNewSimulation(); // Redirection vers nouvelle simulation
                      } else {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Impossible de sauvegarder le devis',
                              style: GoogleFonts.poppins(
                                fontSize: (14.0 / textScaleFactor).clamp(12.0, 16.0),
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Nouvelle simulation',
                      style: GoogleFonts.poppins(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: buttonSpacing),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {

                      final success = await viewModel.sauvegarderDevis(
                        devisId: resultat.id,
                        nomPersonnalise: nomDevis,
                        notes: notes.isEmpty ? null : notes,
                        context: context,
                      );

                      if (success) {

                        _triggerImageUpload(context, resultat.id);

                        _clearTempImagesAfterSave(context);
                        Navigator.pop(context);
                        onViewQuotes(); // Navigation vers contrats
                      } else {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Impossible de sauvegarder le devis',
                              style: GoogleFonts.poppins(
                                fontSize: (14.0 / textScaleFactor).clamp(12.0, 16.0),
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Voir mes devis',
                      style: GoogleFonts.poppins(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String nomDevis,
    required String notes,
    required SimulationResponse resultat,
    required SimulationResultViewModel viewModel,
    required VoidCallback onNewSimulation,
    required VoidCallback onViewQuotes,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ResultSaveConfirmationDialog(
          nomDevis: nomDevis,
          notes: notes,
          resultat: resultat,
          viewModel: viewModel,
          onNewSimulation: onNewSimulation,
          onViewQuotes: onViewQuotes,
        );
      },
    );
  }
}
