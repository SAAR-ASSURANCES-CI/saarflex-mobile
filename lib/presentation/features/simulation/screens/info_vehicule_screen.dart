import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/info_vehicule_app_bar.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/info_vehicule_header.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/custom_text_field.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/permis_images_section.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/continue_button.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

class InfoVehiculeScreen extends StatefulWidget {
  final Product produit;
  final bool assureEstSouscripteur;
  final Map<String, dynamic>? informationsAssure;

  const InfoVehiculeScreen({
    super.key,
    required this.produit,
    required this.assureEstSouscripteur,
    this.informationsAssure,
  });

  @override
  State<InfoVehiculeScreen> createState() => _InfoVehiculeScreenState();
}

class _InfoVehiculeScreenState extends State<InfoVehiculeScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final simulationViewModel = context.read<SimulationViewModel>();
    final hasRequiredImages = simulationViewModel.hasTempPermisImages;

    // Vérifier les champs obligatoires
    final requiredFields = [
      'marque',
      'modele',
      'immatriculation',
      'numero_chassis',
      'zone_stationnement',
      'annee_mise_circulation',
    ];

    bool allRequiredFieldsFilled = requiredFields.every(
      (field) => _formData[field] != null && _formData[field].toString().trim().isNotEmpty,
    );

    setState(() {
      _isFormValid = isValid && allRequiredFieldsFilled && hasRequiredImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Padding adaptatif
    final horizontalPadding = screenWidth < 360 
        ? 16.0 
        : screenWidth < 600 
            ? 24.0 
            : (screenWidth * 0.08).clamp(24.0, 48.0);
    final verticalPadding = screenHeight < 600 ? 16.0 : 24.0;
    final bottomPadding = 24.0;
    
    // Espacements adaptatifs
    final topSpacing = screenHeight < 600 ? 10.0 : 16.0;
    final headerSpacing = screenHeight < 600 ? 24.0 : 32.0;
    final sectionSpacing = screenHeight < 600 ? 24.0 : 32.0;
    final bottomSpacing = screenHeight < 600 ? 24.0 : 32.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: const InfoVehiculeAppBar(),
      body: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: verticalPadding,
          bottom: bottomPadding,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: topSpacing),
                InfoVehiculeHeader(produit: widget.produit),
                SizedBox(height: headerSpacing),
                _buildFormFields(screenHeight),
                SizedBox(height: sectionSpacing),
                Consumer<SimulationViewModel>(
                  builder: (context, simulationViewModel, child) {
                    return PermisImagesSection(
                      isUploadingRecto: false, // Pas d'upload immédiat
                      isUploadingVerso: false, // Pas d'upload immédiat
                      onPickRecto: () => _pickImage(true),
                      onPickVerso: () => _pickImage(false),
                      rectoImage: simulationViewModel.tempPermisRectoImage,
                      versoImage: simulationViewModel.tempPermisVersoImage,
                      uploadedRectoUrl: null, // Pas d'URL uploadée ici
                      uploadedVersoUrl: null, // Pas d'URL uploadée ici
                    );
                  },
                ),
                SizedBox(height: sectionSpacing),
                ContinueButton(isEnabled: _isFormValid, onPressed: _continue),
                SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(double screenHeight) {
    final fieldSpacing = screenHeight < 600 ? 16.0 : 20.0;
    
    return Column(
      children: [
        CustomTextField(
          fieldName: 'marque',
          label: 'Marque',
          isRequired: true,
          icon: Icons.directions_car,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('marque', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'modele',
          label: 'Modèle',
          isRequired: true,
          icon: Icons.label,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('modele', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'immatriculation',
          label: 'Immatriculation',
          isRequired: true,
          icon: Icons.confirmation_number,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('immatriculation', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'numero_chassis',
          label: 'Numéro de châssis',
          isRequired: true,
          icon: Icons.qr_code,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('numero_chassis', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'zone_stationnement',
          label: 'Zone de stationnement',
          isRequired: true,
          icon: Icons.location_on,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('zone_stationnement', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'annee_mise_circulation',
          label: 'Année de mise en circulation',
          isRequired: true,
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
          validator: _validateAnnee,
          onChanged: (value) => _updateFormData('annee_mise_circulation', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'couleur',
          label: 'Couleur',
          isRequired: false,
          icon: Icons.palette,
          validator: null,
          onChanged: (value) => _updateFormData('couleur', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'usage',
          label: 'Usage',
          isRequired: false,
          icon: Icons.info,
          validator: null,
          onChanged: (value) => _updateFormData('usage', value),
        ),
      ],
    );
  }

  void _updateFormData(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
    _validateForm();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _validateAnnee(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    final annee = int.tryParse(value);
    if (annee == null) {
      return 'Veuillez entrer une année valide';
    }
    final currentYear = DateTime.now().year;
    if (annee < 1900 || annee > currentYear) {
      return 'Veuillez entrer une année valide';
    }
    return null;
  }

  Future<void> _pickImage(bool isRecto) async {
    final simulationViewModel = context.read<SimulationViewModel>();
    await simulationViewModel.pickPermisImage(isRecto, context);
    _validateForm();
  }

  void _continue() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.disabled;
      });

      // Préparer les données du véhicule
      Map<String, dynamic> infosVehicule = Map.from(_formData);
      
      // Nettoyer les valeurs vides pour les champs optionnels
      if (infosVehicule.containsKey('couleur') && 
          (infosVehicule['couleur'] == null || infosVehicule['couleur'].toString().trim().isEmpty)) {
        infosVehicule.remove('couleur');
      }
      if (infosVehicule.containsKey('usage') && 
          (infosVehicule['usage'] == null || infosVehicule['usage'].toString().trim().isEmpty)) {
        infosVehicule.remove('usage');
      }

      final simulationViewModel = context.read<SimulationViewModel>();
      simulationViewModel.updateInformationsVehicule(infosVehicule);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimulationScreen(
            produit: widget.produit,
            assureEstSouscripteur: widget.assureEstSouscripteur,
            informationsAssure: widget.informationsAssure,
          ),
        ),
      );
    } else {
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }
}

