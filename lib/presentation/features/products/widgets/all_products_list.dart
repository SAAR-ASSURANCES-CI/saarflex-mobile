import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/core/utils/product_formatters.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_icon_widget.dart';

class AllProductsList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const AllProductsList({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final bottomPadding = screenWidth < 360 ? 16.0 : 20.0;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final spacing = screenWidth < 360 ? 12.0 : 16.0;
    final itemSpacing = screenWidth < 360 ? 10.0 : 12.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Tous nos produits',
            style: FontHelper.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing),
          Expanded(
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
              itemBuilder: (context, index) {
                return _buildVerticalProductCard(
                  products[index],
                  screenWidth,
                  textScaleFactor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalProductCard(
    Product product,
    double screenWidth,
    double textScaleFactor,
  ) {
    final padding = screenWidth < 360 ? 12.0 : 16.0;
    final iconPadding = screenWidth < 360 ? 10.0 : 12.0;
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    final nameFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final typeFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final descFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final spacing1 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = screenWidth < 360 ? 3.0 : 4.0;
    final spacing3 = screenWidth < 360 ? 6.0 : 8.0;
    final arrowSize = screenWidth < 360 ? 14.0 : 16.0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onProductTap(product),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ProductIconWidget(
                  product: product,
                  size: iconSize,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: spacing1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ProductFormatters.formatProductName(product.nom),
                        style: FontHelper.poppins(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing2),
                      Text(
                        product.typeLabel,
                        style: FontHelper.poppins(
                          fontSize: typeFontSize,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing3),
                      Text(
                        ProductFormatters.formatProductDescription(
                          product.description,
                        ),
                        style: FontHelper.poppins(
                          fontSize: descFontSize,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: arrowSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
