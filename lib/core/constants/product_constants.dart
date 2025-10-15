import 'package:saarflex_app/data/models/product_model.dart';

class ProductConstants {
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minSearchLength = 2;
  static const int maxSearchLength = 50;
  static const int minProductNameLength = 3;
  static const int maxProductNameLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;

  static const Duration cacheValidity = Duration(hours: 1);
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const Duration refreshTimeout = Duration(seconds: 30);

  static const List<String> allowedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  static const Map<ProductType, String> productTypeLabels = {
    ProductType.vie: 'Assurance Vie',
    ProductType.nonVie: 'Assurance Non-Vie',
  };

  static const Map<ProductType, String> productTypeShortLabels = {
    ProductType.vie: 'Vie',
    ProductType.nonVie: 'Non-Vie',
  };

  static const Map<String, String> productStatusLabels = {
    'actif': 'Actif',
    'inactif': 'Inactif',
    'en_attente': 'En attente',
    'suspendu': 'Suspendu',
  };

  static const List<String> productFeatures = [
    'Produit actif',
    'Conditions disponibles',
    'Support des bénéficiaires',
    'Bénéficiaires requis',
    'Simulation disponible',
    'Souscription en ligne',
  ];

  static const Map<String, String> errorMessages = {
    'product_not_found': 'Produit introuvable',
    'product_inactive': 'Produit non disponible',
    'invalid_product_id': 'ID produit invalide',
    'search_too_short': 'Recherche trop courte (min 2 caractères)',
    'search_too_long': 'Recherche trop longue (max 50 caractères)',
    'name_too_short': 'Nom trop court (min 3 caractères)',
    'name_too_long': 'Nom trop long (max 100 caractères)',
    'description_too_short': 'Description trop courte (min 10 caractères)',
    'description_too_long': 'Description trop longue (max 500 caractères)',
    'network_error': 'Problème de connexion réseau',
    'timeout_error': 'Délai d\'attente dépassé',
    'server_error': 'Erreur du serveur',
    'unauthorized': 'Session expirée',
  };

  static const Map<String, String> successMessages = {
    'products_loaded': 'Produits chargés avec succès',
    'product_loaded': 'Produit chargé avec succès',
    'search_completed': 'Recherche terminée',
    'filter_applied': 'Filtre appliqué',
    'cache_cleared': 'Cache vidé',
  };

  static const Map<String, String> infoMessages = {
    'loading_products': 'Chargement des produits...',
    'searching_products': 'Recherche en cours...',
    'applying_filter': 'Application du filtre...',
    'refreshing_products': 'Actualisation des produits...',
    'no_products_found': 'Aucun produit trouvé',
    'no_products_match_filter': 'Aucun produit ne correspond au filtre',
  };
}
