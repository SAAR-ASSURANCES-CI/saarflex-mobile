import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final double screenWidth;
  final double textScaleFactor;

  const ProfileHeader({
    super.key, 
    required this.user,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSpacing = screenWidth < 360 ? 12.0 : 16.0;
    final nameSpacing = screenWidth < 360 ? 6.0 : 8.0;
    
    return Column(
      children: [
        _buildAvatar(),
        SizedBox(height: avatarSpacing),
        _buildUserName(),
        SizedBox(height: nameSpacing),
        _buildUserEmail(),
      ],
    );
  }

  Widget _buildAvatar() {
    final avatarSize = screenWidth < 360 ? 80.0 : 100.0;
    final iconSize = screenWidth < 360 ? 40.0 : 50.0;
    
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.person_rounded, 
        color: AppColors.white, 
        size: iconSize,
      ),
    );
  }

  Widget _buildUserName() {
    final fontSize = (24.0 / textScaleFactor).clamp(20.0, 28.0);
    
    return Text(
      user?.nom ?? "Utilisateur",
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUserEmail() {
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    
    return Text(
      user?.email ?? "Email non renseigné",
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
