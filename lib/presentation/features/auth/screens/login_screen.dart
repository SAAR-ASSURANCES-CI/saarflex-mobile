import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/reset_password_screen.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/signup_screen.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/core/utils/validation_cache.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  final String _emailValidationKey = 'login_email';
  final String _passwordValidationKey = 'login_password';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_debouncedEmailValidation);
    _passwordController.addListener(_debouncedPasswordValidation);
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

    final passwordErrors = ValidationCache.validatePasswordOptimized(
      _passwordController.text,
    );
    final newPasswordError = passwordErrors.isEmpty
        ? null
        : passwordErrors.first;

    if (_passwordError != newPasswordError) {
      setState(() {
        _passwordError = newPasswordError;
        _updateFormValidity();
      });
    }
  }

  void _updateFormValidity() {
    final newIsValid =
        _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;

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
        final optionsSpacing = screenHeight < 600 ? 8.0 : 10.0;
        final buttonTopSpacing = screenHeight < 600 ? 24.0 : 30.0;
        final buttonSpacing = screenHeight < 600 ? 20.0 : 24.0;
        
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

                  _buildEmailField(textScaleFactor, screenWidth),
                  SizedBox(height: fieldSpacing),
                  _buildPasswordField(textScaleFactor, screenWidth),
                  SizedBox(height: optionsSpacing),
                  _buildOptionsRow(screenWidth, textScaleFactor),
                  SizedBox(height: buttonTopSpacing),
                  _buildLoginButton(authProvider, textScaleFactor, screenWidth),
                  SizedBox(height: buttonSpacing),
                  _buildDivider(screenWidth, textScaleFactor),
                  SizedBox(height: buttonSpacing),
                  _buildSignupButton(authProvider, textScaleFactor, screenWidth),
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
        "Se connecter",
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight, double textScaleFactor) {
    final iconSize = screenWidth < 360 ? 50.0 : 60.0;
    final iconInnerSize = screenWidth < 360 ? 24.0 : 28.0;
    final titleFontSize = (28.0 / textScaleFactor).clamp(24.0, 32.0);
    final subtitleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final iconSpacing = screenHeight < 600 ? 16.0 : 24.0;
    final titleSpacing = screenHeight < 600 ? 6.0 : 8.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.login, 
              color: AppColors.white, 
              size: iconInnerSize,
            ),
          ),
        ),
        SizedBox(height: iconSpacing),
        Text(
          "Bon retour !",
          style: GoogleFonts.poppins(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: titleSpacing),
        Text(
          "Connectez-vous à votre compte SAAR",
          style: GoogleFonts.poppins(
            fontSize: subtitleFontSize,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
    return _buildFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      label: "Mot de passe",
      hintText: 'Votre mot de passe',
      icon: Icons.lock_outline,
      error: _passwordError,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        if (_isFormValid) {
          _handleLogin(context.read<AuthViewModel>());
        }
      },
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

  Widget _buildOptionsRow(double screenWidth, double textScaleFactor) {
    final checkboxSize = screenWidth < 360 ? 18.0 : 20.0;
    final checkboxSpacing = screenWidth < 360 ? 6.0 : 8.0;
    final labelFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final linkFontSize = (13.0 / textScaleFactor).clamp(11.0, 15.0);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              SizedBox(
                width: checkboxSize,
                height: checkboxSize,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: checkboxSpacing),
              Flexible(
                child: Text(
                  "Se souvenir de moi",
                  style: GoogleFonts.poppins(
                    fontSize: labelFontSize,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 360 ? 4.0 : 8.0,
                vertical: 4.0,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Mot de passe oublié ?",
              style: GoogleFonts.poppins(
                fontSize: linkFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthViewModel authProvider, double textScaleFactor, double screenWidth) {
    final buttonHeight = screenWidth < 360 ? 48.0 : 50.0;
    final buttonFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: authProvider.isLoading || !_isFormValid
            ? null
            : () => _handleLogin(authProvider),
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
                "Se connecter",
                style: GoogleFonts.poppins(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(double screenWidth, double textScaleFactor) {
    final dividerFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final dividerPadding = screenWidth < 360 ? 12.0 : 16.0;
    
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: dividerPadding),
          child: Text(
            "OU",
            style: GoogleFonts.poppins(
              fontSize: dividerFontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }

  Widget _buildSignupButton(AuthViewModel authProvider, double textScaleFactor, double screenWidth) {
    final buttonHeight = screenWidth < 360 ? 48.0 : 50.0;
    final buttonFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: authProvider.isLoading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Créer un compte",
          style: GoogleFonts.poppins(
            fontSize: buttonFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthViewModel authProvider) async {
    setState(() {
      _generalError = null;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        setState(() {
          _generalError = authProvider.errorMessage ?? 'Erreur de connexion';
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
