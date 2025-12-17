import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/core/utils/product_formatters.dart';

class LatestProductsSection extends StatefulWidget {
  final List<Product> latestProducts;
  final Function(Product) onProductTap;

  const LatestProductsSection({
    super.key,
    required this.latestProducts,
    required this.onProductTap,
  });

  @override
  State<LatestProductsSection> createState() => _LatestProductsSectionState();
}

class _LatestProductsSectionState extends State<LatestProductsSection> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  bool _userInteracting = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _startAutoScrollOptimized();
  }

  void _startAutoScrollOptimized() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      if (!_userInteracting && _pageController.hasClients && mounted) {
        final products = widget.latestProducts;
        if (products.isNotEmpty) {
          _currentPage = (_currentPage + 1) % products.length;

          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _onUserInteractionOptimized() {
    if (!_userInteracting) {
      setState(() {
        _userInteracting = true;
      });

      Timer(const Duration(seconds: 6), () {
        if (mounted && !_disposed) {
          setState(() {
            _userInteracting = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.latestProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final topMargin = screenWidth < 360 ? 16.0 : 20.0;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final topPadding = screenWidth < 360 ? 4.0 : 5.0;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final spacing1 = screenWidth < 360 ? 8.0 : 10.0;
    final cardHeight = screenWidth < 360 ? 140.0 : screenWidth < 600 ? 150.0 : 160.0;
    final spacing2 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing3 = screenWidth < 360 ? 16.0 : 20.0;
    final indicatorSpacing = screenWidth < 360 ? 2.5 : 3.0;
    final indicatorWidth = screenWidth < 360 ? 18.0 : 20.0;
    final indicatorHeight = screenWidth < 360 ? 6.0 : 8.0;
    final indicatorInactiveWidth = screenWidth < 360 ? 6.0 : 8.0;

    return Container(
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withOpacity(0.02), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Derniers produits ajoutés',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(height: spacing1),
          SizedBox(
            height: cardHeight,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  _onUserInteractionOptimized();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  final newPage = index % widget.latestProducts.length;
                  if (_currentPage != newPage) {
                    setState(() {
                      _currentPage = newPage;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  final productIndex = index % widget.latestProducts.length;
                  return _buildHorizontalProductCard(
                    widget.latestProducts[productIndex],
                    screenWidth,
                    textScaleFactor,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: spacing2),
          if (widget.latestProducts.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.latestProducts.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: indicatorSpacing),
                  width: _currentPage == index ? indicatorWidth : indicatorInactiveWidth,
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    gradient: _currentPage == index
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: _currentPage == index ? null : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          SizedBox(height: spacing3),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductCard(
    Product product,
    double screenWidth,
    double textScaleFactor,
  ) {
    final margin = screenWidth < 360 ? 6.0 : 8.0;
    final padding = screenWidth < 360 ? 12.0 : 16.0;
    final nameFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final descFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 6.0 : 8.0;
    final spacing2 = screenWidth < 360 ? 10.0 : 12.0;
    final iconPadding = screenWidth < 360 ? 10.0 : 12.0;
    final iconSize = screenWidth < 360 ? 14.0 : 16.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onProductTap(product),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ProductFormatters.formatProductName(product.nom),
                      style: GoogleFonts.poppins(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing1),
                    Text(
                      ProductFormatters.formatProductDescription(
                        product.description,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: descFontSize,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  ),
                ),
                SizedBox(width: spacing2),
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                    size: iconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
