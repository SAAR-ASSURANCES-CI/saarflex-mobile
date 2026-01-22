import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/profile_helpers.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';

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
      padding: const EdgeInsets.only(
         top: 12,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildUserAvatar(context),
                _buildActionButtons(),
              ],
            ),
            const SizedBox(height: 16),
            _buildWelcomeText(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser ?? user;
        final hasAvatar = ProfileHelpers.isValidImage(currentUser?.avatarUrl);
        
        final avatarUrlRaw = currentUser?.avatarUrl;
        final avatarUrl = avatarUrlRaw != null
            ? (avatarUrlRaw.startsWith('http://') || avatarUrlRaw.startsWith('https://'))
                ? avatarUrlRaw
                : ProfileHelpers.buildImageUrl(avatarUrlRaw, ApiConstants.baseUrl)
            : null;

        final cacheBuster = authProvider.avatarTimestamp ?? 
            currentUser?.updatedAt?.millisecondsSinceEpoch ?? 
            DateTime.now().millisecondsSinceEpoch;
        
        final avatarUrlWithCacheBuster = avatarUrl != null 
            ? (avatarUrl.contains('?') 
                ? '$avatarUrl&t=$cacheBuster&v=${DateTime.now().millisecondsSinceEpoch}'
                : '$avatarUrl?t=$cacheBuster&v=${DateTime.now().millisecondsSinceEpoch}')
            : null;

        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: hasAvatar && avatarUrlWithCacheBuster != null
                  ? Image.network(
                      avatarUrlWithCacheBuster,
                      key: ValueKey('dashboard_avatar_${currentUser?.id}_$cacheBuster'),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      cacheWidth: 168,
                      cacheHeight: 168,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[100]!,
            Colors.blue[50]!,
          ],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        color: Colors.blue[400],
        size: 32,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Bienvenue !",
          style: FontHelper.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.nom ?? "Utilisateur",
          style: FontHelper.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildHeaderButton(
          icon: Icons.notifications_outlined,
          onTap: onNotification,
        ),
        const SizedBox(width: 8),
        _buildHeaderButton(
          icon: Icons.person_outline_rounded,
          onTap: onProfil,
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Icon(
            icon,
            color: Colors.grey[700],
            size: 22,
          ),
        ),
      ),
    );
  }

}
