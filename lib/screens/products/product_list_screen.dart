// lib/screens/products/product_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    
    // Charger les produits au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (timer) { // 2 secondes au lieu de 3
      if (!_userInteracting && _pageController.hasClients) {
        final products = context.read<ProductProvider>().allProducts;
        if (products.isNotEmpty) {
          _currentPage = (_currentPage + 1) % products.take(5).length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300), // Animation plus rapide : 300ms au lieu de 500ms
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _onUserInteraction() {
    setState(() {
      _userInteracting = true;
    });
    
    // Reprendre le scroll automatique après 5 secondes d'inactivité
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _userInteracting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: _buildBody(productProvider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary, // Rouge plus intense dans le header
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Produits d'assurance",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return _buildLoadingState();
    }

    if (productProvider.errorMessage != null) {
      return _buildErrorState(productProvider.errorMessage!, productProvider);
    }

    final products = productProvider.allProducts;
    
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section des derniers produits (horizontal)
        _buildLatestProductsSection(products),
        
        // Tous les produits (vertical)
        Expanded(
          child: _buildAllProductsList(products, productProvider),
        ),
      ],
    );
  }

  Widget _buildLatestProductsSection(List<Product> products) {
    // Prendre les 5 derniers produits (simulé par les 5 premiers pour la démo)
    final latestProducts = products.take(5).toList();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.02),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Derniers produits ajoutés',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  _onUserInteraction();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index % latestProducts.length;
                  });
                },
                itemBuilder: (context, index) {
                  final productIndex = index % latestProducts.length;
                  return _buildHorizontalProductCard(latestProducts[productIndex]);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Indicateurs de page avec style rouge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              latestProducts.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: _currentPage == index 
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)]
                        )
                      : null,
                  color: _currentPage == index ? null : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductCard(Product product) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _onUserInteraction();
            _navigateToProductDetail(product);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icône avec plus de rouge
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.shield_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 14),
                
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge type avec plus de rouge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: product.type == ProductType.vie 
                              ? LinearGradient(colors: [
                                  AppColors.secondary.withOpacity(0.3),
                                  AppColors.secondary.withOpacity(0.2),
                                ])
                              : LinearGradient(colors: [
                                  AppColors.primary.withOpacity(0.25),
                                  AppColors.primary.withOpacity(0.15),
                                ]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: product.type == ProductType.vie 
                                ? AppColors.secondary.withOpacity(0.4)
                                : AppColors.primary.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          product.typeShortLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: product.type == ProductType.vie 
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Nom
                      Text(
                        product.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Description courte
                      Text(
                        product.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Flèche avec accent rouge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllProductsList(List<Product> products, ProductProvider productProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tous nos produits',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          )
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => productProvider.refresh(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildVerticalProductCard(products[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProductDetail(product),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icône avec plus de rouge
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.18),
                        AppColors.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.shield_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 18),
                
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge type avec plus de rouge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: product.type == ProductType.vie 
                              ? LinearGradient(colors: [
                                  AppColors.secondary.withOpacity(0.25),
                                  AppColors.secondary.withOpacity(0.15),
                                ])
                              : LinearGradient(colors: [
                                  AppColors.primary.withOpacity(0.2),
                                  AppColors.primary.withOpacity(0.1),
                                ]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: product.type == ProductType.vie 
                                ? AppColors.secondary.withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          product.typeShortLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: product.type == ProductType.vie 
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Nom
                      Text(
                        product.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Description
                      Text(
                        product.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Flèche avec fond rouge plus visible
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des produits...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, ProductProvider productProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => productProvider.refresh(),
              icon: Icon(Icons.refresh_rounded),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey.shade500,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun produit disponible',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Il n\'y a actuellement aucun produit d\'assurance disponible.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }
}