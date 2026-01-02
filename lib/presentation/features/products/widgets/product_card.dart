import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/core/utils/product_formatters.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_icon_widget.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showType;
  final bool showStatus;
  final bool showBranch;
  final bool showCreatedAt;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showType = true,
    this.showStatus = true,
    this.showBranch = false,
    this.showCreatedAt = false,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final defaultMargin = EdgeInsets.symmetric(
      horizontal: screenWidth < 360 ? 12.0 : 16.0,
      vertical: screenWidth < 360 ? 6.0 : 8.0,
    );
    final defaultPadding = screenWidth < 360 ? 12.0 : 16.0;
    final spacing = screenWidth < 360 ? 10.0 : 12.0;
    
    return Container(
      margin: margin ?? defaultMargin,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(screenWidth, textScaleFactor),
                SizedBox(height: spacing),
                _buildContent(screenWidth, textScaleFactor),
                if (showStatus || showBranch || showCreatedAt) ...[
                  SizedBox(height: spacing),
                  _buildFooter(screenWidth, textScaleFactor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double textScaleFactor) {
    final iconPadding = screenWidth < 360 ? 6.0 : 8.0;
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    final nameFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final typeFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final statusFontSize = (10.0 / textScaleFactor).clamp(9.0, 12.0);
    final spacing1 = screenWidth < 360 ? 10.0 : 12.0;
    final spacing2 = screenWidth < 360 ? 3.0 : 4.0;
    final statusPaddingH = screenWidth < 360 ? 6.0 : 8.0;
    final statusPaddingV = screenWidth < 360 ? 3.0 : 4.0;
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: product.displayColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ProductIconWidget(
            product: product,
            size: iconSize,
            color: product.displayColor,
          ),
        ),
        SizedBox(width: spacing1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ProductFormatters.formatProductName(product.nom),
                style: GoogleFonts.poppins(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showType) ...[
                SizedBox(height: spacing2),
                Text(
                  ProductFormatters.formatProductTypeShort(product.type),
                  style: GoogleFonts.poppins(
                    fontSize: typeFontSize,
                    fontWeight: FontWeight.w500,
                    color: product.displayColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (showStatus)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: statusPaddingH,
              vertical: statusPaddingV,
            ),
            decoration: BoxDecoration(
              color: product.isActive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ProductFormatters.formatProductStatus(product.statut),
              style: GoogleFonts.poppins(
                fontSize: statusFontSize,
                fontWeight: FontWeight.w500,
                color: product.isActive ? Colors.green[700] : Colors.red[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildContent(double screenWidth, double textScaleFactor) {
    final fontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    
    return Text(
      ProductFormatters.formatProductDescription(product.description),
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(double screenWidth, double textScaleFactor) {
    final iconSize = screenWidth < 360 ? 12.0 : 14.0;
    final fontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 3.0 : 4.0;
    final spacing2 = screenWidth < 360 ? 12.0 : 16.0;
    final dividerHeight = screenWidth < 360 ? 10.0 : 12.0;
    
    return Row(
      children: [
        if (showBranch) ...[
          Icon(Icons.business, size: iconSize, color: Colors.grey[500]),
          SizedBox(width: spacing1),
          Flexible(
            child: Text(
              ProductFormatters.formatProductBranch(product.branche),
              style: GoogleFonts.poppins(fontSize: fontSize, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (showBranch && showCreatedAt) ...[
          SizedBox(width: spacing2),
          Container(width: 1, height: dividerHeight, color: Colors.grey[300]),
          SizedBox(width: spacing2),
        ],
        if (showCreatedAt) ...[
          Icon(Icons.access_time, size: iconSize, color: Colors.grey[500]),
          SizedBox(width: spacing1),
          Flexible(
            child: Text(
              ProductFormatters.formatProductCreatedAt(product.createdAt),
              style: GoogleFonts.poppins(fontSize: fontSize, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class ProductCardCompact extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const ProductCardCompact({
    super.key,
    required this.product,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final defaultMargin = EdgeInsets.symmetric(
      horizontal: screenWidth < 360 ? 12.0 : 16.0,
      vertical: screenWidth < 360 ? 3.0 : 4.0,
    );
    final padding = screenWidth < 360 ? 10.0 : 12.0;
    final iconPadding = screenWidth < 360 ? 5.0 : 6.0;
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final nameFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final typeFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final spacing1 = screenWidth < 360 ? 10.0 : 12.0;
    final spacing2 = screenWidth < 360 ? 2.0 : 2.0;
    final arrowSize = screenWidth < 360 ? 14.0 : 16.0;
    
    return Container(
      margin: margin ?? defaultMargin,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: product.displayColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ProductIconWidget(
                    product: product,
                    size: iconSize,
                    color: product.displayColor,
                  ),
                ),
                SizedBox(width: spacing1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ProductFormatters.formatProductName(product.nom),
                        style: GoogleFonts.poppins(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing2),
                      Text(
                        ProductFormatters.formatProductTypeShort(product.type),
                        style: GoogleFonts.poppins(
                          fontSize: typeFontSize,
                          color: product.displayColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: arrowSize,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
