import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';

/// Gestionnaire d'erreurs spécialisé pour la simulation
class SimulationErrorHandler {
  /// Gère les erreurs de validation
  static void handleValidationError(BuildContext context, String error) {
    _showErrorSnackBar(
      context,
      'Erreur de validation',
      error,
      AppColors.warning,
    );
  }

  /// Gère les erreurs de simulation
  static void handleSimulationError(BuildContext context, String error) {
    _showErrorSnackBar(context, 'Erreur de simulation', error, AppColors.error);
  }

  /// Gère les erreurs de sauvegarde
  static void handleSaveError(BuildContext context, String error) {
    _showErrorSnackBar(context, 'Erreur de sauvegarde', error, AppColors.error);
  }

  /// Gère les erreurs de chargement
  static void handleLoadingError(BuildContext context, String error) {
    _showErrorSnackBar(context, 'Erreur de chargement', error, AppColors.error);
  }

  /// Convertit une erreur technique en message utilisateur
  static String getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Erreurs de réseau
    if (errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Problème de connexion. Vérifiez votre connexion internet.';
    }

    // Erreurs de timeout
    if (errorString.contains('timeout')) {
      return 'La requête a pris trop de temps. Veuillez réessayer.';
    }

    // Erreurs de serveur
    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Erreur du serveur. Veuillez réessayer plus tard.';
    }

    // Erreurs d'authentification
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }

    // Erreurs de validation
    if (errorString.contains('validation') || errorString.contains('400')) {
      return 'Données invalides. Vérifiez vos informations.';
    }

    // Erreur générique
    return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
  }

  /// Affiche un SnackBar d'erreur stylisé
  static void _showErrorSnackBar(
    BuildContext context,
    String title,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un SnackBar de succès
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un SnackBar d'information
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un dialogue d'erreur
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(
                buttonText ?? 'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
