// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../providers/auth_provider.dart';
// import 'new_password_screen.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   final String email;

//   const OtpVerificationScreen({super.key, required this.email});

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final List<TextEditingController> _controllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
//   bool _isFormValid = false;

//   @override
//   void initState() {
//     super.initState();
//     for (var controller in _controllers) {
//       controller.addListener(_validateForm);
//     }
//   }

//   void _validateForm() {
//     setState(() {
//       _isFormValid = _controllers.every(
//         (controller) => controller.text.isNotEmpty,
//       );
//     });
//   }

//   String get _otpCode =>
//       _controllers.map((controller) => controller.text).join();

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
//               'Vérification',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 40),
//                 if (authProvider.errorMessage != null)
//                   _buildErrorMessage(authProvider.errorMessage!),
//                 const SizedBox(height: 24),
//                 _buildOtpFields(),
//                 const SizedBox(height: 32),
//                 _buildVerifyButton(authProvider),
//                 const SizedBox(height: 24),
//                 _buildResendButton(authProvider),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Icon(Icons.mark_email_read, color: AppColors.white, size: 28),
//         ),
//         // Icon(Icons.mark_email_read, size: 64, color: AppColors.primary),
//         const SizedBox(height: 24),
//         Text(
//           'Vérifiez votre email',
//           style: GoogleFonts.poppins(
//             fontSize: 24,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Nous avons envoyé un code à',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: AppColors.textSecondary,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           widget.email,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.primary,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorMessage(String message) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.error.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.error.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: AppColors.error),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               message,
//               style: GoogleFonts.poppins(color: AppColors.error, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOtpFields() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: List.generate(
//         6,
//         (index) => SizedBox(
//           width: 45,
//           child: TextField(
//             controller: _controllers[index],
//             focusNode: _focusNodes[index],
//             textAlign: TextAlign.center,
//             keyboardType: TextInputType.number,
//             maxLength: 1,
//             style: GoogleFonts.poppins(fontSize: 20),
//             decoration: InputDecoration(
//               counterText: '',
//               filled: true,
//               fillColor: AppColors.surface,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: AppColors.border),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: AppColors.primary, width: 2),
//               ),
//             ),
//             onChanged: (value) {
//               if (value.isNotEmpty && index < 5) {
//                 _focusNodes[index + 1].requestFocus();
//               } else if (value.isEmpty && index > 0) {
//                 _focusNodes[index - 1].requestFocus();
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVerifyButton(AuthProvider authProvider) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: !_isFormValid || authProvider.isLoading
//             ? null
//             : () => _handleVerifyOtp(authProvider),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
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
//                 'Vérifier',
//                 style: GoogleFonts.poppins(
//                   color: AppColors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildResendButton(AuthProvider authProvider) {
//     return TextButton(
//       onPressed: authProvider.isLoading ? null : _handleResendCode,
//       child: Text(
//         'Renvoyer le code',
//         style: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: AppColors.primary,
//         ),
//       ),
//     );
//   }

//   Future<void> _handleVerifyOtp(AuthProvider authProvider) async {
//     final success = await authProvider.verifyOtp(
//       email: widget.email,
//       code: _otpCode,
//     );

//     if (success && mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               NewPasswordScreen(email: widget.email, code: _otpCode),
//         ),
//       );
//     }
//   }

//   Future<void> _handleResendCode() async {
//     final authProvider = context.read<AuthProvider>();
//     final success = await authProvider.forgotPassword(widget.email);

//     if (success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Code renvoyé avec succès'),
//           backgroundColor: AppColors.success,
//         ),
//       );

//       for (var controller in _controllers) {
//         controller.clear();
//       }
//       _focusNodes[0].requestFocus();
//     }
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
// }





import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isFormValid = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_validateForm);
    }
  }

  void _validateForm() {
    final isValid = _controllers.every(
      (controller) => controller.text.isNotEmpty && controller.text.length == 1,
    );
    
    setState(() {
      _isFormValid = isValid;
      if (isValid) {
        _generalError = null;
      }
    });
  }

  String get _otpCode =>
      _controllers.map((controller) => controller.text).join();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
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

                _buildOtpFields(),
                const SizedBox(height: 32),
                _buildVerifyButton(authProvider),
                const SizedBox(height: 24),
                _buildResendButton(authProvider),
              ],
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
        'Vérification',
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
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(Icons.mark_email_read, color: AppColors.white, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          'Vérifiez votre email',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nous avons envoyé un code à',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.email,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _controllers[index].text.isNotEmpty
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.error),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              _validateForm();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: !_isFormValid || authProvider.isLoading
            ? null
            : () => _handleVerifyOtp(authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppColors.primary
              : AppColors.disabled,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _isFormValid ? 3 : 0,
        ),
        child: authProvider.isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Vérification...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Vérifier le code',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResendButton(AuthProvider authProvider) {
    return Column(
      children: [
        Text(
          "Vous n'avez pas reçu le code ?",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: authProvider.isLoading ? null : _handleResendCode,
          icon: Icon(Icons.refresh_rounded, size: 18),
          label: Text(
            'Renvoyer le code',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleVerifyOtp(AuthProvider authProvider) async {
    setState(() {
      _generalError = null;
    });

    if (!_isFormValid) {
      setState(() {
        _generalError = "Veuillez saisir le code à 6 chiffres complet";
      });
      return;
    }

    try {
      final success = await authProvider.verifyOtp(
        email: widget.email,
        code: _otpCode,
      );

      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Code vérifié avec succès !');
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordScreen(
              email: widget.email, 
              code: _otpCode,
            ),
          ),
        );
      } else if (mounted) {
        // Gestion des erreurs spécifiques pour la vérification OTP
        String errorMessage = 'Erreur de vérification';

        if (authProvider.errorMessage != null) {
          final message = authProvider.errorMessage!.toLowerCase();

          if (message.contains('code') && (message.contains('incorrect') || message.contains('invalid'))) {
            errorMessage = 'Code incorrect. Vérifiez le code reçu par email';
            _clearOtpFields();
          } else if (message.contains('expired') || message.contains('expire')) {
            errorMessage = 'Code expiré. Demandez un nouveau code';
            _clearOtpFields();
          } else if (message.contains('too many')) {
            errorMessage = 'Trop de tentatives. Patientez quelques minutes';
          } else if (message.contains('network') || message.contains('connexion')) {
            errorMessage = 'Problème de connexion internet';
          } else if (message.contains('server') || message.contains('serveur')) {
            errorMessage = 'Erreur du serveur. Réessayez plus tard';
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

  Future<void> _handleResendCode() async {
    final authProvider = context.read<AuthProvider>();
    
    setState(() {
      _generalError = null;
    });

    try {
      final success = await authProvider.forgotPassword(widget.email);

      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Nouveau code envoyé !');
        _clearOtpFields();
        _focusNodes[0].requestFocus();
      } else if (mounted) {
        String errorMessage = 'Erreur lors du renvoi';

        if (authProvider.errorMessage != null) {
          final message = authProvider.errorMessage!.toLowerCase();

          if (message.contains('too many')) {
            errorMessage = 'Trop de tentatives. Patientez quelques minutes';
          } else if (message.contains('network') || message.contains('connexion')) {
            errorMessage = 'Problème de connexion internet';
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
          _generalError = 'Erreur lors du renvoi du code';
        });
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _isFormValid = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}