import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

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

  /// Déclenche l'upload des images après sauvegarde
  void _triggerImageUpload(BuildContext context, String devisId) {
    try {
      final simulationViewModel = context.read<SimulationViewModel>();
      if (simulationViewModel.hasTempImages) {
        // Upload en arrière-plan sans context pour éviter l'erreur
        simulationViewModel.uploadImagesAfterSave(devisId, null);
      }
    } catch (e) {
      // SimulationViewModel non disponible, pas grave
    }
  }

  /// Nettoie les images temporaires après sauvegarde
  void _clearTempImagesAfterSave(BuildContext context) {
    try {
      final simulationViewModel = context.read<SimulationViewModel>();
      simulationViewModel.clearTempImagesAfterSave();
    } catch (e) {
      // SimulationViewModel non disponible, pas grave
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton fermer en haut à droite
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),
            // Icône de sauvegarde
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.save_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              'Sauvegarder le devis',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              'Votre devis "$nomDevis" sera sauvegardé. Que souhaitez-vous faire ensuite ?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // Sauvegarder avec le nom et les notes saisis
                      final success = await viewModel.sauvegarderDevis(
                        devisId: resultat.id,
                        nomPersonnalise: nomDevis,
                        notes: notes.isEmpty ? null : notes,
                        context: context,
                      );

                      if (success) {
                        // Déclencher l'upload des images après sauvegarde
                        _triggerImageUpload(context, resultat.id);
                        // Nettoyer les images temporaires après sauvegarde
                        _clearTempImagesAfterSave(context);
                        Navigator.pop(context);
                        onNewSimulation(); // Redirection vers nouvelle simulation
                      } else {
                        // Afficher l'erreur si échec
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Impossible de sauvegarder le devis'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Nouvelle simulation',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Sauvegarder avec le nom et les notes saisis
                      final success = await viewModel.sauvegarderDevis(
                        devisId: resultat.id,
                        nomPersonnalise: nomDevis,
                        notes: notes.isEmpty ? null : notes,
                        context: context,
                      );

                      if (success) {
                        // Déclencher l'upload des images après sauvegarde
                        _triggerImageUpload(context, resultat.id);
                        // Nettoyer les images temporaires après sauvegarde
                        _clearTempImagesAfterSave(context);
                        Navigator.pop(context);
                        onViewQuotes(); // Navigation vers contrats
                      } else {
                        // Afficher l'erreur si échec
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Impossible de sauvegarder le devis'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Voir mes devis',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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

  /// Affiche le dialog de confirmation
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
