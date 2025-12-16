import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';

class ProductSimulationButton extends StatelessWidget {
  final Product product;
  final VoidCallback onPressed;

  const ProductSimulationButton({
    super.key,
    required this.product,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding = viewInsets.bottom > 0 ? viewInsets.bottom : 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Taille de police adaptative
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final horizontalPadding = screenWidth < 360 ? 16.0 : 24.0;
    final verticalPadding = screenWidth < 360 ? 16.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: verticalPadding,
        bottom: verticalPadding + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            minimumSize: Size(
              double.infinity,
              screenWidth < 360 ? 48 : 50,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calculate_rounded,
                size: screenWidth < 360 ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Simuler un devis',
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
