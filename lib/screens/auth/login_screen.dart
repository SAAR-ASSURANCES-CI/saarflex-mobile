import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/screens/auth/reset_password_screen.dart';
import 'package:saarflex_app/screens/auth/signup_screen.dart';
import 'package:saarflex_app/utils/error_handler.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    _emailError = _validateEmail(_emailController.text);
    _passwordError = _validatePassword(_passwordController.text);

    final isValid = _emailError == null && _passwordError == null;

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
                      () => setState(
                        () => _generalError = null,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildRememberMeAndForgotPassword(),
                  const SizedBox(height: 40),
                  _buildLoginButton(authProvider),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSignupButton(authProvider),
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
        "Se connecter",
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
            child: Icon(Icons.login, color: AppColors.white, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Bon retour !",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Connectez-vous à votre compte SAAR",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Votre adresse email',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError != null
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError != null
                    ? AppColors.error
                    : AppColors.primary,
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
        if (_emailError != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _emailError!,
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mot de passe",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Votre mot de passe',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
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
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordError != null
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordError != null
                    ? AppColors.error
                    : AppColors.primary,
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
        if (_passwordError != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _passwordError!,
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

  Widget _buildRememberMeAndForgotPassword() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              Text(
                "Se souvenir de moi",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
              );
            },
            child: Text(
              "Mot de passe oublié ?",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OU",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }

  Widget _buildSignupButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
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
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Créer un compte",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre adresse email';
    }

    final cleanValue = value.trim();

    if (!cleanValue.contains('@')) {
      return 'L\'email doit contenir le symbole @';
    }

    if (cleanValue.startsWith('@') || cleanValue.endsWith('@')) {
      return 'Format incorrect : exemple@domaine.com';
    }

    final parts = cleanValue.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      return 'Format incorrect : exemple@domaine.com';
    }

    if (!parts[1].contains('.') ||
        parts[1].endsWith('.') ||
        parts[1].startsWith('.')) {
      return 'Domaine invalide : exemple@domaine.com';
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(cleanValue)) {
      return 'Adresse email invalide';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe';
    }

    // Pour le login, on vérifie juste qu'il y a un mot de passe
    // Pas besoin de vérifier la complexité ici
    return null;
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
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

    try {
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Connexion réussie !');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        String errorMessage = 'Erreur de connexion';

        if (authProvider.errorMessage != null) {
          final message = authProvider.errorMessage!.toLowerCase();

          if (message.contains('email') &&
              (message.contains('incorrect') ||
                  message.contains('not found') ||
                  message.contains('non trouvé'))) {
            errorMessage = 'Email ou mot de passe incorrect';
          } else if (message.contains('password') ||
              message.contains('mot de passe')) {
            errorMessage = 'Mot de passe incorrect';
          } else if (message.contains('connexion') ||
              message.contains('network') ||
              message.contains('internet')) {
            errorMessage = 'Problème de connexion internet';
          } else if (message.contains('serveur') ||
              message.contains('server')) {
            errorMessage = 'Erreur du serveur. Veuillez réessayer plus tard';
          } else if (message.contains('timeout') || message.contains('délai')) {
            errorMessage = 'Délai d\'attente dépassé. Vérifiez votre connexion';
          } else if (message.contains('too many') ||
              message.contains('trop de tentatives')) {
            errorMessage =
                'Trop de tentatives. Veuillez patienter quelques minutes';
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}