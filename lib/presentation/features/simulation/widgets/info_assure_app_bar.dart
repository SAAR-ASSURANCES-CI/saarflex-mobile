import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class InfoAssureAppBar extends StatelessWidget implements PreferredSizeWidget {
  const InfoAssureAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Informations de l\'assuré',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
