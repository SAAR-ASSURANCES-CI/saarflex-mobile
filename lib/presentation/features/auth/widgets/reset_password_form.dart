import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'reset_password_widgets.dart';

class ResetPasswordForm extends StatefulWidget {
  final TextEditingController emailController;
  final VoidCallback onEmailSent;

  final AuthViewModel authProvider;

  const ResetPasswordForm({
    super.key,
    required this.emailController,
    required this.onEmailSent,
    required this.authProvider,
  });

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 32),
          _buildSendButton(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      "Adresse email",
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEmailField() {
    return ResetPasswordWidgets.buildModernTextFormField(
      controller: widget.emailController,
      label: 'Votre email',
      icon: Icons.email_rounded,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
    );
  }

  Widget _buildSendButton() {
    return ResetPasswordWidgets.buildModernButton(
      text: "Envoyer le lien",
      onPressed: _isFormValid ? _handleResetPassword : null,
      icon: Icons.send_rounded,
      backgroundColor: AppColors.primary,
      isEnabled: _isFormValid,
      isLoading: widget.authProvider.isLoading,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OU",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return ResetPasswordWidgets.buildModernButton(
      text: "Retour à la connexion",
      onPressed: widget.authProvider.isLoading
          ? null
          : () => Navigator.pop(context),
      icon: Icons.login_rounded,
      backgroundColor: Colors.transparent,
      textColor: AppColors.primary,
      borderColor: AppColors.primary,
      isEnabled: true,
      isLoading: false,
    );
  }

  Future<void> _handleResetPassword() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      ResetPasswordWidgets.showErrorSnackBar(
        context,
        'Veuillez saisir un email valide',
      );
      return;
    }

    final success = await widget.authProvider.forgotPassword(
      widget.emailController.text.trim(),
    );

    if (success) {
      Navigator.pushNamed(
        context,
        '/otp-verification',
        arguments: {
          'email': widget.emailController.text.trim(),
          'fromForgotPassword': true,
        },
      );
    }
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

  @override
  void dispose() {
    widget.emailController.removeListener(_validateForm);
    super.dispose();
  }
}
