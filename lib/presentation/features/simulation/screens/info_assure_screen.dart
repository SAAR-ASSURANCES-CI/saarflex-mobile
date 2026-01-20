import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarciflex_app/presentation/features/simulation/screens/info_vehicule_screen.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/info_assure_app_bar.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/info_assure_header.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/custom_text_field.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/custom_date_field.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/custom_dropdown_field.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/identity_images_section.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/continue_button.dart';
import 'package:saarciflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

class InfoAssureScreen extends StatefulWidget {
  final Product produit;

  const InfoAssureScreen({super.key, required this.produit});

  @override
  State<InfoAssureScreen> createState() => _InfoAssureScreenState();
}

class _InfoAssureScreenState extends State<InfoAssureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final Map<String, dynamic> _formData = {};

  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final List<String> _typesPiece = ['Carte d\'identité', 'Passeport'];

  @override
  void initState() {
    super.initState();
    _dateController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final simulationViewModel = context.read<SimulationViewModel>();
    final hasRequiredImages = simulationViewModel.hasTempImages;

    setState(() {
      _isFormValid =
          isValid && _formData['date_naissance'] != null && hasRequiredImages;
    });
  }

  @override
  void dispose() {
    _dateController.removeListener(_validateForm);
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final horizontalPadding = screenWidth < 360 
        ? 16.0 
        : screenWidth < 600 
            ? 24.0 
            : (screenWidth * 0.08).clamp(24.0, 48.0);
    final verticalPadding = screenHeight < 600 ? 16.0 : 24.0;
    final bottomPadding = 24.0;
    
    final topSpacing = screenHeight < 600 ? 10.0 : 16.0;
    final headerSpacing = screenHeight < 600 ? 24.0 : 32.0;
    final sectionSpacing = screenHeight < 600 ? 24.0 : 32.0;
    final bottomSpacing = screenHeight < 600 ? 24.0 : 32.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: const InfoAssureAppBar(),
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
                InfoAssureHeader(produit: widget.produit),
                SizedBox(height: headerSpacing),
                _buildFormFields(screenHeight),
                SizedBox(height: sectionSpacing),
                Consumer<SimulationViewModel>(
                  builder: (context, simulationViewModel, child) {
                    return IdentityImagesSection(
                      identityType: _formData['type_piece_identite'],
                      isUploadingRecto: false, // Pas d'upload immédiat
                      isUploadingVerso: false, // Pas d'upload immédiat
                      onPickRecto: () => _pickImage(true),
                      onPickVerso: () => _pickImage(false),
                      rectoImage: simulationViewModel.tempRectoImage,
                      versoImage: simulationViewModel.tempVersoImage,
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
          fieldName: 'nom_complet',
          label: 'Nom complet',
          isRequired: true,
          icon: Icons.person_outline,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('nom_complet', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomDateField(
          fieldName: 'date_naissance',
          label: 'Date de naissance',
          controller: _dateController,
          validator: _validateRequired,
          onChanged: (date) => _updateFormData('date_naissance', date),
        ),
        SizedBox(height: fieldSpacing),
        CustomDropdownField(
          fieldName: 'type_piece_identite',
          label: 'Type de pièce',
          items: _typesPiece,
          value: _formData['type_piece_identite'],
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('type_piece_identite', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'numero_piece_identite',
          label: 'Numéro de pièce',
          isRequired: true,
          icon: Icons.badge_outlined,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('numero_piece_identite', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'telephone',
          label: 'Téléphone',
          isRequired: true,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('telephone', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'adresse',
          label: 'Adresse',
          isRequired: true,
          icon: Icons.home_outlined,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('adresse', value),
        ),
        SizedBox(height: fieldSpacing),
        CustomTextField(
          fieldName: 'email',
          label: 'Email',
          isRequired: false,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          onChanged: (value) => _updateFormData('email', value),
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

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Veuillez entrer un email valide';
      }
    }
    return null;
  }

  Future<void> _pickImage(bool isRecto) async {
    final simulationViewModel = context.read<SimulationViewModel>();
    await simulationViewModel.pickImage(isRecto, context);
    _validateForm();
  }

  void _continue() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.disabled;
      });

      Map<String, dynamic> infosAEnvoyer = Map.from(_formData);
      if (infosAEnvoyer.containsKey('date_naissance')) {
        final dateNaissance = infosAEnvoyer['date_naissance'];
        if (dateNaissance is DateTime) {
          final day = dateNaissance.day.toString().padLeft(2, '0');
          final month = dateNaissance.month.toString().padLeft(2, '0');
          infosAEnvoyer['date_naissance'] = '$day-$month-${dateNaissance.year}';
        }
      }

      final simulationViewModel = context.read<SimulationViewModel>();
      simulationViewModel.updateInformationsAssure(infosAEnvoyer);

      if (widget.produit.necessiteInformationsVehicule) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InfoVehiculeScreen(
              produit: widget.produit,
              assureEstSouscripteur: false,
              informationsAssure: infosAEnvoyer,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SimulationScreen(
              produit: widget.produit,
              assureEstSouscripteur: false,
              informationsAssure: infosAEnvoyer,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }
}
