import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';
import 'package:saarflex_app/core/utils/validation_cache.dart';

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

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  List<String> _passwordErrors = [];
  String? _confirmPasswordError;
  String? _generalError;

  final String _nameValidationKey = 'signup_name';
  final String _emailValidationKey = 'signup_email';
  final String _phoneValidationKey = 'signup_phone';
  final String _passwordValidationKey = 'signup_password';
  final String _confirmPasswordValidationKey = 'signup_confirm_password';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_debouncedNameValidation);
    _emailController.addListener(_debouncedEmailValidation);
    _phoneController.addListener(_debouncedPhoneValidation);
    _passwordController.addListener(_debouncedPasswordValidation);
    _confirmPasswordController.addListener(_debouncedConfirmPasswordValidation);
  }

  void _debouncedNameValidation() {
    ValidationCache.debounceValidation(
      _nameValidationKey,
      () => _validateNameOptimized(),
      delay: Duration(milliseconds: 400),
    );
  }

  void _debouncedEmailValidation() {
    ValidationCache.debounceValidation(
      _emailValidationKey,
      () => _validateEmailOptimized(),
      delay: Duration(milliseconds: 400),
    );
  }

  void _debouncedPhoneValidation() {
    ValidationCache.debounceValidation(
      _phoneValidationKey,
      () => _validatePhoneOptimized(),
      delay: Duration(milliseconds: 400),
    );
  }

  void _debouncedPasswordValidation() {
    ValidationCache.debounceValidation(
      _passwordValidationKey,
      () => _validatePasswordOptimized(),
      delay: Duration(milliseconds: 400),
    );
  }

  void _debouncedConfirmPasswordValidation() {
    ValidationCache.debounceValidation(
      _confirmPasswordValidationKey,
      () => _validateConfirmPasswordOptimized(),
      delay: Duration(milliseconds: 400),
    );
  }

  void _validateNameOptimized() {
    if (!mounted) return;
    
    final newNameError = ValidationCache.validateNameOptimized(_nameController.text);
    
    if (_nameError != newNameError) {
      setState(() {
        _nameError = newNameError;
        _updateFormValidity();
      });
    }
  }

  void _validateEmailOptimized() {
    if (!mounted) return;
    
    final newEmailError = ValidationCache.validateEmailOptimized(_emailController.text);
    
    if (_emailError != newEmailError) {
      setState(() {
        _emailError = newEmailError;
        _updateFormValidity();
      });
    }
  }

  void _validatePhoneOptimized() {
    if (!mounted) return;
    
    final newPhoneError = ValidationCache.validatePhoneOptimized(_phoneController.text);
    
    if (_phoneError != newPhoneError) {
      setState(() {
        _phoneError = newPhoneError;
        _updateFormValidity();
      });
    }
  }

  void _validatePasswordOptimized() {
    if (!mounted) return;
    
    final newPasswordErrors = ValidationCache.validatePasswordOptimized(_passwordController.text);
    
    if (_passwordErrors.join() != newPasswordErrors.join()) {
      setState(() {
        _passwordErrors = newPasswordErrors;
        _updateFormValidity();
      });
    }
  }

  void _validateConfirmPasswordOptimized() {
    if (!mounted) return;
    
    String? newConfirmPasswordError;
    
    if (_confirmPasswordController.text.isNotEmpty) {
      if (_confirmPasswordController.text != _passwordController.text) {
        newConfirmPasswordError = 'Les mots de passe ne correspondent pas';
      } else {
        newConfirmPasswordError = null;
      }
    } else if (_passwordController.text.isNotEmpty) {
      newConfirmPasswordError = 'Veuillez confirmer votre mot de passe';
    } else {
      newConfirmPasswordError = null;
    }
    
    if (_confirmPasswordError != newConfirmPasswordError) {
      setState(() {
        _confirmPasswordError = newConfirmPasswordError;
        _updateFormValidity();
      });
    }
  }

  void _updateFormValidity() {
    final newIsValid = _nameError == null &&
                       _emailError == null &&
                       _phoneError == null &&
                       _passwordErrors.isEmpty &&
                       _confirmPasswordError == null &&
                       _acceptTerms &&
                       _nameController.text.isNotEmpty &&
                       _emailController.text.isNotEmpty &&
                       _phoneController.text.isNotEmpty &&
                       _passwordController.text.isNotEmpty &&
                       _confirmPasswordController.text.isNotEmpty;

    if (_isFormValid != newIsValid) {
      _isFormValid = newIsValid;
      if (newIsValid) {
        _generalError = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
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
              _updateFormValidity();
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

  Widget _buildCreateAccountButton(AuthViewModel authProvider) {
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

 Future<void> _handleSignup(AuthViewModel authProvider) async {
  setState(() {
    _generalError = null;
    _autovalidateMode = AutovalidateMode.onUserInteraction;
  });

  if (!_formKey.currentState!.validate()) {
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
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (mounted) {
      setState(() {
        _generalError = authProvider.errorMessage ?? 'Erreur lors de la création du compte';
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
