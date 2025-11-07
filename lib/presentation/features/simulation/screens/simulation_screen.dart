import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/dynamic_form_field.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/simulation_app_bar.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/simulation_loading_state.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/simulation_error_state.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/simulation_product_header.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/simulation_form_title.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/simulation_bottom_button.dart';
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
  VoidCallback? _calculationListener;

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
      final simulationProvider = context.read<SimulationViewModel>();
      simulationProvider.initierSimulation(
        produitId: widget.produit.id,
        assureEstSouscripteur: widget.assureEstSouscripteur,
        informationsAssure: widget.informationsAssure,
      );
      if (_isSaarNansou(widget.produit.nom)) {
        void checkAndCalculate() {
          if (!simulationProvider.isLoadingCriteres && 
              simulationProvider.criteresProduit.isNotEmpty) {
            if (_calculationListener != null) {
              simulationProvider.removeListener(_calculationListener!);
              _calculationListener = null;
            }
            simulationProvider.calcAutoDureeWithContext(context);
          }
        }
        _calculationListener = checkAndCalculate;
        simulationProvider.addListener(_calculationListener!);
        checkAndCalculate();
      }
    });
  }

  bool _isSaarNansou(String nomProduit) {
    final nomLower = nomProduit.toLowerCase();
    return nomLower.contains('nansou') || nomLower.contains('saar nansou');
  }

  @override
  void dispose() {
    if (_calculationListener != null) {
      context.read<SimulationViewModel>().removeListener(_calculationListener!);
      _calculationListener = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationViewModel>(
      builder: (context, simulationProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: SimulationAppBar(produit: widget.produit),
          body: simulationProvider.isLoadingCriteres
              ? const SimulationLoadingState()
              : simulationProvider.hasError
              ? SimulationErrorState(provider: simulationProvider)
              : _buildFormContent(simulationProvider),
          bottomNavigationBar: simulationProvider.isLoadingCriteres
              ? null
              : SimulationBottomButton(
                  provider: simulationProvider,
                  onSimulate: () => _simuler(simulationProvider),
                ),
        );
      },
    );
  }

  Widget _buildFormContent(SimulationViewModel provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SimulationProductHeader(produit: widget.produit),
            const SizedBox(height: 32),
            const SimulationFormTitle(),
            const SizedBox(height: 24),
            ..._buildFormFields(provider),

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

  List<Widget> _buildFormFields(SimulationViewModel provider) {
    final criteres = provider.criteresProduitTries;
    final isSaarNansou = _isSaarNansou(widget.produit.nom);

    return criteres.map((critere) {
      final besoinFormatage = _critereNecessiteFormatage(critere);
      final nomLower = critere.nom.toLowerCase();
      final isDureeCotisation = nomLower.contains('durée') || 
                                 nomLower.contains('duree') || 
                                 nomLower.contains('cotisation');
      final enabled = !(isSaarNansou && isDureeCotisation);
      String? infoText;
      if (isSaarNansou && isDureeCotisation && !enabled) {
        infoText = 'Cette durée est déterminée automatiquement selon votre âge.';
      }

      return DynamicFormField(
        critere: critere,
        valeur: provider.criteresReponses[critere.nom],
        onChanged: (valeur) {
          provider.updateCritereReponse(critere.nom, valeur);
        },
        errorText: provider.getValidationError(critere.nom),
        formatMilliers: besoinFormatage,
        enabled: enabled,
        infoText: infoText,
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
              style: const TextStyle(
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

  Future<void> _simuler(SimulationViewModel provider) async {
    try {
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
