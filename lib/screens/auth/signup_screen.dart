// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _acceptTerms = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isFormValid = false;
//   AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

//   final _nameFocus = FocusNode();
//   final _emailFocus = FocusNode();
//   final _phoneFocus = FocusNode();
//   final _passwordFocus = FocusNode();
//   final _confirmPasswordFocus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _nameController.addListener(_validateForm);
//     _emailController.addListener(_validateForm);
//     _phoneController.addListener(_validateForm);
//     _passwordController.addListener(_validateForm);
//     _confirmPasswordController.addListener(_validateForm);
//     _autovalidateMode = AutovalidateMode.always;
//   }

//   void _validateForm() {
//     final isValid = _formKey.currentState?.validate() ?? false;
//     setState(() {
//       _isFormValid = isValid && _acceptTerms;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         return Scaffold(
//           backgroundColor: AppColors.background,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back, color: AppColors.primary),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Text(
//               "Créer un compte",
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               autovalidateMode: _autovalidateMode,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   _buildHeader(),
//                   const SizedBox(height: 40),

//                   if (authProvider.errorMessage != null)
//                     _buildErrorMessage(authProvider.errorMessage!),

//                   _buildNameField(),
//                   const SizedBox(height: 20),
//                   _buildEmailField(),
//                   const SizedBox(height: 20),
//                   _buildPhoneField(),
//                   const SizedBox(height: 20),
//                   _buildPasswordField(),
//                   const SizedBox(height: 20),
//                   _buildConfirmPasswordField(),
//                   const SizedBox(height: 24),
//                   _buildTermsCheckbox(),
//                   const SizedBox(height: 40),
//                   _buildCreateAccountButton(authProvider),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(
//           child: Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(Icons.person_add, color: AppColors.white, size: 28),
//           ),
//         ),
//         const SizedBox(height: 24),
//         Text(
//           "Rejoignez SAAR",
//           style: GoogleFonts.poppins(
//             fontSize: 28,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "Créez votre compte et découvrez nos services",
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: AppColors.textSecondary,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorMessage(String message) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.error.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.error.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: AppColors.error, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               message,
//               style: GoogleFonts.poppins(
//                 color: AppColors.error,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNameField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Nom complet",
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _nameController,
//           focusNode: _nameFocus,
//           textInputAction: TextInputAction.next,
//           validator: _validateName,
//           onChanged: (value) => _validateForm(), // Ajout de onChanged
//           onFieldSubmitted: (_) => _emailFocus.requestFocus(),
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: AppColors.textPrimary,
//           ),
//           decoration: _buildInputDecoration(
//             hintText: 'Votre nom complet',
//             icon: Icons.person_outline,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmailField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Email",
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _emailController,
//           focusNode: _emailFocus,
//           keyboardType: TextInputType.emailAddress,
//           textInputAction: TextInputAction.next,
//           validator: _validateEmail,
//           onChanged: (value) => _validateForm(), // Ajout de onChanged
//           onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: AppColors.textPrimary,
//           ),
//           decoration: _buildInputDecoration(
//             hintText: 'Votre adresse email',
//             icon: Icons.email_outlined,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPhoneField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Téléphone",
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _phoneController,
//           focusNode: _phoneFocus,
//           keyboardType: TextInputType.phone,
//           textInputAction: TextInputAction.next,
//           validator: _validatePhone,
//           onChanged: (value) => _validateForm(), // Ajout de onChanged
//           onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: AppColors.textPrimary,
//           ),
//           decoration: _buildInputDecoration(
//             hintText: 'Votre numéro de téléphone',
//             icon: Icons.phone_outlined,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPasswordField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Mot de passe",
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _passwordController,
//           focusNode: _passwordFocus,
//           obscureText: _obscurePassword,
//           textInputAction: TextInputAction.next,
//           validator: _validatePassword,
//           onChanged: (value) => _validateForm(), // Ajout de onChanged
//           onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: AppColors.textPrimary,
//           ),
//           decoration: _buildInputDecoration(
//             hintText: 'Votre mot de passe',
//             icon: Icons.lock_outline,
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                 color: AppColors.textSecondary,
//               ),
//               onPressed: () {
//                 setState(() {
//                   _obscurePassword = !_obscurePassword;
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildConfirmPasswordField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Confirmer le mot de passe",
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _confirmPasswordController,
//           focusNode: _confirmPasswordFocus,
//           obscureText: _obscureConfirmPassword,
//           textInputAction: TextInputAction.done,
//           validator: _validateConfirmPassword,
//           onChanged: (value) => _validateForm(), // Ajout de onChanged
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: AppColors.textPrimary,
//           ),
//           decoration: _buildInputDecoration(
//             hintText: 'Confirmez votre mot de passe',
//             icon: Icons.lock_outline,
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscureConfirmPassword
//                     ? Icons.visibility_off
//                     : Icons.visibility,
//                 color: AppColors.textSecondary,
//               ),
//               onPressed: () {
//                 setState(() {
//                   _obscureConfirmPassword = !_obscureConfirmPassword;
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   InputDecoration _buildInputDecoration({
//     required String hintText,
//     required IconData icon,
//     Widget? suffixIcon,
//   }) {
//     return InputDecoration(
//       hintText: hintText,
//       hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
//       prefixIcon: Icon(icon, color: AppColors.primary),
//       suffixIcon: suffixIcon,
//       filled: true,
//       fillColor: AppColors.surface,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: AppColors.border),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: AppColors.border),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: AppColors.primary, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: AppColors.error),
//       ),
//       contentPadding: const EdgeInsets.all(16),
//     );
//   }

//   Widget _buildTermsCheckbox() {
//     return Row(
//       children: [
//         Checkbox(
//           value: _acceptTerms,
//           onChanged: (value) {
//             setState(() {
//               _acceptTerms = value ?? false;
//               _validateForm();
//             });
//           },
//           activeColor: AppColors.primary,
//         ),
//         Expanded(
//           child: Text(
//             "J'accepte les conditions générales d'utilisation",
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCreateAccountButton(AuthProvider authProvider) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: authProvider.isLoading || !_isFormValid
//             ? null
//             : () => _handleSignup(authProvider),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _isFormValid
//               ? AppColors.primary
//               : AppColors.disabled,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//         child: authProvider.isLoading
//             ? SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : Text(
//                 "Créer mon compte",
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }

//   Future<void> _handleSignup(AuthProvider authProvider) async {
//     if (!_formKey.currentState!.validate() || !_acceptTerms) {
//       if (!_acceptTerms) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Veuillez accepter les conditions d\'utilisation'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//       return;
//     }

//     final success = await authProvider.signup(
//       nom: _nameController.text.trim(),
//       email: _emailController.text.trim(),
//       telephone: _phoneController.text.trim(),
//       password: _passwordController.text,
//     );

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Compte créé avec succès !'),
//           backgroundColor: AppColors.success,
//         ),
//       );
//       Navigator.pushReplacementNamed(context, '/dashboard');
//     }
//   }

//   String? _validateName(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Veuillez saisir votre nom complet';
//     }
//     if (value.trim().length < 2) {
//       return 'Le nom doit contenir au moins 2 caractères';
//     }
//     if (value.trim().length > 50) {
//       return 'Le nom ne doit pas dépasser 50 caractères';
//     }
//     // Vérification que le nom contient au moins des lettres
//     if (!RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(value)) {
//       return 'Le nom doit contenir au moins une lettre';
//     }
//     return null;
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Veuillez saisir votre adresse email';
//     }

//     final cleanValue = value.trim();

//     // Vérification de la présence du @
//     if (!cleanValue.contains('@')) {
//       return 'L\'email doit contenir le symbole @';
//     }

//     // Vérification de la structure générale
//     if (cleanValue.startsWith('@') || cleanValue.endsWith('@')) {
//       return 'Format incorrect : exemple@domaine.com';
//     }

//     // Vérification du domaine
//     final parts = cleanValue.split('@');
//     if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
//       return 'Format incorrect : exemple@domaine.com';
//     }

//     // Vérification de l'extension du domaine
//     if (!parts[1].contains('.') ||
//         parts[1].endsWith('.') ||
//         parts[1].startsWith('.')) {
//       return 'Domaine invalide : exemple@domaine.com';
//     }

//     // Validation complète avec regex
//     if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(cleanValue)) {
//       return 'Adresse email invalide';
//     }

//     return null;
//   }

//   String? _validatePhone(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Veuillez saisir votre numéro de téléphone';
//     }

//     String cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

//     if (cleanPhone.length < 10) {
//       return 'Le numéro doit contenir au moins 10 chiffres';
//     }

//     if (cleanPhone.length > 15) {
//       return 'Le numéro ne doit pas dépasser 15 chiffres';
//     }

//     // Vérification que le numéro ne contient que des chiffres
//     if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
//       return 'Le numéro ne doit contenir que des chiffres';
//     }

//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Veuillez saisir votre mot de passe';
//     }

//     if (value.length < 8) {
//       return 'Le mot de passe doit contenir au moins 8 caractères';
//     }

//     // Vérification des caractères requis
//     List<String> missing = [];

//     if (!RegExp(r'[a-z]').hasMatch(value)) {
//       missing.add('une minuscule');
//     }

//     if (!RegExp(r'[A-Z]').hasMatch(value)) {
//       missing.add('une majuscule');
//     }

//     if (!RegExp(r'\d').hasMatch(value)) {
//       missing.add('un chiffre');
//     }

//     if (!RegExp(r'[@$!%*?&]').hasMatch(value)) {
//       missing.add('un caractère spécial (@, !, %, *, ?, &)');
//     }

//     if (missing.isNotEmpty) {
//       if (missing.length == 1) {
//         return 'Il manque ${missing.first}';
//       } else if (missing.length == 2) {
//         return 'Il manque ${missing.join(' et ')}';
//       } else {
//         return 'Il manque ${missing.sublist(0, missing.length - 1).join(', ')} et ${missing.last}';
//       }
//     }

//     return null;
//   }

//   String? _validateConfirmPassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Veuillez confirmer votre mot de passe';
//     }

//     if (value != _passwordController.text) {
//       return 'Les mots de passe ne correspondent pas';
//     }

//     return null;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _nameFocus.dispose();
//     _emailFocus.dispose();
//     _phoneFocus.dispose();
//     _passwordFocus.dispose();
//     _confirmPasswordFocus.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // Variables pour gérer les erreurs de validation
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  List<String> _passwordErrors = [];
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    // Validation en temps réel
    _nameError = ErrorHandler.validateName(_nameController.text);
    _emailError = ErrorHandler.validateEmail(_emailController.text);
    _phoneError = ErrorHandler.validatePhone(_phoneController.text);
    _passwordErrors = ErrorHandler.validatePassword(_passwordController.text);

    // Validation de la confirmation du mot de passe
    if (_confirmPasswordController.text.isNotEmpty) {
      if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas';
      } else {
        _confirmPasswordError = null;
      }
    } else {
      _confirmPasswordError = 'Veuillez confirmer votre mot de passe';
    }

    final isValid =
        _nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordErrors.isEmpty &&
        _confirmPasswordError == null &&
        _acceptTerms;

    setState(() {
      _isFormValid = isValid;
      if (isValid) {
        _generalError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // Afficher l'erreur générale s'il y en a une
                  if (_generalError != null) ...[
                    ErrorHandler.buildAutoDisappearingErrorContainer(
                      _generalError!,
                      () => setState(() => _generalError = null),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPhoneField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 40),
                  _buildCreateAccountButton(authProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Créer un compte",
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
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
            child: Icon(Icons.person_add, color: AppColors.white, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Rejoignez SAAR",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Créez votre compte et découvrez nos services",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return _buildFormField(
      controller: _nameController,
      focusNode: _nameFocus,
      label: "Nom complet",
      hintText: 'Votre nom complet',
      icon: Icons.person_outline,
      error: _nameError,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
    );
  }

  Widget _buildEmailField() {
    return _buildFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      label: "Email",
      hintText: 'Votre adresse email',
      icon: Icons.email_outlined,
      error: _emailError,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
    );
  }

  Widget _buildPhoneField() {
    return _buildFormField(
      controller: _phoneController,
      focusNode: _phoneFocus,
      label: "Téléphone",
      hintText: 'Votre numéro de téléphone',
      icon: Icons.phone_outlined,
      error: _phoneError,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: "Mot de passe",
          hintText: 'Votre mot de passe',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        // Afficher les erreurs de mot de passe
        if (_passwordErrors.isNotEmpty) ...[
          const SizedBox(height: 8),
          ErrorHandler.buildErrorList(_passwordErrors),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocus,
      label: "Confirmer le mot de passe",
      hintText: 'Confirmez votre mot de passe',
      icon: Icons.lock_outline,
      error: _confirmPasswordError,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData icon,
    String? error,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    Function(String)? onFieldSubmitted,
  }) {
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
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        // Afficher l'erreur spécifique au champ
        if (error != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
              _validateForm();
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: Text(
            "J'accepte les conditions générales d'utilisation",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: authProvider.isLoading || !_isFormValid
            ? null
            : () => _handleSignup(authProvider),
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
        child: authProvider.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                "Créer mon compte",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSignup(AuthProvider authProvider) async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _generalError = null;
    });

    _validateForm();

    if (!_isFormValid) {
      setState(() {
        _generalError = "Veuillez corriger les erreurs ci-dessus";
      });
      return;
    }

    if (!_acceptTerms) {
      setState(() {
        _generalError = "Veuillez accepter les conditions d'utilisation";
      });
      return;
    }

    try {
      final success = await authProvider.signup(
        nom: _nameController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Compte créé avec succès !');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        // Gestion des erreurs spécifiques pour l'inscription
        String errorMessage = 'Erreur lors de la création du compte';

        if (authProvider.errorMessage != null) {
          final message = authProvider.errorMessage!.toLowerCase();

          if (message.contains('email') && message.contains('already')) {
            errorMessage = 'Un compte existe déjà avec cette adresse email';
          } else if (message.contains('phone') && message.contains('already')) {
            errorMessage = 'Ce numéro de téléphone est déjà utilisé';
          } else if (message.contains('validation')) {
            errorMessage = 'Données invalides. Vérifiez vos informations';
          } else if (message.contains('network') ||
              message.contains('connexion')) {
            errorMessage = 'Problème de connexion internet';
          } else if (message.contains('server') ||
              message.contains('serveur')) {
            errorMessage = 'Erreur du serveur. Veuillez réessayer plus tard';
          } else {
            errorMessage = authProvider.errorMessage!;
          }
        }

        setState(() {
          _generalError = errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = 'Une erreur inattendue s\'est produite';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }
}
