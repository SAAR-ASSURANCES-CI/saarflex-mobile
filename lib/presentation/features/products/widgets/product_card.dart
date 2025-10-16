import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/core/utils/product_formatters.dart';

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
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildContent(),
                if (showStatus || showBranch || showCreatedAt) ...[
                  const SizedBox(height: 12),
                  _buildFooter(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: product.displayColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            product.displayIcon,
            color: product.displayColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ProductFormatters.formatProductName(product.nom),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showType) ...[
                const SizedBox(height: 4),
                Text(
                  ProductFormatters.formatProductTypeShort(product.type),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: product.displayColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.isActive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ProductFormatters.formatProductStatus(product.statut),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: product.isActive ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      ProductFormatters.formatProductDescription(product.description),
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (showBranch) ...[
          Icon(Icons.business, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            ProductFormatters.formatProductBranch(product.branche),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
        if (showBranch && showCreatedAt) ...[
          const SizedBox(width: 16),
          Container(width: 1, height: 12, color: Colors.grey[300]),
          const SizedBox(width: 16),
        ],
        if (showCreatedAt) ...[
          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            ProductFormatters.formatProductCreatedAt(product.createdAt),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
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
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: product.displayColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    product.displayIcon,
                    color: product.displayColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ProductFormatters.formatProductName(product.nom),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ProductFormatters.formatProductTypeShort(product.type),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: product.displayColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
