import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/beneficiaire_model.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/data/services/product_detail_service.dart';
import 'package:saarflex_app/presentation/features/souscription/viewmodels/souscription_viewmodel.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarflex_app/presentation/features/souscription/widgets/souscription_form.dart';
import 'package:saarflex_app/presentation/features/souscription/widgets/souscription_summary.dart';
import 'package:saarflex_app/presentation/features/souscription/widgets/payment_method_selector.dart';
import 'package:saarflex_app/presentation/features/souscription/widgets/beneficiaires_selector.dart';

class souscriptionScreen extends StatefulWidget {
  final SimulationResponse? simulationResult;
  final Product? product;
  final SavedQuote? savedQuote;

  final String source;

  const souscriptionScreen({
    super.key,
    this.simulationResult,
    this.product,
    this.savedQuote,
    required this.source,
  });

  @override
  State<souscriptionScreen> createState() => _souscriptionScreenState();
}

class _souscriptionScreenState extends State<souscriptionScreen> {
  late SouscriptionViewModel _souscriptionViewModel;
  final ProductDetailService _productDetailService = ProductDetailService();
  Product? _loadedProduct;
  bool _isLoadingProduct = false;

  @override
  void initState() {
    super.initState();
    _souscriptionViewModel = SouscriptionViewModel();
    _initializesouscription();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetails();
    });
  }

  @override
  void dispose() {
    _souscriptionViewModel.dispose();
    super.dispose();
  }

  void _initializesouscription() {
    if (widget.source == 'simulation' && widget.simulationResult != null) {
      _initializeFromSimulation();
    } else if (widget.source == 'saved_quote' && widget.savedQuote != null) {
      _initializeFromSavedQuote();
    }
  }

  void _initializeFromSimulation() {
    final result = widget.simulationResult!;

    final beneficiaires = result.beneficiaires
        .map(
          (b) => Beneficiaire(
            nomComplet: b['nom_complet']?.toString() ?? '',
            lienSouscripteur: b['lien_souscripteur']?.toString() ?? '',
            ordre: b['ordre'] ?? 1,
          ),
        )
        .toList();

    _souscriptionViewModel.initializesouscription(
      devisId: result.id,
      beneficiaires: beneficiaires,
    );
  }

  void _initializeFromSavedQuote() {
    final quote = widget.savedQuote!;

    final beneficiaires =
        quote.beneficiaires
            ?.map(
              (b) => Beneficiaire(
                nomComplet: b['nom_complet']?.toString() ?? '',
                lienSouscripteur: b['lien_souscripteur']?.toString() ?? '',
                ordre: b['ordre'] ?? 1,
              ),
            )
            .toList() ??
        [];

    _souscriptionViewModel.initializesouscription(
      devisId: quote.id,
      beneficiaires: beneficiaires,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _souscriptionViewModel,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Consumer2<SouscriptionViewModel, AuthViewModel>(
          builder: (context, souscriptionProvider, authProvider, child) {
            if (souscriptionProvider.isLoading) {
              return _buildLoadingState();
            }

            if (souscriptionProvider.hasError) {
              return _buildErrorState(souscriptionProvider.error!);
            }

            if (souscriptionProvider.souscriptionResponse != null) {
              return _buildSuccessState();
            }

            return _buildsouscriptionForm(authProvider.currentUser);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Souscription',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            Text(
              'Souscription réussie !',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre souscription a été enregistrée avec succès.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retour au tableau de bord'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildsouscriptionForm(User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          souscriptionSummary(
            simulationResult: widget.simulationResult,
            savedQuote: widget.savedQuote,
            source: widget.source,
          ),

          const SizedBox(height: 32),

          if (_isLoadingProduct)
            _buildLoadingProductInfo()
          else
            BeneficiairesSelector(
              beneficiaires: _souscriptionViewModel.beneficiaires,
              onBeneficiairesChanged: (beneficiaires) {
                _souscriptionViewModel.setBeneficiaires(beneficiaires);
              },
              maxBeneficiaires: _getMaxBeneficiaires(),
              necessiteBeneficiaires: _getNecessiteBeneficiaires(),
            ),

          const SizedBox(height: 32),

          PaymentMethodSelector(
            selectedMethod: _souscriptionViewModel.selectedMethodePaiement,
            onMethodSelected: _souscriptionViewModel.setMethodePaiement,
            hasError: _souscriptionViewModel.hasFieldError('methode_paiement'),
            errorText: _souscriptionViewModel.getFieldError('methode_paiement'),
          ),

          const SizedBox(height: 32),

          Consumer<SouscriptionViewModel>(
            builder: (context, provider, child) {
              return souscriptionForm(
                phoneNumber: provider.numeroTelephone,
                onPhoneChanged: provider.setNumeroTelephone,
                hasError: provider.hasFieldError('numero_telephone'),
                errorText: provider.getFieldError('numero_telephone'),
                selectedPaymentMethod: provider.selectedMethodePaiement,
              );
            },
          ),

          const SizedBox(height: 48),

          _buildSubscribeButton(),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Consumer<SouscriptionViewModel>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                provider.isSubscribing == true ||
                    !provider.isFormValid
                ? null
                : _handlesouscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isSubscribing == true
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Souscrire',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handlesouscription() async {
    final success = await _souscriptionViewModel.souscrire();

    if (!mounted) return;

    if (success) {
      final paymentUrl = _souscriptionViewModel.paymentUrl;
      
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(paymentUrl);
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          if (!launched) {
            await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur lors de l\'ouverture de l\'URL de paiement: ${e.toString()}',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Souscription effectuée avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _souscriptionViewModel.error ?? 'Erreur lors de la souscription',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loadProductDetails() async {
    if (widget.product != null) {
      _loadedProduct = widget.product;
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoadingProduct = true;
    });

    try {
      Product? product;

      if (widget.source == 'simulation' && widget.simulationResult != null) {
        product = await _productDetailService.getProductByName(
          widget.simulationResult!.nomProduit,
        );
      } else if (widget.source == 'saved_quote' && widget.savedQuote != null) {
        product = await _productDetailService.getProductByName(
          widget.savedQuote!.nomProduit,
        );
      }

      if (mounted) {
        setState(() {
          _loadedProduct = product;
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
        });
      }
    }
  }

  int _getMaxBeneficiaires() {
    if (widget.product != null) {
      return widget.product!.maxBeneficiaires > 0
          ? widget.product!.maxBeneficiaires
          : _getDefaultMaxBeneficiaires();
    }

    if (_loadedProduct != null) {
      return _loadedProduct!.maxBeneficiaires > 0
          ? _loadedProduct!.maxBeneficiaires
          : _getDefaultMaxBeneficiaires();
    }

    return _getFallbackMaxBeneficiaires();
  }

  bool _getNecessiteBeneficiaires() {
    if (widget.product != null) {
      return widget.product!.necessiteBeneficiaires;
    }

    if (_loadedProduct != null) {
      return _loadedProduct!.necessiteBeneficiaires;
    }

    return _getFallbackNecessiteBeneficiaires();
  }

  int _getDefaultMaxBeneficiaires() {
    if (widget.source == 'simulation' && widget.simulationResult != null) {
      final typeProduit = widget.simulationResult!.typeProduit.toLowerCase();
      if (typeProduit == 'vie') {
        return 5;
      } else {
        return 3;
      }
    }
    return 3;
  }

  int _getFallbackMaxBeneficiaires() {
    if (widget.source == 'simulation' && widget.simulationResult != null) {
      final typeProduit = widget.simulationResult!.typeProduit.toLowerCase();
      if (typeProduit == 'vie') {
        return 5;
      } else {
        return 3;
      }
    } else if (widget.source == 'saved_quote' && widget.savedQuote != null) {
      final typeProduit = widget.savedQuote!.typeProduit.toLowerCase();
      if (typeProduit == 'vie') {
        return 5;
      } else {
        return 3;
      }
    }
    return 3;
  }

  bool _getFallbackNecessiteBeneficiaires() {
    if (widget.source == 'simulation' && widget.simulationResult != null) {
      final typeProduit = widget.simulationResult!.typeProduit.toLowerCase();
      if (typeProduit == 'vie') return true;
      return widget.simulationResult!.beneficiaires.isNotEmpty;
    } else if (widget.source == 'saved_quote' && widget.savedQuote != null) {
      final typeProduit = widget.savedQuote!.typeProduit.toLowerCase();
      if (typeProduit == 'vie') return true;
      return widget.savedQuote!.beneficiaires?.isNotEmpty ?? false;
    }
    return true;
  }

  Widget _buildLoadingProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chargement de la configuration du produit...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
