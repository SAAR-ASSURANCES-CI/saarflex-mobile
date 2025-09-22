import '../models/simulation_model.dart';
import '../models/product_model.dart';

/// Utilitaire pour détecter si un produit nécessite des bénéficiaires
class BeneficiairesDetector {
  /// Détecte si un produit nécessite des bénéficiaires basé sur la simulation
  static bool requiresBeneficiaires(
    Product product,
    SimulationResponse simulation,
  ) {
    // 1. Vérifier d'abord le champ necessiteBeneficiaires du produit
    if (product.necessiteBeneficiaires) return true;

    // 2. Pour les produits vie, considérer qu'ils nécessitent des bénéficiaires par défaut
    if (product.type == ProductType.vie) return true;

    // 3. Vérifier si la simulation a déjà des bénéficiaires (indique que c'est requis)
    if (simulation.beneficiaires.isNotEmpty) return true;

    // 4. Vérifier le type de produit dans la simulation
    if (simulation.typeProduit.toLowerCase() == 'vie') return true;

    return false;
  }

  /// Détecte si un produit nécessite des bénéficiaires basé sur le nom du produit
  static bool requiresBeneficiairesByName(String productName) {
    final name = productName.toLowerCase();

    // Mots-clés qui indiquent un produit d'assurance vie
    final vieKeywords = [
      'vie',
      'décès',
      'capital',
      'épargne',
      'retraite',
      'nansou', // Spécifique à votre produit
    ];

    return vieKeywords.any((keyword) => name.contains(keyword));
  }

  /// Détecte si un produit nécessite des bénéficiaires basé sur le type de produit
  static bool requiresBeneficiairesByType(String productType) {
    return productType.toLowerCase() == 'vie';
  }

  /// Méthode principale de détection
  static bool shouldShowBeneficiairesSection({
    required Product product,
    required SimulationResponse simulation,
  }) {
    // Règle principale : Si max_beneficiaires > 0, afficher la section
    if (product.maxBeneficiaires > 0) return true;

    // Fallback : Ancienne logique pour compatibilité
    // if (product.hasBeneficiaires) return true; // Supprimé car hasBeneficiaires n'existe plus
    if (product.necessiteBeneficiaires) return true;
    if (product.type == ProductType.vie) return true;
    if (simulation.typeProduit.toLowerCase() == 'vie') return true;
    if (requiresBeneficiairesByName(product.nom)) return true;
    if (requiresBeneficiairesByName(simulation.nomProduit)) return true;
    if (simulation.beneficiaires.isNotEmpty) return true;

    return false;
  }
}
