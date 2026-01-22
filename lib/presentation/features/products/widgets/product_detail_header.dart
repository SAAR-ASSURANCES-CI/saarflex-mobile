import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/core/utils/product_formatters.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_icon_widget.dart';

class ProductDetailHeader extends StatelessWidget {
  final Product product;

  const ProductDetailHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final nomLength = product.nom.length;
    final baseHeight = 230.0;
    final additionalHeight = nomLength > 30 
        ? (nomLength - 30) * 2.0 
        : 0.0;
    final calculatedHeight = (baseHeight + additionalHeight).clamp(230.0, 320.0);

    final fontSize = screenWidth < 360 
        ? (24.0 / textScaleFactor).clamp(18.0, 24.0)
        : (24.0 / textScaleFactor).clamp(20.0, 28.0);

    return SliverAppBar(
      expandedHeight: calculatedHeight,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                product.type.color.withOpacity(0.8),
                product.type.color.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 360 ? 12.0 : 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                      child: Container(
                        width: screenWidth < 360 ? 68 : 76,
                        height: screenWidth < 360 ? 68 : 76,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ProductIconWidget(
                          product: product,
                          size: screenWidth < 360 ? 32 : 38,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth < 360 ? 10 : 14),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 360 ? 8.0 : 16.0,
                      ),
                      child: Text(
                        ProductFormatters.formatProductName(product.nom),
                        style: FontHelper.poppins(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: screenWidth < 360 ? 6 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 360 ? 12 : 16,
                        vertical: screenWidth < 360 ? 5 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.type.label,
                        style: FontHelper.poppins(
                          fontSize: screenWidth < 360 ? 12 : 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
