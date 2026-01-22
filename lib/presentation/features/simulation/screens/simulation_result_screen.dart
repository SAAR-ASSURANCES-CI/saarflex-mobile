import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_result_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_success_header.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_product_info.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_main_card.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_details_card.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_assure_info_card.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_save_section.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_action_buttons.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/result_save_confirmation_dialog.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/upload_status_indicator.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/contracts/screens/contracts_screen.dart';
import 'package:saarciflex_app/presentation/features/products/screens/product_list_screen.dart';
import 'package:saarciflex_app/presentation/features/souscription/screens/souscription_screen.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final textScaleFactor = MediaQuery.of(context).textScaleFactor;
          final viewInsets = MediaQuery.of(context).viewInsets;
          
          final horizontalPadding = screenWidth < 360 
              ? 16.0 
              : screenWidth < 600 
                  ? 20.0 
                  : (screenWidth * 0.08).clamp(20.0, 48.0);
          final verticalPadding = screenHeight < 600 ? 16.0 : 20.0;
          
          final headerSpacing = screenHeight < 600 ? 24.0 : 32.0;
          final cardSpacing = screenHeight < 600 ? 20.0 : 24.0;
          final saveSpacing = screenHeight < 600 ? 12.0 : 16.0;
          final bottomSpacing = screenHeight < 600 ? 60.0 : 80.0;
          
          return Scaffold(
            backgroundColor: AppColors.background,
            resizeToAvoidBottomInset: true,
            appBar: _buildAppBar(screenWidth, textScaleFactor),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: verticalPadding,
                bottom: bottomSpacing + viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              ResultSuccessHeader(
                screenWidth: screenWidth,
                textScaleFactor: textScaleFactor,
              ),
              SizedBox(height: headerSpacing),

              ResultProductInfo(
                produit: widget.produit,
                resultat: widget.resultat,
                screenWidth: screenWidth,
                textScaleFactor: textScaleFactor,
              ),
              SizedBox(height: cardSpacing),

              if (!widget.resultat.assureEstSouscripteur &&
                  widget.resultat.informationsAssure != null) ...[
                ResultAssureInfoCard(
                  resultat: widget.resultat,
                  screenWidth: screenWidth,
                  textScaleFactor: textScaleFactor,
                ),
                SizedBox(height: cardSpacing),
              ],

              ResultMainCard(
                resultat: widget.resultat,
                screenWidth: screenWidth,
                textScaleFactor: textScaleFactor,
              ),
              SizedBox(height: cardSpacing),
              ResultDetailsCard(
                resultat: widget.resultat,
                produit: widget.produit,
                screenWidth: screenWidth,
                textScaleFactor: textScaleFactor,
              ),
              SizedBox(height: cardSpacing),

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
                              screenWidth: screenWidth,
                              textScaleFactor: textScaleFactor,
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
                                          width: screenWidth < 360 ? 14.0 : 16.0,
                                          height: screenWidth < 360 ? 14.0 : 16.0,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth < 360 ? 10.0 : 12.0),
                                        Flexible(
                                          child: Text(
                                            'Upload des images en cours...',
                                            style: FontHelper.poppins(
                                              fontSize: (14.0 / textScaleFactor).clamp(12.0, 16.0),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                                          size: screenWidth < 360 ? 14.0 : 16.0,
                                        ),
                                        SizedBox(width: screenWidth < 360 ? 10.0 : 12.0),
                                        Flexible(
                                          child: Text(
                                            'Images uploadées avec succès !',
                                            style: FontHelper.poppins(
                                              fontSize: (14.0 / textScaleFactor).clamp(12.0, 16.0),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                        SizedBox(height: saveSpacing),
                        ResultSaveSection(
                          key: _saveSectionKey,
                          resultat: widget.resultat,
                          viewModel: _resultViewModel,
                          screenWidth: screenWidth,
                          textScaleFactor: textScaleFactor,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
                  SizedBox(height: bottomSpacing),
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
                      screenWidth: screenWidth,
                      textScaleFactor: textScaleFactor,
                    );
                  },
                ),
          );
        },
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
          Icons.close_rounded,
          color: AppColors.primary,
          size: iconSize.toDouble(),
        ),
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
        style: FontHelper.poppins(
          fontSize: titleFontSize,
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
            style: FontHelper.poppins(
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
