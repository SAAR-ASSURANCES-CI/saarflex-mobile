import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/info_assure_app_bar.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/info_assure_header.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/custom_text_field.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/custom_date_field.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/custom_dropdown_field.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/identity_images_section.dart';
import 'package:saarflex_app/presentation/features/simulation/widgets/continue_button.dart';
import 'package:saarflex_app/presentation/features/simulation/viewmodels/simulation_viewmodel.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const InfoAssureAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                InfoAssureHeader(produit: widget.produit),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 32),
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
                const SizedBox(height: 32),
                ContinueButton(isEnabled: _isFormValid, onPressed: _continue),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
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
        const SizedBox(height: 20),
        CustomDateField(
          fieldName: 'date_naissance',
          label: 'Date de naissance',
          controller: _dateController,
          validator: _validateRequired,
          onChanged: (date) => _updateFormData('date_naissance', date),
        ),
        const SizedBox(height: 20),
        CustomDropdownField(
          fieldName: 'type_piece_identite',
          label: 'Type de pièce',
          items: _typesPiece,
          value: _formData['type_piece_identite'],
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('type_piece_identite', value),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          fieldName: 'numero_piece_identite',
          label: 'Numéro de pièce',
          isRequired: true,
          icon: Icons.badge_outlined,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('numero_piece_identite', value),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          fieldName: 'telephone',
          label: 'Téléphone',
          isRequired: true,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('telephone', value),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          fieldName: 'adresse',
          label: 'Adresse',
          isRequired: true,
          icon: Icons.home_outlined,
          validator: _validateRequired,
          onChanged: (value) => _updateFormData('adresse', value),
        ),
        const SizedBox(height: 20),
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimulationScreen(
            produit: widget.produit,
            assureEstSouscripteur: false, // L'assuré n'est PAS le souscripteur
            informationsAssure: infosAEnvoyer,
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
