import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class ProductListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProductListAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final iconSize = screenWidth < 360 ? 20 : 24;
    
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: iconSize.toDouble(),
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          }
        },
      ),
      title: Text(
        "Produits d'assurance",
        style: GoogleFonts.poppins(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
