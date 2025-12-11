import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/presentation/features/profile/screens/profile_screen.dart';
import 'package:saarflex_app/presentation/features/auth/widgets/dashboard_header.dart';
import 'package:saarflex_app/presentation/features/products/screens/product_list_screen.dart';
import 'package:saarflex_app/presentation/features/contracts/screens/contracts_screen.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthViewModel>().ensureUserProfileLoaded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Container(
            color: AppColors.primary,
            child: SafeArea(
              child: Column(
                children: [
                  DashboardHeader(
                    user: authProvider.currentUser,
                    onProfil: _handleProfil,
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

  Widget _buildContent(BuildContext context, AuthViewModel authProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360
        ? 16.0
        : screenWidth < 600
            ? 24.0
            : (screenWidth * 0.08).clamp(24.0, 48.0);
    final verticalPadding = screenWidth < 360 ? 16.0 : 24.0;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenWidth < 360 ? 10 : 15),
              _buildWelcomeSection(authProvider),
              SizedBox(height: screenWidth < 360 ? 24 : 32),
              _buildStatsCards(),
              SizedBox(height: screenWidth < 360 ? 24 : 32),
              _buildQuickActionsSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AuthViewModel authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tableau de bord",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
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
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final spacing = isNarrow ? 12.0 : 16.0;

        if (isNarrow) {
          return Column(
            children: [
              _buildStatCard(
                "Contrats Actifs",
                "0",
                Icons.description_rounded,
                AppColors.success,
              ),
              SizedBox(height: spacing),
              _buildStatCard(
                "Sinistres",
                "1",
                Icons.report_problem_rounded,
                AppColors.warning,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Contrats Actifs",
                "0",
                Icons.description_rounded,
                AppColors.success,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildStatCard(
                "Sinistres",
                "1",
                Icons.report_problem_rounded,
                AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 900
                ? 4
                : width >= 680
                    ? 3
                    : 2;
            final spacing = width < 360 ? 12.0 : 16.0;
            final itemWidth = (width - (crossAxisCount - 1) * spacing) / crossAxisCount;
            final childAspectRatio = width < 360 ? 0.95 : (itemWidth / (itemWidth + 20));

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
              children: [
                _buildActionCard(
                  "Offres Assurance",
                  Icons.shopping_bag_rounded,
                  AppColors.primary,
                  () => _navigateToProducts(),
                ),
                _buildActionCard(
                  "Mes Contrats",
                  Icons.description_rounded,
                  AppColors.accent,
                  () => _navigateToContracts(),
                ),
                _buildActionCard(
                  "Sinistres",
                  Icons.report_problem_rounded,
                  AppColors.warning,
                  () => _showComingSoon(context),
                ),
                _buildActionCard(
                  "Support",
                  Icons.support_agent_rounded,
                  AppColors.success,
                  () => _showComingSoon(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.05), color.withOpacity(0.02)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleProfil() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductListScreen()),
    );
  }

  void _navigateToContracts() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ContractsScreen(),
          settings: const RouteSettings(name: '/contracts'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de navigation: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              "Fonctionnalité à venir !",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
