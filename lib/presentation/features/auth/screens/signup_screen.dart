import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';
import 'package:saarciflex_app/core/utils/validation_cache.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/cgu_modal.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool _hasOpenedCGU = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _nameError;
  String? _emailError;
  List<String> _passwordErrors = [];
  String? _confirmPasswordError;
  String? _generalError;

  final String _nameValidationKey = 'signup_name';
  final String _emailValidationKey = 'signup_email';
  final String _passwordValidationKey = 'signup_password';
  final String _confirmPasswordValidationKey = 'signup_confirm_password';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_debouncedNameValidation);
    _emailController.addListener(_debouncedEmailValidation);
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

    final newNameError = ValidationCache.validateNameOptimized(
      _nameController.text,
    );

    if (_nameError != newNameError) {
      setState(() {
        _nameError = newNameError;
        _updateFormValidity();
      });
    }
  }

  void _validateEmailOptimized() {
    if (!mounted) return;

    final newEmailError = ValidationCache.validateEmailOptimized(
      _emailController.text,
    );

    if (_emailError != newEmailError) {
      setState(() {
        _emailError = newEmailError;
        _updateFormValidity();
      });
    }
  }

  void _validatePasswordOptimized() {
    if (!mounted) return;

    final newPasswordErrors = ValidationCache.validatePasswordOptimized(
      _passwordController.text,
    );

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
    final newIsValid =
        _nameError == null &&
        _emailError == null &&
        _passwordErrors.isEmpty &&
        _confirmPasswordError == null &&
        _acceptTerms &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
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
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final viewInsets = MediaQuery.of(context).viewInsets;
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;
        
        // Padding adaptatif
        final horizontalPadding = screenWidth < 360 
            ? 16.0 
            : screenWidth < 600 
                ? 24.0 
                : (screenWidth * 0.08).clamp(24.0, 48.0);
        final verticalPadding = screenHeight < 600 ? 16.0 : 24.0;
        final bottomPadding = viewInsets.bottom > 0 
            ? viewInsets.bottom + 16.0 
            : 24.0;
        
        // Espacements adaptatifs
        final topSpacing = screenHeight < 600 ? 10.0 : 20.0;
        final headerSpacing = screenHeight < 600 ? 24.0 : 40.0;
        final fieldSpacing = screenHeight < 600 ? 16.0 : 20.0;
        final checkboxSpacing = screenHeight < 600 ? 20.0 : 24.0;
        final buttonTopSpacing = screenHeight < 600 ? 32.0 : 40.0;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(textScaleFactor, screenWidth),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: verticalPadding,
              bottom: bottomPadding,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topSpacing),
                  _buildHeader(screenWidth, screenHeight, textScaleFactor),
                  SizedBox(height: headerSpacing),

                  if (_generalError != null) ...[
                    ErrorHandler.buildAutoDisappearingErrorContainer(
                      _generalError!,
                    ),
                    SizedBox(height: fieldSpacing),
                  ],

                  _buildNameField(textScaleFactor, screenWidth),
                  SizedBox(height: fieldSpacing),
                  _buildEmailField(textScaleFactor, screenWidth),
                  SizedBox(height: fieldSpacing),
                  _buildPasswordField(textScaleFactor, screenWidth),
                  SizedBox(height: fieldSpacing),
                  _buildConfirmPasswordField(textScaleFactor, screenWidth),
                  SizedBox(height: checkboxSpacing),
                  _buildTermsCheckbox(screenWidth, textScaleFactor),
                  SizedBox(height: buttonTopSpacing),
                  _buildCreateAccountButton(authProvider, textScaleFactor, screenWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(double textScaleFactor, double screenWidth) {
    final fontSize = (20.0 / textScaleFactor).clamp(18.0, 22.0);
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back, 
          color: AppColors.primary,
          size: screenWidth < 360 ? 22 : 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Créer un compte",
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight, double textScaleFactor) {
    final logoSize = screenWidth < 360 ? 70.0 : 80.0;
    final titleFontSize = (28.0 / textScaleFactor).clamp(24.0, 32.0);
    final subtitleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final logoSpacing = screenHeight < 600 ? 16.0 : 24.0;
    final titleSpacing = screenHeight < 600 ? 6.0 : 8.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: logoSize,
            height: logoSize,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'lib/assets/logoSaarCI.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shield_rounded,
                color: AppColors.primary,
                size: logoSize * 0.5,
              ),
            ),
          ),
        ),
        SizedBox(height: logoSpacing),
        Text(
          "Rejoignez SAAR",
          style: GoogleFonts.poppins(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: titleSpacing),
        Text(
          "Créez votre compte et découvrez nos services",
          style: GoogleFonts.poppins(
            fontSize: subtitleFontSize,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(double textScaleFactor, double screenWidth) {
    return _buildFormField(
      controller: _nameController,
      focusNode: _nameFocus,
      label: "Nom complet",
      hintText: 'Votre nom complet',
      icon: Icons.person_outline,
      error: _nameError,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
      textScaleFactor: textScaleFactor,
      screenWidth: screenWidth,
    );
  }

  Widget _buildEmailField(double textScaleFactor, double screenWidth) {
    return _buildFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      label: "Email",
      hintText: 'Votre adresse email',
      icon: Icons.email_outlined,
      error: _emailError,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
      textScaleFactor: textScaleFactor,
      screenWidth: screenWidth,
    );
  }

  Widget _buildPasswordField(double textScaleFactor, double screenWidth) {
    final errorSpacing = screenWidth < 360 ? 6.0 : 8.0;
    
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
              size: screenWidth < 360 ? 20 : 24,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          textScaleFactor: textScaleFactor,
          screenWidth: screenWidth,
        ),
        if (_passwordErrors.isNotEmpty) ...[
          SizedBox(height: errorSpacing),
          ErrorHandler.buildErrorList(_passwordErrors),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField(double textScaleFactor, double screenWidth) {
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
          size: screenWidth < 360 ? 20 : 24,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
      textScaleFactor: textScaleFactor,
      screenWidth: screenWidth,
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData icon,
    required double textScaleFactor,
    required double screenWidth,
    String? error,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    Function(String)? onFieldSubmitted,
  }) {
    final labelFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final fieldFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final errorFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final contentPadding = screenWidth < 360 ? 14.0 : 16.0;
    final labelSpacing = screenWidth < 360 ? 6.0 : 8.0;
    final errorSpacing = screenWidth < 360 ? 6.0 : 8.0;
    final iconSize = screenWidth < 360 ? 20.0 : 24.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: labelSpacing),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: GoogleFonts.poppins(
            fontSize: fieldFontSize,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textHint,
              fontSize: fieldFontSize,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: iconSize),
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
            contentPadding: EdgeInsets.all(contentPadding),
          ),
        ),
        if (error != null) ...[
          SizedBox(height: errorSpacing),
          Row(
            children: [
              Icon(
                Icons.error_outline, 
                color: AppColors.error, 
                size: screenWidth < 360 ? 14 : 16,
              ),
              SizedBox(width: screenWidth < 360 ? 6 : 8),
              Expanded(
                child: Text(
                  error,
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontSize: errorFontSize,
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

  Widget _buildTermsCheckbox(double screenWidth, double textScaleFactor) {
    final checkboxSize = screenWidth < 360 ? 18.0 : 20.0;
    final labelFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final helpFontSize = (12.0 / textScaleFactor).clamp(10.0, 14.0);
    final helpSpacing = screenWidth < 360 ? 6.0 : 8.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: checkboxSize,
              height: checkboxSize,
              child: Checkbox(
                value: _acceptTerms,
                onChanged: _hasOpenedCGU
                    ? (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                          _updateFormValidity();
                        });
                      }
                    : null,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(width: screenWidth < 360 ? 6.0 : 8.0),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: screenWidth < 360 ? 2.0 : 0.0),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: labelFontSize,
                      color: _hasOpenedCGU
                          ? AppColors.textSecondary
                          : AppColors.textHint,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: "J'accepte les "),
                      TextSpan(
                        text: "conditions générales d'utilisation",
                        style: GoogleFonts.poppins(
                          fontSize: labelFontSize,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          height: 1.4,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showCGUModal(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_hasOpenedCGU) ...[
          SizedBox(height: helpSpacing),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: screenWidth < 360 ? 14 : 16,
                color: AppColors.warning,
              ),
              SizedBox(width: screenWidth < 360 ? 6 : 8),
              Expanded(
                child: Text(
                  "Veuillez d'abord consulter les conditions générales d'utilisation",
                  style: GoogleFonts.poppins(
                    fontSize: helpFontSize,
                    color: AppColors.warning,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showCGUModal() {
    CGUModal.show(context).then((_) {
      if (mounted) {
        setState(() {
          _hasOpenedCGU = true;
          _acceptTerms = true;
          _updateFormValidity();
        });
      }
    });
  }

  Widget _buildCreateAccountButton(AuthViewModel authProvider, double textScaleFactor, double screenWidth) {
    final buttonHeight = screenWidth < 360 ? 48.0 : 50.0;
    final buttonFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
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
                  fontSize: buttonFontSize,
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
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        setState(() {
          _generalError =
              authProvider.errorMessage ??
              'Erreur lors de la création du compte';
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }
}
