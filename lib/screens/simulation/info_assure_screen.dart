import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/constants/colors.dart';
import 'package:saarflex_app/screens/simulation/simulation_screen.dart';
import 'package:saarflex_app/models/product_model.dart';

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

  final List<String> _typesPiece = [
    'Carte d\'identité',
    'Passeport', 
    'Permis de conduire',
  ];

  @override
  void initState() {
    super.initState();
    // Écouter les changements pour valider le formulaire en temps réel
    _dateController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid && _formData['date_naissance'] != null;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informations de l\'assuré',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTextField('nom_complet', 'Nom complet', true, Icons.person_outline),
              const SizedBox(height: 20),
              _buildDateField('date_naissance', 'Date de naissance'),
              const SizedBox(height: 20),
              _buildDropdown('type_piece_identite', 'Type de pièce'),
              const SizedBox(height: 20),
              _buildTextField('numero_piece_identite', 'Numéro de pièce', true, Icons.badge_outlined),
              const SizedBox(height: 20),
              _buildTextField('telephone', 'Téléphone', true, Icons.phone_outlined),
              const SizedBox(height: 20),
              _buildTextField('adresse', 'Adresse', true, Icons.home_outlined),
              const SizedBox(height: 20),
              _buildTextField('email', 'Email', false, Icons.email_outlined),
              const SizedBox(height: 32),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.person_search, color: AppColors.white, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Informations de l'assuré",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Renseignez les informations personnelles de l'assuré",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String field, String label, bool required, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Votre $label',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          validator: required 
              ? (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null 
              : null,
          onChanged: (value) {
            _formData[field] = value;
            _validateForm();
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String field, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: 'Sélectionnez un type',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          items: _typesPiece.map((type) => 
            DropdownMenuItem(
              value: type, 
              child: Text(type),
            )
          ).toList(),
          validator: (value) => value == null ? 'Ce champ est obligatoire' : null,
          onChanged: (value) {
            _formData[field] = value;
            _validateForm();
          },
        ),
      ],
    );
  }

  Widget _buildDateField(String field, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          decoration: InputDecoration(
            hintText: 'Sélectionnez une date',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isFormValid ? _validateAndSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppColors.primary
              : AppColors.disabled,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          "Continuer vers la simulation",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      
      setState(() {
        _formData['date_naissance'] = formattedDate;
        _dateController.text = formattedDate;
        _validateForm();
      });
    }
  }

  void _validateAndSubmit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_formData['date_naissance'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une date de naissance'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimulationScreen(
          produit: widget.produit,
          assureEstSouscripteur: false,
          informationsAssure: _formData,
        ),
      ),
    );
  }
}