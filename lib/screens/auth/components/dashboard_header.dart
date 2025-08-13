import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/models/user_model.dart';
import '../../../constants/colors.dart';

class DashboardHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onProfil;
  final VoidCallback onNotification;
  final VoidCallback onSettings;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.onProfil,
    required this.onNotification,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 16),
          _buildUserInfo(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Icon(
          Icons.person_rounded, 
          color: AppColors.primary, 
          size: 35
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bonjour,",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.nom ?? "Utilisateur",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              user?.email ?? "email@example.com",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withOpacity(0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildHeaderButton(
          icon: Icons.notifications_rounded,
          onTap: onNotification,
        ),
        const SizedBox(width: 8),
        _buildHeaderButton(
          icon: Icons.person_rounded, 
          onTap: onProfil,
          isProfile: true,
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isProfile = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isProfile 
            ? AppColors.secondary.withOpacity(0.2)
            : AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isProfile 
              ? AppColors.secondary.withOpacity(0.4)
              : AppColors.white.withOpacity(0.3), 
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: isProfile 
                ? AppColors.secondary.withOpacity(0.2)
                : AppColors.shadowMedium,
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon, 
          color: isProfile ? AppColors.secondary : AppColors.white, 
          size: 22
        ),
        onPressed: onTap,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }
}