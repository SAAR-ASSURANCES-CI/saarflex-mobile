import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/core/utils/product_formatters.dart';

class ProductDescriptionSection extends StatelessWidget {
  final Product product;

  const ProductDescriptionSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Padding adaptatif
    final padding = screenWidth < 360 ? 16.0 : 20.0;
    
    // Tailles de police adaptatives
    final titleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final descriptionFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screenWidth < 360 ? 12 : 16),
          Text(
            product.description.isNotEmpty
                ? ProductFormatters.formatProductDescription(
                    product.description,
                  )
                : 'Protection complète et personnalisée selon vos besoins.',
            style: GoogleFonts.poppins(
              fontSize: descriptionFontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
