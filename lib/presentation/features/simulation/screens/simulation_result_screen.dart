import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_success_header.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_product_info.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_main_card.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_details_card.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_assure_info_card.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_save_section.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_action_buttons.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/result_save_confirmation_dialog.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/upload_status_indicator.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'package:saarflex_app/presentation/features/contracts/screens/contracts_screen.dart';
import 'package:saarflex_app/presentation/features/products/screens/product_list_screen.dart';
import 'package:saarflex_app/presentation/features/souscription/screens/souscription_screen.dart';

class SimulationResultScreen extends StatefulWidget {
  final Product produit;
  final SimulationResponse resultat;

  const SimulationResultScreen({
    super.key,
    required this.produit,
    required this.resultat,
  });

  @override
  State<SimulationResultScreen> createState() => _SimulationResultScreenState();
}

class _SimulationResultScreenState extends State<SimulationResultScreen> {
  late SimulationResultViewModel _resultViewModel;
  final GlobalKey _saveSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _resultViewModel = SimulationResultViewModel();
    _resultViewModel.setResultat(widget.resultat);
  }

  @override
  void dispose() {
    _resultViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _resultViewModel,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const ResultSuccessHeader(),
              const SizedBox(height: 32),

              ResultProductInfo(
                produit: widget.produit,
                resultat: widget.resultat,
              ),
              const SizedBox(height: 24),

              if (!widget.resultat.assureEstSouscripteur &&
                  widget.resultat.informationsAssure != null) ...[
                ResultAssureInfoCard(resultat: widget.resultat),
                const SizedBox(height: 24),
              ],

              ResultMainCard(resultat: widget.resultat),
              const SizedBox(height: 24),
              ResultDetailsCard(resultat: widget.resultat),
              const SizedBox(height: 24),

              Consumer<AuthViewModel>(
                builder: (context, authProvider, child) {
                  if (authProvider.isLoggedIn) {
                    return Column(
                      children: [
                        Consumer<SimulationViewModel>(
                          builder: (context, simulationViewModel, child) {
                            return UploadStatusIndicator(
                              isUploading:
                                  simulationViewModel.isUploadingImages,
                              hasUploadedImages:
                                  simulationViewModel.hasUploadedImages,
                              onRetry: () =>
                                  _retryImageUpload(simulationViewModel),
                            );
                          },
                        ),
                        Consumer<SimulationViewModel>(
                          builder: (context, simulationViewModel, child) {
                            if (simulationViewModel.isUploadingImages) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('Upload des images en cours...'),
                                      ],
                                    ),
                                    backgroundColor: AppColors.primary,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              });
                            } else if (simulationViewModel.hasUploadedImages) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 12),
                                        Text('Images uploadées avec succès !'),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              });
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 16),
                        ResultSaveSection(
                          key: _saveSectionKey,
                          resultat: widget.resultat,
                          viewModel: _resultViewModel,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar:
            Consumer2<SimulationResultViewModel, AuthViewModel>(
              builder: (context, resultViewModel, authProvider, child) {
                return ResultActionButtons(
                  resultat: widget.resultat,
                  viewModel: resultViewModel,
                  onSave: _showSaveConfirmationDialog,
                  onSubscribe: _procederSouscription,
                );
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
        icon: Icon(Icons.close_rounded, color: AppColors.primary),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        },
      ),
      title: Text(
        'Résultat de simulation',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  void _showSaveConfirmationDialog() {
    final saveSectionState = _saveSectionKey.currentState;
    if (saveSectionState == null) return;

    final typedState = saveSectionState as dynamic;
    final nomDevis = typedState.nomController.text.trim();
    final notes = typedState.notesController.text.trim();
    if (nomDevis.isEmpty) {
      _resultViewModel.setValidationError(
        'nom_personnalise',
        'Le nom du devis est obligatoire',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez saisir un nom pour votre devis',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );

      return;
    }

    ResultSaveConfirmationDialog.show(
      context: context,
      nomDevis: nomDevis,
      notes: notes,
      resultat: widget.resultat,
      viewModel: _resultViewModel,
      onNewSimulation: _naviguerVersProduits,
      onViewQuotes: _naviguerVersContrats,
    );
  }

  void _procederSouscription() {
    final saveSectionState = _saveSectionKey.currentState;
    if (saveSectionState == null) return;

    final typedState = saveSectionState as dynamic;
    final nomDevis = typedState.nomController.text.trim();
    if (nomDevis.isEmpty) {
      _resultViewModel.setValidationError(
        'nom_personnalise',
        'Le nom du devis est obligatoire',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez saisir un nom pour votre devis',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => souscriptionScreen(
          simulationResult: widget.resultat,
          product: widget.produit,
          source: 'simulation',
        ),
      ),
    );
  }

  void _naviguerVersProduits() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProductListScreen()),
    );
  }

  void _retryImageUpload(SimulationViewModel simulationViewModel) {
    if (simulationViewModel.devisId != null) {
      simulationViewModel.uploadImagesAfterSave(
        simulationViewModel.devisId!,
        context,
      );
    }
  }

  void _naviguerVersContrats() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ContractsScreen(initialTab: 0),
      ),
    );
  }
}
