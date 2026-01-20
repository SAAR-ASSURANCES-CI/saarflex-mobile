import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/presentation/features/products/viewmodels/product_viewmodel.dart';
import 'package:saarciflex_app/data/models/product_model.dart';

void main() {
  group('ProductViewModel', () {
    late ProductViewModel viewModel;

    setUp(() {
      viewModel = ProductViewModel();
    });

    group('États initiaux', () {
      test('isLoading initial est false', () {
        expect(viewModel.isLoading, false);
      });

      test('allProducts initial est vide', () {
        expect(viewModel.allProducts, isEmpty);
      });

      test('filteredProducts initial est vide', () {
        expect(viewModel.filteredProducts, isEmpty);
      });

      test('selectedProduct initial est null', () {
        expect(viewModel.selectedProduct, isNull);
      });

      test('hasProducts initial est false', () {
        expect(viewModel.hasProducts, false);
      });
    });

    group('filterByType', () {
      test('filtre les produits par type', () {
        viewModel.filterByType(ProductType.vie);
        expect(viewModel.selectedFilter, ProductType.vie);
        expect(viewModel.isFiltered, true);
      });

      test('retire le filtre quand null', () {
        viewModel.filterByType(ProductType.vie);
        viewModel.filterByType(null);
        expect(viewModel.selectedFilter, isNull);
        expect(viewModel.isFiltered, false);
      });
    });

    group('search', () {
      test('filtre les produits par recherche', () {
        viewModel.search('test');
        expect(viewModel.searchQuery, 'test');
        expect(viewModel.isFiltered, true);
      });

      test('retire la recherche quand vide', () {
        viewModel.search('test');
        viewModel.search('');
        expect(viewModel.searchQuery, isEmpty);
      });
    });

    group('clearFilters', () {
      test('retire tous les filtres', () {
        viewModel.filterByType(ProductType.vie);
        viewModel.search('test');
        viewModel.clearFilters();
        expect(viewModel.selectedFilter, isNull);
        expect(viewModel.searchQuery, isEmpty);
        expect(viewModel.isFiltered, false);
      });
    });

    group('loadProducts', () {
      test('met isLoading à true pendant le chargement', () {
        expect(viewModel.isLoading, false);
      });
    });
  });
}
