import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _lastNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid && _acceptTerms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.white,
                  AppColors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      foregroundColor: AppColors.primary,
                      title: Text(
                        "Créer un compte",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  if (authProvider.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: GoogleFonts.poppins(
                                color: Colors.red[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_add_rounded,
                                  size: 50,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            Text(
                              "Coordonnées",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildModernTextFormField(
                              controller: _lastNameController,
                              focusNode: _nameFocus,
                              nextFocusNode: _emailFocus,
                              label: 'Nom de famille',
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              validator: _validateName,
                            ),
                            const SizedBox(height: 16),

                            _buildModernTextFormField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              nextFocusNode: _phoneFocus,
                              label: 'Email',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),

                            _buildModernTextFormField(
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              nextFocusNode: _passwordFocus,
                              label: 'Téléphone',
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              validator: _validatePhone,
                            ),
                            const SizedBox(height: 16),

                            _buildModernTextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              nextFocusNode: _confirmPasswordFocus,
                              label: 'Mot de passe',
                              icon: Icons.lock_rounded,
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildModernTextFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              label: 'Confirmer le mot de passe',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirmPassword,
                              validator: _validateConfirmPassword,
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildTermsCheckbox(),
                            const SizedBox(height: 32),

                            _buildModernButton(
                              text: "Créer mon compte",
                              onPressed: _isFormValid
                                  ? () => _handleSignup(authProvider)
                                  : null,
                              isEnabled: _isFormValid,
                              isLoading: authProvider.isLoading,
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignup(AuthProvider authProvider) async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      _showErrorSnackBar('Veuillez corriger les erreurs du formulaire');
      return;
    }

final success = await authProvider.signup(
  nom: _lastNameController.text.trim(),       
  email: _emailController.text.trim(),
  telephone: _phoneController.text.trim(),   
  password: _passwordController.text,
);

    if (success) {
      _showSuccessSnackBar('Compte créé avec succès !');
    }
  }

  Widget _buildModernTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction:
            textInputAction ??
            (nextFocusNode != null
                ? TextInputAction.next
                : TextInputAction.done),
        validator: validator,
        onFieldSubmitted: (_) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppColors.primary.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          errorStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !_acceptTerms && _autovalidateMode != AutovalidateMode.disabled
              ? Colors.red.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        color: AppColors.primary.withOpacity(0.05),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
                _validateForm();
              });
            },
            title: Text(
              "J'accepte les conditions générales d'utilisation",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            checkColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (!_acceptTerms && _autovalidateMode != AutovalidateMode.disabled)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    "Vous devez accepter les conditions d'utilisation",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isEnabled,
    required bool isLoading,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: isEnabled && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary : Colors.grey[300],
          foregroundColor: isEnabled ? AppColors.white : Colors.grey[600],
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Création en cours...",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return 'Le nom ne doit contenir que des lettres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le téléphone est obligatoire';
    }
    String cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(\+225|0)?[0-9]{8,10}$').hasMatch(cleanPhone)) {
      return 'Numéro invalide (ex: 0712345678 ou +2250712345678)';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (value.length < 8) {
      return 'Au moins 8 caractères requis';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Doit contenir : majuscule, minuscule, chiffre';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmer le mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _lastNameController.dispose();
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
