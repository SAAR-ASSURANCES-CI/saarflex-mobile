import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/profile/profile_screen.dart';
import 'package:saarflex_app/screens/auth/components/action_card.dart';
import 'package:saarflex_app/screens/auth/components/dashboard_header.dart';
import 'package:saarflex_app/screens/auth/components/info_card.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
 @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                  AppColors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  DashboardHeader(
                    user: authProvider.currentUser, 
                    onLogout: _handleLogout,
                    onNotification: () => _showComingSoon(context),
                    onSettings: () => _showComingSoon(context),
                  ),
                  _buildContent(context, authProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
   
  }

  Widget _buildContent(BuildContext context, AuthProvider authProvider) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildWelcomeSection(authProvider), 
              const SizedBox(height: 32),
              _buildQuickActionsSection(context),
              const SizedBox(height: 32),
              InfoCard(
                icon: Icons.info_outline_rounded,
                title: "Bienvenue sur SAAR Assurance !",
                message: "Votre espace personnel vous permet de gérer tous vos "
                    "contrats d'assurance. Commencez par compléter votre profil.",
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

 

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tableau de bord",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          authProvider.currentUser != null 
              ? "Bonjour ${authProvider.currentUser!.nom} !"
              : "Gérez votre assurance en toute simplicité",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }


Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Actions rapides",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            ActionCard(
              title: "Mon Profil",
              icon: Icons.person_rounded,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ActionCard(
              title: "Mes Contrats",
              icon: Icons.description_rounded,
              color: AppColors.secondary,
              onTap: () => _showComingSoon(context),
            ),
            ActionCard(
              title: "Sinistres",
              icon: Icons.report_problem_rounded,
              color: Colors.orange,
              onTap: () => _showComingSoon(context),
            ),
            ActionCard(
              title: "Support",
              icon: Icons.support_agent_rounded,
              color: Colors.green,
              onTap: () => _showComingSoon(context),
            ),
          ],  
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();

    final confirmed = await _showLogoutDialog(context);
    if (confirmed == true) {
      await authProvider.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/welcome', 
          (route) => false,
        );
      }
    }
  }


Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Déconnexion",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          content: Text(
            "Êtes-vous sûr de vouloir vous déconnecter ?",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.primary.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Annuler",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Déconnecter",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text("Fonctionnalité à venir !"),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

