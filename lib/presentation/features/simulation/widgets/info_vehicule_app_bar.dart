import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';

class InfoVehiculeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const InfoVehiculeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final titleFontSize = (22.0 / textScaleFactor).clamp(20.0, 26.0);
    final iconSize = screenWidth < 360 ? 22 : 26;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[600]!,
              Colors.indigo[700]!,
            ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize.toDouble()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Informations du véhicule',
        style: FontHelper.poppins(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}


