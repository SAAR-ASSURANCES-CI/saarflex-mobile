import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/critere_tarification_model.dart';
import '../../providers/simulation_provider.dart';
import '../../widgets/dynamic_form_field.dart';
import '../../models/product_model.dart';
import '../../widgets/beneficiaires_collection_widget.dart';
import 'simulation_result_screen.dart';

class SimulationScreen extends StatefulWidget {
  final Product produit;
  final bool assureEstSouscripteur;
  final String? userId;
  final Map<String, dynamic>? informationsAssure;

  const SimulationScreen({
    super.key,
    required this.produit,
    required this.assureEstSouscripteur,
    this.userId,
    this.informationsAssure,
  });
  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Dans SimulationScreen - ajoutez cette méthode
  bool _critereNecessiteFormatage(CritereTarification critere) {
    const champsAvecSeparateurs = [
      'capital',
      'capital_assure',
      'montant',
      'prime',
      'franchise',
      'plafond',
      'souscription',
      'assurance',
    ];

    final nomCritereLower = critere.nom.toLowerCase();

    for (final motCle in champsAvecSeparateurs) {
      final contains = nomCritereLower.contains(motCle);
      if (contains) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimulationProvider>().initierSimulation(
        produitId: widget.produit.id,
        assureEstSouscripteur: widget.assureEstSouscripteur,
        informationsAssure: widget.informationsAssure,
      );
    });
  }

  @override
  void dispose() {
    // Nettoyer les ressources si nécessaire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationProvider>(
      builder: (context, simulationProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: simulationProvider.isLoadingCriteres
              ? _buildLoadingState()
              : simulationProvider.hasError
              ? _buildErrorState(simulationProvider)
              : _buildFormContent(simulationProvider),
          bottomNavigationBar: simulationProvider.isLoadingCriteres
              ? null
              : _buildBottomButton(simulationProvider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulation',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            widget.produit.nom,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des critÃ¨res...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PrÃ©paration du formulaire personnalisÃ©',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SimulationProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Une erreur est survenue',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.chargerCriteresProduit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'RÃ©essayer',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(SimulationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            const SizedBox(height: 32),
            _buildFormTitle(),
            const SizedBox(height: 24),
            ..._buildFormFields(provider),

            // Section bénéficiaires - affichée seulement si nécessaire
            if (widget.produit.necessiteBeneficiaires) ...[
              const SizedBox(height: 24),
              BeneficiairesCollectionWidget(
                maxBeneficiaires: widget.produit.maxBeneficiaires,
                productName: widget.produit.nom,
              ),
            ],
            if (provider.hasError) ...[
              const SizedBox(height: 16),
              _buildFormError(provider.errorMessage!),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: widget.produit.type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.produit.type.icon,
              color: widget.produit.type.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.produit.nom,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.produit.type.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Renseignez vos informations',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complètez les champs ci-dessous pour obtenir votre devis personnalisé.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields(SimulationProvider provider) {
    final criteres = provider.criteresProduitTries;

    return criteres.map((critere) {
      final besoinFormatage = _critereNecessiteFormatage(critere);

      return DynamicFormField(
        critere: critere,
        valeur: provider.criteresReponses[critere.nom],
        onChanged: (valeur) {
          provider.updateCritereReponse(critere.nom, valeur);
        },
        errorText: provider.getValidationError(critere.nom),
        formatMilliers: besoinFormatage,
      );
    }).toList();
  }

  Widget _buildFormError(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(SimulationProvider provider) {
    // Vérifier si les bénéficiaires sont requis et complets
    bool canSimulate = provider.canSimulate;
    if (widget.produit.necessiteBeneficiaires) {
      final beneficiaires = provider.beneficiaires;
      canSimulate =
          canSimulate &&
          beneficiaires.length == widget.produit.maxBeneficiaires;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canSimulate ? () => _simuler(provider) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSimulate
                ? AppColors.primary
                : AppColors.textSecondary,
            foregroundColor: AppColors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: provider.isSimulating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Obtenir mon devis',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // Dans simulation_screen.dart - méthode _simuler
  Future<void> _simuler(SimulationProvider provider) async {
    try {
      // Vérifier si les bénéficiaires sont requis et complets
      if (widget.produit.necessiteBeneficiaires) {
        final beneficiaires = provider.beneficiaires;
        if (beneficiaires.length != widget.produit.maxBeneficiaires) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Vous devez ajouter ${widget.produit.maxBeneficiaires} bénéficiaire(s) pour ce produit avant de pouvoir simuler votre devis.',
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      Map<String, dynamic> infosAEnvoyer = {};

      if (widget.informationsAssure != null) {
        infosAEnvoyer = Map.from(widget.informationsAssure!);

        if (infosAEnvoyer.containsKey('date_naissance')) {
          final dateNaissance = infosAEnvoyer['date_naissance'];
          if (dateNaissance is DateTime) {
            final day = dateNaissance.day.toString().padLeft(2, '0');
            final month = dateNaissance.month.toString().padLeft(2, '0');
            infosAEnvoyer['date_naissance'] =
                '$day-$month-${dateNaissance.year}';
          }
        }
      }

      await provider.simulerDevisSimplifie();

      if (!provider.hasError && provider.dernierResultat != null && mounted) {
        // 🛠️ OPTIMISATION: Utiliser pushReplacement pour éviter l'accumulation d'écrans
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SimulationResultScreen(
              produit: widget.produit,
              resultat: provider.dernierResultat!,
            ),
          ),
        );
      } else if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Erreur lors de la simulation',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur inattendue s\'est produite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
