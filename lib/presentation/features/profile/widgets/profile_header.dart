import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/profile_helpers.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final double screenWidth;
  final double textScaleFactor;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key, 
    required this.user,
    required this.screenWidth,
    required this.textScaleFactor,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: _buildAvatar(),
        ),
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
    return Consumer<AuthViewModel>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser ?? user;
        final avatarSize = screenWidth < 360 ? 70.0 : 80.0;
        final iconSize = screenWidth < 360 ? 35.0 : 40.0;
        final hasAvatar = ProfileHelpers.isValidImage(currentUser?.avatarUrl);
        final avatarUrl = currentUser?.avatarUrl != null
            ? ProfileHelpers.buildImageUrl(currentUser!.avatarUrl!, ApiConstants.baseUrl)
            : null;

        // Utiliser le timestamp d'avatar s'il existe, sinon utiliser updatedAt ou un timestamp actuel
        final cacheBuster = authProvider.avatarTimestamp ?? 
            currentUser?.updatedAt?.millisecondsSinceEpoch ?? 
            DateTime.now().millisecondsSinceEpoch;
        
        // Si l'URL est déjà complète (contient https://), ne pas ajouter de query params
        // car le backend peut ne pas les accepter
        final avatarUrlWithCacheBuster = avatarUrl != null 
            ? (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'))
                ? avatarUrl // URL complète : utiliser telle quelle
                : '$avatarUrl?t=$cacheBuster&v=${DateTime.now().millisecondsSinceEpoch}' // URL relative : ajouter cache buster
            : null;

        return Stack(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: hasAvatar && avatarUrlWithCacheBuster != null
                    ? FutureBuilder<Map<String, String>>(
                        future: _getAuthHeaders(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Icon(
                              Icons.person_rounded,
                              color: Colors.grey[600],
                              size: iconSize,
                            );
                          }
                          return Image.network(
                            avatarUrlWithCacheBuster,
                            key: ValueKey('avatar_${currentUser?.id}_$cacheBuster'), // Key unique pour forcer le rebuild
                            fit: BoxFit.cover,
                            headers: snapshot.data!,
                            // Utiliser 3x pour les écrans haute densité (Retina, etc.)
                            cacheWidth: (avatarSize * 3).toInt(),
                            cacheHeight: (avatarSize * 3).toInt(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                            Icons.person_rounded,
                            color: Colors.grey[600],
                            size: iconSize,
                          );
                            },
                          );
                        },
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: Colors.grey[600],
                        size: iconSize,
                      ),
              ),
            ),
            if (onAvatarTap != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (e) {
      // Ignore errors
    }
    return {};
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
