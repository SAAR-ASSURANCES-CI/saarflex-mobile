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
    _nameError = ErrorHandler.validateName(_nameController.text);
    _emailError = ErrorHandler.validateEmail(_emailController.text);
    _phoneError = ErrorHandler.validatePhone(_phoneController.text);
    _passwordErrors = ErrorHandler.validatePassword(_passwordController.text);

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
