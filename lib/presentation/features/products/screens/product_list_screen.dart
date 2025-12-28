import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/presentation/features/products/viewmodels/product_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_list_app_bar.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/latest_products_section.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/all_products_list.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_list_loading_state.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_list_error_state.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_list_empty_state.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product>? _cachedLatestProducts;
  List<Product>? _cachedAllProducts;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productProvider, child) {
        _updateCache(productProvider);

        return Scaffold(
          backgroundColor: const Color(0xFFE8F4F8),
          appBar: const ProductListAppBar(),
          body: _buildBody(productProvider),
        );
      },
    );
  }

  void _updateCache(ProductViewModel productProvider) {
    final allProducts = productProvider.allProducts;
    if (_cachedAllProducts != allProducts) {
      _cachedAllProducts = allProducts;

      final sortedProducts = List<Product>.from(allProducts);
      sortedProducts.sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        if (a.createdAt != null) return -1;
        if (b.createdAt != null) return 1;
        return 0;
      });

      _cachedLatestProducts = sortedProducts.take(5).toList();
    }
  }

  Widget _buildBody(ProductViewModel productProvider) {
    if (productProvider.isLoading) {
      return const ProductListLoadingState();
    }

    if (productProvider.errorMessage != null) {
      return ProductListErrorState(
        errorMessage: productProvider.errorMessage!,
        productProvider: productProvider,
      );
    }

    final products = _cachedAllProducts ?? [];

    if (products.isEmpty) {
      return const ProductListEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LatestProductsSection(
          latestProducts: _cachedLatestProducts ?? [],
          onProductTap: _navigateToProductDetail,
        ),
        Expanded(
          child: AllProductsList(
            products: products,
            onProductTap: _navigateToProductDetail,
          ),
        ),
      ],
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id),
      ),
    );
  }
}
