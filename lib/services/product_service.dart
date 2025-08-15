import '../models/product_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  static final List<Product> _staticProducts = [
    Product(
      id: 'vie_1',
      nom: 'Assurance Vie Épargne',
      type: ProductType.vie,
      description: 'Une solution d\'épargne flexible qui vous permet de constituer un capital tout en bénéficiant d\'une protection vie. Idéale pour préparer votre retraite ou transmettre un patrimoine à vos proches.',
    ),
    Product(
      id: 'vie_2', 
      nom: 'Assurance Décès',
      type: ProductType.vie,
      description: 'Protégez vos proches en cas de décès avec une couverture adaptée à vos besoins. Capital garanti versé aux bénéficiaires pour maintenir leur niveau de vie et honorer vos engagements financiers.',
    ),
    Product(
      id: 'vie_3',
      nom: 'Assurance Vie Universelle',
      type: ProductType.vie,
      description: 'Combinez protection et investissement avec notre assurance vie universelle. Flexibilité des primes, choix d\'investissement et protection vie modulable selon l\'évolution de vos besoins.',
    ),
    Product(
      id: 'vie_4',
      nom: 'Assurance Invalidité',
      type: ProductType.vie,
      description: 'Préservez vos revenus en cas d\'invalidité temporaire ou permanente. Compensation financière pour maintenir votre niveau de vie et celui de votre famille face aux aléas de la vie.',
    ),

    Product(
      id: 'non_vie_1',
      nom: 'Assurance Auto',
      type: ProductType.nonVie,
      description: 'Protection complète pour votre véhicule avec des garanties tous risques, responsabilité civile, vol, incendie et assistance 24h/24. Tarifs préférentiels pour les bons conducteurs.',
    ),
    Product(
      id: 'non_vie_2',
      nom: 'Assurance Habitation',
      type: ProductType.nonVie,  
      description: 'Protégez votre logement et vos biens contre les risques d\'incendie, vol, dégâts des eaux et catastrophes naturelles. Couverture étendue pour votre mobilier et responsabilité civile vie privée.',
    ),
    Product(
      id: 'non_vie_3',
      nom: 'Assurance Voyage',
      type: ProductType.nonVie,
      description: 'Voyagez l\'esprit tranquille avec notre assurance voyage complète : assistance médicale, rapatriement, annulation, retard de vol et protection de vos bagages dans le monde entier.',
    ),
    Product(
      id: 'non_vie_4',
      nom: 'Assurance Entreprise',
      type: ProductType.nonVie,
      description: 'Solution globale pour protéger votre activité professionnelle : responsabilité civile professionnelle, protection des locaux, du matériel et couverture contre les pertes d\'exploitation.',
    ),
  ];

  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_staticProducts);
  }

  Future<List<Product>> getProductsByType(ProductType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _staticProducts.where((product) => product.type == type).toList();
  }

  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _staticProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (query.isEmpty) return getAllProducts();
    
    final lowerQuery = query.toLowerCase();
    return _staticProducts.where((product) {
      return product.nom.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.typeLabel.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Product>> filterProducts({
    ProductType? type,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<Product> filteredProducts = List.from(_staticProducts);
    
    if (type != null) {
      filteredProducts = filteredProducts.where((product) => product.type == type).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      filteredProducts = filteredProducts.where((product) {
        return product.nom.toLowerCase().contains(lowerQuery) ||
               product.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    
    return filteredProducts;
  }

  Map<ProductType, int> getProductCountByType() {
    final Map<ProductType, int> count = {};
    for (ProductType type in ProductType.values) {
      count[type] = _staticProducts.where((product) => product.type == type).length;
    }
    return count;
  }

  bool productExists(String id) {
    return _staticProducts.any((product) => product.id == id);
  }

  Future<List<Product>> getFeaturedProducts({int limit = 3}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _staticProducts.take(limit).toList();
  }
}