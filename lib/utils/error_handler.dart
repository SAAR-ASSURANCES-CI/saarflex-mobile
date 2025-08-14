// lib/utils/error_handler.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class ErrorHandler {
  // Messages d'erreur pour l'authentification
  static const Map<String, String> _authErrors = {
    'email_not_found': 'Aucun compte trouvé',
    'invalid_password': 'Mot de passe incorrect',
    'user_disabled': 'Ce compte a été désactivé',
    'too_many_requests':
        'Trop de tentatives. Veuillez patienter quelques minutes',
    'email_already_exists': 'Un compte existe déjà avec cette adresse email',
    'weak_password': 'Le mot de passe est trop faible',
    'invalid_email': 'Format d\'email invalide',
    'network_error': 'Problème de connexion internet',
    'server_error': 'Erreur du serveur. Veuillez réessayer plus tard',
    'timeout': 'Délai d\'attente dépassé. Vérifiez votre connexion',
    'unauthorized': 'Session expirée. Veuillez vous reconnecter',
    'forbidden': 'Accès non autorisé',
    'not_found': 'Service non disponible',
    'validation_error': 'Données invalides',
    'unknown_error': 'Une erreur inattendue s\'est produite',
  };

  // Messages d'erreur pour le profil
  static const Map<String, String> _profileErrors = {
    'name_required': 'Le nom est obligatoire',
    'name_too_short': 'Le nom doit contenir au moins 2 caractères',
    'name_too_long': 'Le nom ne peut pas dépasser 50 caractères',
    'email_required': 'L\'email est obligatoire',
    'email_invalid': 'Format d\'email invalide (exemple: nom@domaine.com)',
    'email_exists': 'Cette adresse email est déjà utilisée',
    'phone_required': 'Le numéro de téléphone est obligatoire',
    'phone_invalid': 'Format de téléphone invalide',
    'phone_too_short': 'Le numéro doit contenir au moins 10 chiffres',
    'phone_exists': 'Ce numéro de téléphone est déjà utilisé',
    'password_required': 'Le mot de passe est obligatoire',
    'password_too_short': 'Le mot de passe doit contenir au moins 8 caractères',
    'password_missing_lowercase':
        'Le mot de passe doit contenir au moins une minuscule',
    'password_missing_uppercase':
        'Le mot de passe doit contenir au moins une majuscule',
    'password_missing_number':
        'Le mot de passe doit contenir au moins un chiffre',
    'password_missing_special':
        'Le mot de passe doit contenir un caractère spécial',
    'passwords_dont_match': 'Les mots de passe ne correspondent pas',
    'update_failed': 'Erreur lors de la mise à jour du profil',
    'no_changes': 'Aucune modification détectée',
  };

  // Messages d'erreur généraux
  static const Map<String, String> _generalErrors = {
    'connection_error': 'Problème de connexion. Vérifiez votre internet',
    'server_unavailable': 'Service temporairement indisponible',
    'invalid_data': 'Données invalides',
    'permission_denied': 'Permission refusée',
    'file_too_large': 'Le fichier est trop volumineux',
    'unsupported_format': 'Format de fichier non supporté',
  };

  /// Convertit une ApiException en message utilisateur compréhensible
  static String getAuthErrorMessage(ApiException exception) {
    final message = exception.message.toLowerCase();

    // Vérifier les mots-clés dans le message d'erreur
    if (message.contains('email') &&
        message.contains('not') &&
        message.contains('found')) {
      return _authErrors['email_not_found']!;
    }

    if (message.contains('password') && message.contains('incorrect')) {
      return _authErrors['invalid_password']!;
    }

    if (message.contains('email') &&
        message.contains('already') &&
        message.contains('exist')) {
      return _authErrors['email_already_exists']!;
    }

    if (message.contains('too many') || message.contains('rate limit')) {
      return _authErrors['too_many_requests']!;
    }

    if (message.contains('network') || message.contains('connection')) {
      return _authErrors['network_error']!;
    }

    if (message.contains('timeout')) {
      return _authErrors['timeout']!;
    }

    // Vérifier par code de statut
    switch (exception.statusCode) {
      case 401:
        return _authErrors['invalid_password']!;
      case 403:
        return _authErrors['forbidden']!;
      case 404:
        return _authErrors['email_not_found']!;
      case 409:
        return _authErrors['email_already_exists']!;
      case 422:
        return _authErrors['validation_error']!;
      case 429:
        return _authErrors['too_many_requests']!;
      case 500:
        return _authErrors['server_error']!;
      case 503:
        return _authErrors['server_error']!;
      default:
        return _authErrors['unknown_error']!;
    }
  }

  /// Convertit une ApiException en message pour la mise à jour de profil
  static String getProfileErrorMessage(ApiException exception) {
    final message = exception.message.toLowerCase();

    if (message.contains('email') && message.contains('already')) {
      return _profileErrors['email_exists']!;
    }

    if (message.contains('phone') && message.contains('already')) {
      return _profileErrors['phone_exists']!;
    }

    if (message.contains('validation')) {
      return _profileErrors['update_failed']!;
    }

    if (message.contains('connection') || message.contains('network')) {
      return _generalErrors['connection_error']!;
    }

    // Vérifier par code de statut
    switch (exception.statusCode) {
      case 409:
        return _profileErrors['email_exists']!;
      case 422:
        return _profileErrors['update_failed']!;
      case 500:
        return _generalErrors['server_unavailable']!;
      default:
        return _profileErrors['update_failed']!;
    }
  }

  /// Valide un email et retourne un message d'erreur si invalide
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return _profileErrors['email_required'];
    }

    final cleanEmail = email.trim();

    if (!cleanEmail.contains('@')) {
      return 'L\'email doit contenir le symbole @';
    }

    if (cleanEmail.startsWith('@') || cleanEmail.endsWith('@')) {
      return _profileErrors['email_invalid'];
    }

    final parts = cleanEmail.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      return _profileErrors['email_invalid'];
    }

    if (!parts[1].contains('.') ||
        parts[1].endsWith('.') ||
        parts[1].startsWith('.')) {
      return _profileErrors['email_invalid'];
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(cleanEmail)) {
      return _profileErrors['email_invalid'];
    }

    return null;
  }

  /// Valide un mot de passe et retourne les erreurs spécifiques
  static List<String> validatePassword(String? password) {
    List<String> errors = [];

    if (password == null || password.isEmpty) {
      errors.add(_profileErrors['password_required']!);
      return errors;
    }

    if (password.length < 8) {
      errors.add(_profileErrors['password_too_short']!);
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add(_profileErrors['password_missing_lowercase']!);
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add(_profileErrors['password_missing_uppercase']!);
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add(_profileErrors['password_missing_number']!);
    }

    if (!RegExp(r'[@$!%*?&]').hasMatch(password)) {
      errors.add(_profileErrors['password_missing_special']!);
    }

    return errors;
  }

  /// Valide un nom
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return _profileErrors['name_required'];
    }

    if (name.trim().length < 2) {
      return _profileErrors['name_too_short'];
    }

    if (name.trim().length > 50) {
      return _profileErrors['name_too_long'];
    }

    if (!RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(name)) {
      return 'Le nom doit contenir au moins une lettre';
    }

    return null;
  }

  /// Valide un numéro de téléphone
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return _profileErrors['phone_required'];
    }

    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    if (cleanPhone.length < 10) {
      return _profileErrors['phone_too_short'];
    }

    if (cleanPhone.length > 15) {
      return 'Le numéro ne doit pas dépasser 15 chiffres';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return 'Le numéro ne doit contenir que des chiffres';
    }

    return null;
  }

  /// Affiche un SnackBar d'erreur avec style cohérent
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un SnackBar de succès
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Affiche un SnackBar d'avertissement
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Construit un widget d'erreur réutilisable
  static Widget buildErrorContainer(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un widget d'erreur qui disparaît automatiquement après 5 secondes
  static Widget buildAutoDisappearingErrorContainer(
    String message,
    VoidCallback onDismiss,
  ) {
    return _AutoDismissErrorWidget(message: message, onDismiss: onDismiss);
  }

  /// Construit un widget de liste d'erreurs
  static Widget buildErrorList(List<String> errors) {
    final nonNullErrors = errors.whereType<String>().toList();
    if (nonNullErrors.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Corrections nécessaires :',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Text(
                '• $error',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CLASSE POUR GÉRER L'AUTO-DISPARITION DES ERREURS
class _AutoDismissErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _AutoDismissErrorWidget({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_AutoDismissErrorWidget> createState() =>
      _AutoDismissErrorWidgetState();
}

class _AutoDismissErrorWidgetState extends State<_AutoDismissErrorWidget> {
  bool isVisible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Créer le timer pour auto-supprimer après 5 secondes
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted && isVisible) {
        setState(() {
          isVisible = false;
        });
        // Attendre la fin de l'animation avant d'appeler onDismiss
        Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // IMPORTANT : Annuler le timer pour éviter l'erreur
    _timer?.cancel();
    super.dispose();
  }

  void _dismissManually() {
    if (mounted) {
      setState(() {
        isVisible = false;
      });
      Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onDismiss();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? null : 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: isVisible ? const EdgeInsets.all(16) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: isVisible
            ? Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Bouton pour fermer manuellement
                  IconButton(
                    onPressed: _dismissManually,
                    icon: Icon(Icons.close, color: AppColors.error, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
