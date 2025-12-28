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
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserName(),
              const SizedBox(height: 4),
              _buildUserEmail(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final avatarSize = screenWidth < 360 ? 70.0 : 80.0;
    final iconSize = screenWidth < 360 ? 35.0 : 40.0;
    final hasAvatar = (user?.avatarUrl ?? '').isNotEmpty;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
                user!.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person_rounded,
                    color: Colors.grey[600],
                    size: iconSize,
                  );
                },
              )
            : Icon(
                Icons.person_rounded,
                color: Colors.grey[600],
                size: iconSize,
              ),
      ),
    );
  }

  Widget _buildUserName() {
    final fontSize = (20.0 / textScaleFactor).clamp(18.0, 24.0);
    
    return Text(
      user?.nom ?? "Utilisateur",
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUserEmail() {
    final fontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    
    return Text(
      user?.email ?? "Email non renseigné",
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

}
