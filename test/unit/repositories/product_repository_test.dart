import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/product_repository.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import '../../mocks/mocks.dart';

void main() {
  group('ProductRepository', () {
    late ProductRepository repository;
    late MockProductService mockProductService;

    setUp(() {
      mockProductService = MockProductService();
      repository = ProductRepository(productService: mockProductService);
    });

    group('getAllProducts', () {
      test('appelle ProductService.getAllProducts et retourne la liste', () async {
        final expectedProducts = [
          Product(
            id: '1',
            nom: 'Product 1',
            description: 'Description 1',
            type: ProductType.vie,
          ),
        ];

        when(mockProductService.getAllProducts())
            .thenAnswer((_) async => expectedProducts);

        final result = await repository.getAllProducts();

        expect(result, equals(expectedProducts));
        expect(result.length, 1);
        verify(mockProductService.getAllProducts()).called(1);
      });

      test('propage les erreurs de ProductService', () async {
        when(mockProductService.getAllProducts())
            .thenThrow(ApiException('Erreur serveur', 500));

        expect(
          () => repository.getAllProducts(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getProductById', () {
      test('appelle ProductService.getProductById avec le bon id', () async {
        final expectedProduct = Product(
          id: '1',
          nom: 'Product 1',
          description: 'Description 1',
          type: ProductType.vie,
        );

        when(mockProductService.getProductById('1'))
            .thenAnswer((_) async => expectedProduct);

        final result = await repository.getProductById('1');

        expect(result, equals(expectedProduct));
        expect(result?.id, '1');
        verify(mockProductService.getProductById('1')).called(1);
      });

      test('retourne null si produit non trouvé', () async {
        when(mockProductService.getProductById('invalid'))
            .thenAnswer((_) async => null);

        final result = await repository.getProductById('invalid');

        expect(result, isNull);
      });

      test('propage les erreurs de ProductService', () async {
        when(mockProductService.getProductById('1'))
            .thenThrow(ApiException('Produit non trouvé', 404));

        expect(
          () => repository.getProductById('1'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('searchProducts', () {
      test('appelle ProductService.searchProducts avec la bonne query', () async {
        final expectedProducts = [
          Product(
            id: '1',
            nom: 'Test Product',
            description: 'Description',
            type: ProductType.vie,
          ),
        ];

        when(mockProductService.searchProducts('test'))
            .thenAnswer((_) async => expectedProducts);

        final result = await repository.searchProducts('test');

        expect(result, equals(expectedProducts));
        verify(mockProductService.searchProducts('test')).called(1);
      });

      test('retourne liste vide si aucun résultat', () async {
        when(mockProductService.searchProducts('nonexistent'))
            .thenAnswer((_) async => <Product>[]);

        final result = await repository.searchProducts('nonexistent');

        expect(result, isEmpty);
      });
    });

    group('filterProductsByType', () {
      test('appelle ProductService.getProductsByType avec le bon type', () async {
        final expectedProducts = [
          Product(
            id: '1',
            nom: 'Vie Product',
            description: 'Description',
            type: ProductType.vie,
          ),
        ];

        when(mockProductService.getProductsByType(ProductType.vie))
            .thenAnswer((_) async => expectedProducts);

        final result = await repository.filterProductsByType(ProductType.vie);

        expect(result, equals(expectedProducts));
        verify(mockProductService.getProductsByType(ProductType.vie)).called(1);
      });
    });

    group('filterProducts', () {
      test('appelle ProductService.filterProducts avec les bons paramètres', () async {
        final expectedProducts = [
          Product(
            id: '1',
            nom: 'Product',
            description: 'Description',
            type: ProductType.vie,
          ),
        ];

        when(mockProductService.filterProducts(
          type: ProductType.vie,
          searchQuery: 'test',
        )).thenAnswer((_) async => expectedProducts);

        final result = await repository.filterProducts(
          type: ProductType.vie,
          searchQuery: 'test',
        );

        expect(result, equals(expectedProducts));
        verify(mockProductService.filterProducts(
          type: ProductType.vie,
          searchQuery: 'test',
        )).called(1);
      });

      test('passe null pour type et searchQuery si non fournis', () async {
        when(mockProductService.filterProducts(
          type: null,
          searchQuery: null,
        )).thenAnswer((_) async => <Product>[]);

        await repository.filterProducts();

        verify(mockProductService.filterProducts(
          type: null,
          searchQuery: null,
        )).called(1);
      });
    });

    group('getProductCountByType', () {
      test('appelle ProductService.getProductCountByType', () async {
        final expectedCount = {
          ProductType.vie: 5,
          ProductType.nonVie: 3,
        };

        when(mockProductService.getProductCountByType())
            .thenAnswer((_) async => expectedCount);

        final result = await repository.getProductCountByType();

        expect(result, equals(expectedCount));
        expect(result[ProductType.vie], 5);
        verify(mockProductService.getProductCountByType()).called(1);
      });
    });

    group('productExists', () {
      test('retourne true si produit existe', () async {
        when(mockProductService.productExists('1'))
            .thenAnswer((_) async => true);

        final result = await repository.productExists('1');

        expect(result, true);
        verify(mockProductService.productExists('1')).called(1);
      });

      test('retourne false si produit n\'existe pas', () async {
        when(mockProductService.productExists('invalid'))
            .thenAnswer((_) async => false);

        final result = await repository.productExists('invalid');

        expect(result, false);
      });
    });
  });
}
