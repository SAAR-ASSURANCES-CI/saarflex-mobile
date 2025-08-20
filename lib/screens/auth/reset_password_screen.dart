import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/screens/auth/otp_verification_screen.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  String? _emailError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
  }

  void _validateForm() {
    _emailError = ErrorHandler.validateEmail(_emailController.text);

    setState(() {
      _isFormValid = _emailError == null;
      if (_isFormValid) {
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

                  _buildEmailField(),
                  const SizedBox(height: 40),
                  _buildResetButton(authProvider),
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
        "Mot de passe oublié",
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
            child: Icon(Icons.lock_reset, color: AppColors.white, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Réinitialiser le mot de passe",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Entrez votre email pour vérifier votre compte",
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
          textInputAction: TextInputAction.done,
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

  Widget _buildResetButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: authProvider.isLoading || !_isFormValid
            ? null
            : () => _handleReset(authProvider),
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
                "Continuer",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleReset(AuthProvider authProvider) async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _generalError = null;
    });

    _validateForm();

    if (!_isFormValid) {
      setState(() {
        _generalError = "Veuillez saisir un email valide";
      });
      return;
    }

    final email = _emailController.text.trim();

    try {
      await authProvider.login(email: email, password: 'test123invalid');
      
      await _proceedWithPasswordReset(authProvider, email);
      
    } catch (e) {
      if (authProvider.errorMessage != null) {
        final errorMessage = authProvider.errorMessage!.toLowerCase();
        
        if (errorMessage.contains('user not found') || 
            errorMessage.contains('utilisateur introuvable') ||
            errorMessage.contains('user does not exist') ||
            errorMessage.contains('email not found')) {
          
          setState(() {
            _generalError = 'Aucun compte associé à cette adresse email';
          });
          return;
        }
        
        else if (errorMessage.contains('mot de passe') ||
                 errorMessage.contains('password') ||
                 errorMessage.contains('caractères') ||
                 errorMessage.contains('obligatoire') ||
                 errorMessage.contains('incorrect') ||
                 errorMessage.contains('invalid')) {
          
          await _proceedWithPasswordReset(authProvider, email);
        }
        
        else {
          setState(() {
            _generalError = 'Erreur de connexion. Veuillez réessayer.';
          });
          return;
        }
      } else {
        setState(() {
          _generalError = 'Erreur de connexion. Veuillez réessayer.';
        });
        return;
      }
    }
  }

  Future<void> _proceedWithPasswordReset(AuthProvider authProvider, String email) async {
    authProvider.clearError();
    
    try {
      final success = await authProvider.forgotPassword(email);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
      } else if (mounted) {
        setState(() {
          _generalError = authProvider.errorMessage ?? 'Erreur lors de l\'envoi';
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
    _emailFocus.dispose();
    super.dispose();
  }
}