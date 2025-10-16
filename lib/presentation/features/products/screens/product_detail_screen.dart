import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarflex_app/presentation/shared/widgets/assure_selector_popup.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/presentation/features/products/viewmodels/product_viewmodel.dart';
import 'package:saarflex_app/presentation/features/simulation/screens/info_assure_screen.dart';
import 'package:saarflex_app/core/utils/image_labels.dart';
import 'package:saarflex_app/presentation/features/products/widgets/product_detail_loading_state.dart';
import 'package:saarflex_app/presentation/features/products/widgets/product_detail_error_state.dart';
import 'package:saarflex_app/presentation/features/products/widgets/product_detail_header.dart';
import 'package:saarflex_app/presentation/features/products/widgets/product_description_section.dart';
import 'package:saarflex_app/presentation/features/products/widgets/product_simulation_section.dart';
import 'package:saarflex_app/presentation/features/products/widgets/product_simulation_button.dart';
import 'package:saarflex_app/presentation/features/products/widgets/photo_required_dialog.dart';
import 'package:saarflex_app/presentation/features/profile/screens/edit_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _hasRequiredPhotos(AuthViewModel authProvider) {
    final user = authProvider.currentUser;
    if (user == null) return false;

    final hasRectoPhoto =
        user.frontDocumentPath != null && user.frontDocumentPath!.isNotEmpty;
    final hasVersoPhoto =
        user.backDocumentPath != null && user.backDocumentPath!.isNotEmpty;

    return hasRectoPhoto && hasVersoPhoto;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: productProvider.isLoadingDetail
              ? const ProductDetailLoadingState()
              : productProvider.selectedProduct == null
              ? ProductDetailErrorState(
                  errorMessage:
                      productProvider.errorMessage ??
                      'Ce produit n\'existe pas ou n\'est plus disponible.',
                )
              : _buildProductDetail(productProvider.selectedProduct!),
          bottomNavigationBar: productProvider.selectedProduct != null
              ? ProductSimulationButton(
                  product: productProvider.selectedProduct!,
                  onPressed: () =>
                      _navigateToSimulation(productProvider.selectedProduct!),
                )
              : null,
        );
      },
    );
  }

  Widget _buildProductDetail(Product product) {
    return CustomScrollView(
      slivers: [
        ProductDetailHeader(product: product),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductDescriptionSection(product: product),
                const SizedBox(height: 32),
                const ProductSimulationSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToSimulation(Product product) async {
    final authProvider = context.read<AuthViewModel>();

    final bool? isSelfAssured = await showDialog<bool>(
      context: context,
      builder: (context) => AssureSelectorDialog(
        onConfirm: (value) => Navigator.pop(context, value),
      ),
    );

    if (!mounted || isSelfAssured == null) return;

    try {
      if (isSelfAssured) {
        final currentUser = authProvider.currentUser;

        if (currentUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Veuillez vous connecter pour continuer')),
            );
          }
          return;
        }

        if (!(currentUser.isProfileComplete ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Complétez votre profil pour simuler un devis',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange[800],
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          );

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditProfileScreenRefactored(produit: product),
            ),
          );

          await authProvider.loadUserProfile();

          if (authProvider.currentUser?.isProfileComplete == true && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SimulationScreen(
                  produit: product,
                  assureEstSouscripteur: true,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profil toujours incomplet'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        if (!_hasRequiredPhotos(authProvider)) {
          final user = authProvider.currentUser;
          final identityType = user?.identityType;
          final photoTitle = ImageLabels.getUploadTitle(identityType);
          final photoDescription = ImageLabels.getUploadDescription(
            identityType,
          );

          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return PhotoRequiredDialog(
                photoTitle: photoTitle,
                photoDescription: photoDescription,
                product: product,
              );
            },
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SimulationScreen(produit: product, assureEstSouscripteur: true),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoAssureScreen(produit: product),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }
}
