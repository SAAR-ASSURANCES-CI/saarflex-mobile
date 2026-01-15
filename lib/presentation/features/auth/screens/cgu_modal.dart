import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/auth/widgets/cgu_content.dart';

class CGUModal extends StatelessWidget {
  const CGUModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CGUModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    final appBarFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final maxHeight = screenHeight * 0.9;

    return Container(
      height: maxHeight,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // AppBar
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textPrimary,
                size: screenWidth < 360 ? 22 : 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Conditions Générales d'Utilisation",
              style: GoogleFonts.poppins(
                fontSize: appBarFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: const CGUContent(),
            ),
          ),
        ],
      ),
    );
  }
}
