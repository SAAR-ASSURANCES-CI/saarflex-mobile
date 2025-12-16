import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class ProductListLoadingState extends StatelessWidget {
  const ProductListLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final containerSize = screenWidth < 360 ? 50.0 : screenWidth < 600 ? 55.0 : 60.0;
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final spacing = screenWidth < 360 ? 20.0 : 24.0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
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
          SizedBox(height: spacing),
          Text(
            'Chargement des produits...',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
