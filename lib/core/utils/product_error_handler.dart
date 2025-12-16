import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';

class ProductErrorHandler {
  static String handleProductError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Problème de connexion réseau. Vérifiez votre connexion internet.';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Délai d\'attente dépassé. Veuillez réessayer.';
    }

    if (error.toString().contains('FormatException')) {
      return 'Erreur de format des données. Contactez le support.';
    }

    if (error.toString().contains('Unauthorized')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }

    if (error.toString().contains('NotFound')) {
      return 'Produit introuvable.';
    }

    if (error.toString().contains('ServerException')) {
      return 'Erreur du serveur. Veuillez réessayer plus tard.';
    }

    return 'Erreur inattendue: ${error.toString()}';
  }

  static String handleProductLoadError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Impossible de charger les produits. Vérifiez votre connexion.';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Chargement trop long. Veuillez réessayer.';
    }

    return handleProductError(error);
  }

  static String handleProductSearchError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Recherche impossible. Vérifiez votre connexion.';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Recherche trop lente. Veuillez réessayer.';
    }

    return handleProductError(error);
  }

  static String handleProductDetailError(dynamic error) {
    if (error.toString().contains('NotFound')) {
      return 'Détails du produit introuvables.';
    }

    if (error.toString().contains('SocketException')) {
      return 'Impossible de charger les détails. Vérifiez votre connexion.';
    }

    return handleProductError(error);
  }

  static String handleProductFilterError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Filtrage impossible. Vérifiez votre connexion.';
    }

    return handleProductError(error);
  }

  static void showProductErrorSnackBar(BuildContext context, dynamic error) {
    final message = handleProductError(error);
    ErrorHandler.showErrorSnackBar(context, message);
  }

  static void showProductLoadErrorSnackBar(
    BuildContext context,
    dynamic error,
  ) {
    final message = handleProductLoadError(error);
    ErrorHandler.showErrorSnackBar(context, message);
  }

  static void showProductSearchErrorSnackBar(
    BuildContext context,
    dynamic error,
  ) {
    final message = handleProductSearchError(error);
    ErrorHandler.showErrorSnackBar(context, message);
  }

  static void showProductDetailErrorSnackBar(
    BuildContext context,
    dynamic error,
  ) {
    final message = handleProductDetailError(error);
    ErrorHandler.showErrorSnackBar(context, message);
  }

  static void showProductFilterErrorSnackBar(
    BuildContext context,
    dynamic error,
  ) {
    final message = handleProductFilterError(error);
    ErrorHandler.showErrorSnackBar(context, message);
  }

  static void showProductSuccessSnackBar(BuildContext context, String message) {
    ErrorHandler.showSuccessSnackBar(context, message);
  }

  static void showProductInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Widget buildProductErrorWidget({
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryText ?? 'Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildProductEmptyWidget({
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun produit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
