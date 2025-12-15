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
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    return ChangeNotifierProvider.value(
      value: _souscriptionViewModel,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(screenWidth, textScaleFactor),
        body: Consumer2<SouscriptionViewModel, AuthViewModel>(
          builder: (context, souscriptionProvider, authProvider, child) {
            if (souscriptionProvider.isLoading) {
              return _buildLoadingState(screenWidth, textScaleFactor);
            }

            if (souscriptionProvider.hasError) {
              return _buildErrorState(
                souscriptionProvider.error!,
                screenWidth,
                textScaleFactor,
              );
            }

            if (souscriptionProvider.souscriptionResponse != null) {
              return _buildSuccessState(screenWidth, textScaleFactor);
            }

            return _buildsouscriptionForm(
              authProvider.currentUser,
              screenWidth,
              textScaleFactor,
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth, double textScaleFactor) {
    final titleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final iconSize = screenWidth < 360 ? 20 : 24;
    
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.primary,
          size: iconSize.toDouble(),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Souscription',
        style: GoogleFonts.poppins(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState(double screenWidth, double textScaleFactor) {
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final spacing = screenWidth < 360 ? 12.0 : 16.0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: spacing),
          Text(
            'Chargement...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String error,
    double screenWidth,
    double textScaleFactor,
  ) {
    final padding = screenWidth < 360 ? 16.0 : 24.0;
    final iconSize = screenWidth < 360 ? 48.0 : 64.0;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final errorFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final buttonFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final spacing1 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = screenWidth < 360 ? 6.0 : 8.0;
    final spacing3 = screenWidth < 360 ? 20.0 : 24.0;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: iconSize, color: AppColors.error),
            SizedBox(height: spacing1),
            Text(
              'Erreur',
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing2),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: errorFontSize,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing3),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 360 ? 20.0 : 24.0,
                  vertical: screenWidth < 360 ? 12.0 : 14.0,
                ),
              ),
              child: Text(
                'Retour',
                style: GoogleFonts.poppins(fontSize: buttonFontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(double screenWidth, double textScaleFactor) {
    final padding = screenWidth < 360 ? 16.0 : 24.0;
    final iconSize = screenWidth < 360 ? 48.0 : 64.0;
    final titleFontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    final messageFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final buttonFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final spacing1 = screenWidth < 360 ? 12.0 : 16.0;
    final spacing2 = screenWidth < 360 ? 6.0 : 8.0;
    final spacing3 = screenWidth < 360 ? 20.0 : 24.0;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: iconSize,
              color: AppColors.success,
            ),
            SizedBox(height: spacing1),
            Text(
              'Souscription réussie !',
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing2),
            Text(
              'Votre souscription a été enregistrée avec succès.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: messageFontSize,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing3),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth < 360 ? 14.0 : 16.0,
                  ),
                ),
                child: Text(
                  'Retour au tableau de bord',
                  style: GoogleFonts.poppins(fontSize: buttonFontSize),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildsouscriptionForm(
    User? user,
    double screenWidth,
    double textScaleFactor,
  ) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final horizontalPadding = screenWidth < 360 
        ? 16.0 
        : screenWidth < 600 
            ? 20.0 
            : (screenWidth * 0.08).clamp(20.0, 48.0);
    final verticalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final sectionSpacing = screenWidth < 360 ? 24.0 : 32.0;
    final buttonSpacing = screenWidth < 360 ? 36.0 : 48.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: verticalPadding,
        bottom: verticalPadding + viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          souscriptionSummary(
            simulationResult: widget.simulationResult,
            savedQuote: widget.savedQuote,
            source: widget.source,
            screenWidth: screenWidth,
            textScaleFactor: textScaleFactor,
          ),

          SizedBox(height: sectionSpacing),

          if (_getNecessiteBeneficiaires()) ...[
            if (_isLoadingProduct)
              _buildLoadingProductInfo(screenWidth, textScaleFactor)
            else
              BeneficiairesSelector(
                beneficiaires: _souscriptionViewModel.beneficiaires,
                onBeneficiairesChanged: (beneficiaires) {
                  _souscriptionViewModel.setBeneficiaires(beneficiaires);
                },
                maxBeneficiaires: _getMaxBeneficiaires(),
                necessiteBeneficiaires: _getNecessiteBeneficiaires(),
                screenWidth: screenWidth,
                textScaleFactor: textScaleFactor,
              ),
            SizedBox(height: sectionSpacing),
          ],

          PaymentMethodSelector(
            selectedMethod: _souscriptionViewModel.selectedMethodePaiement,
            onMethodSelected: _souscriptionViewModel.setMethodePaiement,
            hasError: _souscriptionViewModel.hasFieldError('methode_paiement'),
            errorText: _souscriptionViewModel.getFieldError('methode_paiement'),
            screenWidth: screenWidth,
            textScaleFactor: textScaleFactor,
          ),

          SizedBox(height: sectionSpacing),

          Consumer<SouscriptionViewModel>(
            builder: (context, provider, child) {
              return souscriptionForm(
                phoneNumber: provider.numeroTelephone,
                onPhoneChanged: provider.setNumeroTelephone,
                hasError: provider.hasFieldError('numero_telephone'),
                errorText: provider.getFieldError('numero_telephone'),
                selectedPaymentMethod: provider.selectedMethodePaiement,
                screenWidth: screenWidth,
                textScaleFactor: textScaleFactor,
              );
            },
          ),

          SizedBox(height: buttonSpacing),

          _buildSubscribeButton(screenWidth, textScaleFactor),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(double screenWidth, double textScaleFactor) {
    final buttonHeight = screenWidth < 360 ? 48.0 : 50.0;
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    
    return Consumer<SouscriptionViewModel>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          height: buttonHeight,
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
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Souscrire',
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handlesouscription() async {
    final success = await _souscriptionViewModel.souscrire(
      necessiteBeneficiaires: _getNecessiteBeneficiaires(),
    );

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
    // Priorité 1: Produit passé en paramètre
    if (widget.product != null && widget.product!.maxBeneficiaires > 0) {
      return widget.product!.maxBeneficiaires;
    }

    // Priorité 2: Produit chargé dynamiquement
    if (_loadedProduct != null && _loadedProduct!.maxBeneficiaires > 0) {
      return _loadedProduct!.maxBeneficiaires;
    }

    // Fallback: Estimation basée sur les bénéficiaires existants
    if (widget.source == 'simulation' && widget.simulationResult != null) {
      final existingCount = widget.simulationResult!.beneficiaires.length;
      if (existingCount > 0) {
        return existingCount + 2;
      }
    } else if (widget.source == 'saved_quote' && widget.savedQuote != null) {
      final existingCount = widget.savedQuote!.beneficiaires?.length ?? 0;
      if (existingCount > 0) {
        return existingCount + 2;
      }
    }

    // Valeur par défaut minimale
    return 3;
  }

  bool _getNecessiteBeneficiaires() {
    // Priorité 1: Produit passé en paramètre
    if (widget.product != null) {
      return widget.product!.necessiteBeneficiaires;
    }

    // Priorité 2: Produit chargé dynamiquement
    if (_loadedProduct != null) {
      return _loadedProduct!.necessiteBeneficiaires;
    }

    // Fallback: Si des bénéficiaires existent déjà, c'est probablement requis
    if (widget.source == 'simulation' && widget.simulationResult != null) {
      return widget.simulationResult!.beneficiaires.isNotEmpty;
    } else if (widget.source == 'saved_quote' && widget.savedQuote != null) {
      return widget.savedQuote!.beneficiaires?.isNotEmpty ?? false;
    }

    // Par défaut, on assume que les bénéficiaires sont requis pour éviter les erreurs
    return true;
  }

  Widget _buildLoadingProductInfo(double screenWidth, double textScaleFactor) {
    final padding = screenWidth < 360 ? 12.0 : 16.0;
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final fontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final spacing = screenWidth < 360 ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              'Chargement de la configuration du produit...',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
