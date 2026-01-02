import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/profile/screens/profile_screen.dart';
import 'package:saarciflex_app/presentation/features/auth/widgets/dashboard_header.dart';
import 'package:saarciflex_app/presentation/features/products/screens/product_list_screen.dart';
import 'package:saarciflex_app/presentation/features/products/screens/product_detail_screen.dart';
import 'package:saarciflex_app/presentation/features/contracts/screens/contracts_screen.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/products/viewmodels/product_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/contracts/viewmodels/contract_viewmodel.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/presentation/features/products/widgets/product_icon_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Couleur de fond cyan/bleu très clair
  static const Color _backgroundColor = Color(0xFFE8F4F8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthViewModel>().ensureUserProfileLoaded();
        context.read<ProductViewModel>().loadProducts();
        context.read<ContractViewModel>().loadActiveContractsCount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header simplifié
                  DashboardHeader(
                    user: authProvider.currentUser,
                    onProfil: _handleProfil,
                    onNotification: () => _showComingSoon(context),
                    onSettings: () => _showComingSoon(context),
                  ),
                  // Contenu principal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte promotionnelle avec dégradé
                        _buildPromoCard(),
                        const SizedBox(height: 24),
                        // Section Stats
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        // Section Actions rapides
                        _buildQuickActionsSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.indigo[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[400]!.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Contenu texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Découvrez nos offres",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Protégez ce qui compte le plus avec nos solutions d'assurance",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _navigateToProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Explorer",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Logo à droite
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'lib/assets/logoSaarCI.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    const double cardHeight = 170.0;
    
    return Column(
      children: [
        // Première ligne : Contrats Actifs + Sinistres
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Consumer<ContractViewModel>(
                  builder: (context, contractViewModel, child) {
                    final count = contractViewModel.isLoadingActiveCount 
                        ? "..." 
                        : contractViewModel.activeContractsCount.toString();
                    
                    return _buildUnifiedCard(
                      title: "Contrats Actifs",
                      value: count,
                      icon: Icons.description_outlined,
                      gradientColors: [Colors.teal[400]!, Colors.teal[600]!],
                      height: cardHeight,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUnifiedCard(
                  title: "Sinistres",
                  value: "1",
                  icon: Icons.warning_amber_rounded,
                  gradientColors: [Colors.orange[400]!, Colors.deepOrange[500]!],
                  height: cardHeight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Deuxième ligne : Offres Assurance + Mes Contrats
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildUnifiedCard(
                  title: "Offres Assurance",
                  icon: Icons.shopping_bag_rounded,
                  gradientColors: [Colors.red[400]!, Colors.red[600]!],
                  onTap: _navigateToProducts,
                  height: cardHeight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUnifiedCard(
                  title: "Mes Contrats",
                  icon: Icons.folder_rounded,
                  gradientColors: [Colors.purple[400]!, Colors.purple[600]!],
                  onTap: _navigateToContracts,
                  height: cardHeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedCard({
    required String title,
    String? value,
    required IconData icon,
    required List<Color> gradientColors,
    VoidCallback? onTap,
    required double height,
  }) {
    final content = Container(
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors[0].withOpacity(0.2),
                  gradientColors[1].withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: gradientColors[0],
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          if (value != null) ...[
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: gradientColors[0],
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }

  Widget _buildQuickActionsSection() {
    return Consumer<ProductViewModel>(
      builder: (context, productViewModel, child) {
        final products = productViewModel.allProducts;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nos Produits",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                  ),
                ),
                TextButton(
                  onPressed: _navigateToProducts,
                  child: Text(
                    "Voir tout",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (productViewModel.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Aucun produit disponible",
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 115,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length > 6 ? 6 : products.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductItem(product);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProductItem(Product product) {
    final color = product.type.color;
    final gradientColors = [color, color];
    
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors[0].withOpacity(0.2),
                  gradientColors[1].withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ProductIconWidget(
              product: product,
              size: 26,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 70,
            child: Text(
              product.nom,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
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
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
