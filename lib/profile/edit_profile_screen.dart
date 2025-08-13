import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import '../../constants/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _professionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _idExpiryController = TextEditingController();

  String _selectedGender = 'Masculin';
  String _selectedIdType = 'Carte Nationale d\'Identité';

  final List<String> _genderOptions = ['Masculin', 'Féminin'];
  final List<String> _idTypeOptions = [
    'Carte Nationale d\'Identité',
    'Passeport',
    'Permis de Conduire',
    'Carte de Séjour',
  ];

  bool _isLoading = false;
  bool _hasChanges = false; // Variable pour tracker les modifications
  Map<String, dynamic> _originalData = {}; // Stocker les données originales

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _addListeners();
  }

  void _addListeners() {
    // Ajouter des listeners sur tous les controllers
    _firstNameController.addListener(_checkForChanges);
    _birthDateController.addListener(_checkForChanges);
    _birthPlaceController.addListener(_checkForChanges);
    _nationalityController.addListener(_checkForChanges);
    _professionController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _idNumberController.addListener(_checkForChanges);
    _idExpiryController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    // Comparer les valeurs actuelles avec les originales
    final currentData = {
      'nom': _firstNameController.text.trim(),
      'email': _emailController.text.trim(),
      'telephone': _phoneController.text.trim(),
      'lieu_naissance': _birthPlaceController.text.trim(),
      'nationalite': _nationalityController.text.trim(),
      'profession': _professionController.text.trim(),
      'adresse': _addressController.text.trim(),
      'numero_piece_identite': _idNumberController.text.trim(),
      'date_naissance': _birthDateController.text.trim(),
      'date_expiration': _idExpiryController.text.trim(),
      'sexe': _selectedGender,
      'type_piece_identite': _selectedIdType,
    };

    bool hasChanged = false;
    for (String key in currentData.keys) {
      if (currentData[key] != _originalData[key]) {
        hasChanged = true;
        break;
      }
    }

    if (_hasChanges != hasChanged) {
      setState(() {
        _hasChanges = hasChanged;
      });
    }
  }

  void _onDropdownChanged() {
    _checkForChanges();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      _firstNameController.text = user.nom;
      _emailController.text = user.email;
      _phoneController.text = user.telephone ?? '';
      _birthPlaceController.text = user.lieuNaissance ?? '';
      _nationalityController.text = user.nationalite ?? '';
      _professionController.text = user.profession ?? '';
      _addressController.text = user.adresse ?? '';
      _idNumberController.text = user.numeroPieceIdentite ?? '';
      
      if (user.sexe != null) {
        _selectedGender = user.sexe == 'masculin' ? 'Masculin' : 'Féminin';
      }
      
      if (user.typePieceIdentite != null) {
        _selectedIdType = _getTypePieceIdentiteLabel(user.typePieceIdentite!);
      }

      // Stocker les données originales pour comparaison
      _originalData = {
        'nom': user.nom,
        'email': user.email,
        'telephone': user.telephone ?? '',
        'lieu_naissance': user.lieuNaissance ?? '',
        'nationalite': user.nationalite ?? '',
        'profession': user.profession ?? '',
        'adresse': user.adresse ?? '',
        'numero_piece_identite': user.numeroPieceIdentite ?? '',
        'date_naissance': '',
        'date_expiration': '',
        'sexe': _selectedGender,
        'type_piece_identite': _selectedIdType,
      };
    }
  }

  String _getTypePieceIdentiteLabel(String type) {
    switch (type.toLowerCase()) {
      case 'cni':
        return 'Carte Nationale d\'Identité';
      case 'passport':
        return 'Passeport';
      case 'permis':
        return 'Permis de Conduire';
      case 'carte_sejour':
        return 'Carte de Séjour';
      default:
        return 'Carte Nationale d\'Identité';
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email est requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Téléphone est requis';
    }
    if (value.length < 8) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  void _showMessage(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 40),
                    _buildPersonalSection(),
                    const SizedBox(height: 32),
                    _buildContactSection(),
                    const SizedBox(height: 32),
                    _buildIdentitySection(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Édition du profil",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = context.read<AuthProvider>().currentUser;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: user?.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_rounded,
                              color: AppColors.white,
                              size: 45,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size: 45,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Modifiez vos informations",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Les champs marqués * sont obligatoires",
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

  Widget _buildPersonalSection() {
    return _buildFormSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'Nom complet',
          isRequired: true,
          validator: (value) => _validateRequired(value, 'Le nom'),
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          value: _selectedGender,
          items: _genderOptions,
          label: 'Sexe',
          isRequired: true,
          onChanged: (value) {
            setState(() => _selectedGender = value!);
            _onDropdownChanged();
          },
        ),
        const SizedBox(height: 20),
        _buildDateField(
          controller: _birthDateController,
          label: 'Date de naissance',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _birthPlaceController,
          label: 'Lieu de naissance',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _nationalityController,
          label: 'Nationalité',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _professionController,
          label: 'Profession',
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildFormSection(
      title: "Coordonnées",
      icon: Icons.contact_phone_rounded,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Adresse email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          isRequired: true,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: 'Adresse de résidence',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildIdentitySection() {
    return _buildFormSection(
      title: "Pièce d'identité",
      icon: Icons.badge_rounded,
      children: [
        _buildDropdownField(
          value: _selectedIdType,
          items: _idTypeOptions,
          label: 'Type de pièce',
          onChanged: (value) {
            setState(() => _selectedIdType = value!);
            _onDropdownChanged();
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _idNumberController,
          label: 'Numéro de pièce',
        ),
        const SizedBox(height: 20),
        _buildDateField(
          controller: _idExpiryController,
          label: 'Date d\'expiration',
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Saisir $label',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    bool isRequired = false,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Sélectionner une date',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onTap: () => _selectDate(controller),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final bool isEnabled = _hasChanges && !_isLoading;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _saveProfile : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
          foregroundColor: isEnabled ? AppColors.white : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Enregistrement...",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                "Enregistrer les modifications",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        controller.text = "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
        _checkForChanges();
      }
      
    } catch (e) {
      // Gestion d'erreur silencieuse ou affichage d'un message à l'utilisateur
    }
  }

  Future<void> _saveProfile() async {
    // Validation simple : vérifier que les champs requis ne sont pas vides
    if (_firstNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showMessage(
        "Veuillez remplir tous les champs obligatoires",
        AppColors.warning,
        Icons.warning_rounded,
      );
      return;
    }

    // Validation simple de l'email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      _showMessage(
        "Format d'email invalide",
        AppColors.warning,
        Icons.warning_rounded,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      final profileData = {
        'nom': _firstNameController.text.trim(),
        'lieu_naissance': _birthPlaceController.text.trim(),
        'sexe': _selectedGender.toLowerCase(),
        'nationalite': _nationalityController.text.trim(),
        'profession': _professionController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'adresse': _addressController.text.trim(),
        'numero_piece_identite': _idNumberController.text.trim(),
        'type_piece_identite': _selectedIdType,
      };

      final success = await authProvider.updateProfile(profileData);

      if (success) {
        _showMessage(
          "Profil mis à jour avec succès !",
          AppColors.success,
          Icons.check_circle_outline,
        );
        
        // Réinitialiser l'état des modifications après sauvegarde réussie
        _loadUserData(); // Recharger les données comme nouvelles données "originales"
        setState(() {
          _hasChanges = false;
        });
        
        // Retourner à l'écran précédent après un délai
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showMessage(
          "Erreur lors de la mise à jour du profil",
          AppColors.error,
          Icons.error_outline,
        );
      }
    } catch (e) {
      _showMessage(
        "Une erreur s'est produite. Veuillez réessayer.",
        AppColors.error,
        Icons.error_outline,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Retirer les listeners avant de disposer les controllers
    _firstNameController.removeListener(_checkForChanges);
    _birthDateController.removeListener(_checkForChanges);
    _birthPlaceController.removeListener(_checkForChanges);
    _nationalityController.removeListener(_checkForChanges);
    _professionController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _emailController.removeListener(_checkForChanges);
    _addressController.removeListener(_checkForChanges);
    _idNumberController.removeListener(_checkForChanges);
    _idExpiryController.removeListener(_checkForChanges);

    _firstNameController.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _nationalityController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _idNumberController.dispose();
    _idExpiryController.dispose();
    super.dispose();
  }
}