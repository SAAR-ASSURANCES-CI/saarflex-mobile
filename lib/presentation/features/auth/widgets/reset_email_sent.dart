import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/auth/screens/otp_verification_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        _emailController.text.trim().isNotEmpty &&
        _validateEmail(_emailController.text) == null;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<AuthViewModel>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),

                  if (authProvider.errorMessage != null)
                    _buildErrorMessage(authProvider.errorMessage!),

                  _buildEmailField(),
                  const SizedBox(height: 40),
                  _buildResetButton(authProvider),
                ],
              ),
            ),
          );
        },
      ),
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

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
          validator: _validateEmail,
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
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(AuthViewModel authProvider) {
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

  Future<void> _handleReset(AuthViewModel authProvider) async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() => _isFormValid = false);

    try {
      await authProvider.login(email: email, password: '');

      await _proceedWithPasswordReset(authProvider, email);
    } catch (e) {
      if (authProvider.errorMessage != null) {
        final errorMessage = authProvider.errorMessage!.toLowerCase();

        if (errorMessage.contains('user') &&
            (errorMessage.contains('not found') ||
                errorMessage.contains('n\'existe pas') ||
                errorMessage.contains('introuvable'))) {
          setState(() {
            _isFormValid = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Aucun compte associé à cette adresse email',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        } else if (errorMessage.contains('password') ||
            errorMessage.contains('mot de passe') ||
            errorMessage.contains('credential')) {
          await _proceedWithPasswordReset(authProvider, email);
        } else {
          setState(() => _isFormValid = true);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur de connexion. Veuillez réessayer.',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        }
      } else {
        setState(() => _isFormValid = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur de connexion. Veuillez réessayer.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    }
  }

  Future<void> _proceedWithPasswordReset(
    AuthViewModel authProvider,
    String email,
  ) async {
    authProvider.clearError();

    final success = await authProvider.forgotPassword(email);

    setState(() => _isFormValid = true);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erreur lors de l\'envoi',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email obligatoire';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }
}
