// // Modifications à apporter à votre EditProfileScreen existant

// // 1. AJOUTER L'IMPORT
// import '../../utils/error_handler.dart';

// // 2. REMPLACER LA VALIDATION DES CHAMPS
// // Dans votre méthode _validateChangedFields(), remplacer par :

// Map<String, String?> _validateChangedFields() {
//   Map<String, String?> errors = {};
  
//   // Vérifier seulement les champs qui ont été modifiés
//   if (_firstNameController.text.trim() != _originalData['nom']) {
//     final nameError = ErrorHandler.validateName(_firstNameController.text);
//     if (nameError != null) {
//       errors['nom'] = nameError;
//     }
//   }

//   if (_emailController.text.trim() != _originalData['email']) {
//     final emailError = ErrorHandler.validateEmail(_emailController.text);
//     if (emailError != null) {
//       errors['email'] = emailError;
//     }
//   }

//   if (_phoneController.text.trim() != _originalData['telephone']) {
//     final phoneError = ErrorHandler.validatePhone(_phoneController.text);
//     if (phoneError != null) {
//       errors['telephone'] = phoneError;
//     }
//   }

//   return errors;
// }

// // 3. REMPLACER L'AFFICHAGE D'ERREUR DANS build()
// // Remplacer la section d'affichage d'erreurs par :

// if (_fieldErrors.isNotEmpty) ...[
//   ErrorHandler.buildErrorList(_fieldErrors.values.toList()),
//   const SizedBox(height: 20),
// ],

// // 4. REMPLACER LES MÉTHODES _showFieldError ET _showSuccess
// // Supprimer ces méthodes et utiliser directement :

// void _showFieldError(String message) {
//   ErrorHandler.showErrorSnackBar(context, message);
// }

// void _showSuccess(String message) {
//   ErrorHandler.showSuccessSnackBar(context, message);
// }

// // 5. AMÉLIORER LA GESTION D'ERREURS DANS _saveProfile()
// // Remplacer la section de gestion d'erreurs par :

// Future<void> _saveProfile() async {
//   setState(() {
//     _isLoading = true;
//     _fieldErrors.clear();
//   });

//   try {
//     // Validation des champs modifiés uniquement
//     final errors = _validateChangedFields();
    
//     if (errors.isNotEmpty) {
//       setState(() {
//         _fieldErrors = errors;
//         _isLoading = false;
//       });
//       ErrorHandler.showErrorSnackBar(
//         context, 
//         'Veuillez corriger les erreurs ci-dessus'
//       );
//       return;
//     }

//     final authProvider = context.read<AuthProvider>();

//     // Construire les données à envoyer - seulement les champs modifiés
//     final Map<String, dynamic> profileData = {};
    
//     if (_firstNameController.text.trim() != _originalData['nom']) {
//       profileData['nom'] = _firstNameController.text.trim();
//     }
    
//     if (_emailController.text.trim() != _originalData['email']) {
//       profileData['email'] = _emailController.text.trim();
//     }
    
//     if (_phoneController.text.trim() != _originalData['telephone']) {
//       profileData['telephone'] = _phoneController.text.trim();
//     }
    
//     if (_birthPlaceController.text.trim() != _originalData['lieu_naissance']) {
//       profileData['lieu_naissance'] = _birthPlaceController.text.trim();
//     }
    
//     if (_nationalityController.text.trim() != _originalData['nationalite']) {
//       profileData['nationalite'] = _nationalityController.text.trim();
//     }
    
//     if (_professionController.text.trim() != _originalData['profession']) {
//       profileData['profession'] = _professionController.text.trim();
//     }
    
//     if (_addressController.text.trim() != _originalData['adresse']) {
//       profileData['adresse'] = _addressController.text.trim();
//     }
    
//     if (_idNumberController.text.trim() != _originalData['numero_piece_identite']) {
//       profileData['numero_piece_identite'] = _idNumberController.text.trim();
//     }
    
//     if (_selectedGender != _originalData['sexe']) {
//       profileData['sexe'] = _selectedGender.toLowerCase();
//     }
    
//     if (_selectedIdType != _originalData['type_piece_identite']) {
//       profileData['type_piece_identite'] = _selectedIdType;
//     }

//     // Vérifier qu'il y a au moins un champ à modifier
//     if (profileData.isEmpty) {
//       setState(() {
//         _isLoading = false;
//       });
//       ErrorHandler.showWarningSnackBar(context, 'Aucune modification détectée');
//       return;
//     }

//     final success = await authProvider.updateProfile(profileData);

//     if (success && mounted) {
//       ErrorHandler.showSuccessSnackBar(context, 'Profil mis à jour avec succès !');
      
//       // Recharger les données pour mettre à jour les valeurs originales
//       _loadUserData();
//       setState(() {
//         _hasChanges = false;
//       });
      
//       // Retourner à l'écran précédent après un délai
//       Future.delayed(const Duration(seconds: 1), () {
//         if (mounted) Navigator.pop(context);
//       });
//     } else if (mounted) {
//       // Gestion des erreurs spécifiques de l'API avec ErrorHandler
//       String errorMessage = 'Erreur lors de la mise à jour du profil';
      
//       if (authProvider.errorMessage != null) {
//         final apiError = authProvider.errorMessage!.toLowerCase();
        
//         if (apiError.contains('email') && apiError.contains('already')) {
//           errorMessage = 'Cette adresse email est déjà utilisée par un autre compte';
//         } else if (apiError.contains('phone') && apiError.contains('already')) {
//           errorMessage = 'Ce numéro de téléphone est déjà utilisé par un autre compte';
//         } else if (apiError.contains('validation')) {
//           errorMessage = 'Données invalides, vérifiez vos informations';
//         } else if (apiError.contains('connexion') || apiError.contains('internet') || apiError.contains('network')) {
//           errorMessage = 'Problème de connexion, vérifiez votre internet';
//         } else if (apiError.contains('server') || apiError.contains('serveur')) {
//           errorMessage = 'Erreur du serveur, réessayez plus tard';
//         } else {
//           errorMessage = authProvider.errorMessage!;
//         }
//       }
      
//       ErrorHandler.showErrorSnackBar(context, errorMessage);
//     }

//   } catch (e) {
//     if (mounted) {
//       ErrorHandler.showErrorSnackBar(
//         context, 
//         'Une erreur inattendue s\'est produite. Veuillez réessayer.'
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }

// // 6. OPTIONNEL : AJOUTER UNE VALIDATION EN TEMPS RÉEL
// // Dans vos _buildTextField(), ajouter onChanged pour validation en temps réel :

// Widget _buildTextField({
//   required TextEditingController controller,
//   required String label,
//   bool isRequired = false,
//   TextInputType? keyboardType,
//   int maxLines = 1,
//   bool hasError = false,
// }) {
//   // Déterminer la clé du champ pour la validation
//   String originalKey = '';
//   if (controller == _firstNameController) originalKey = 'nom';
//   else if (controller == _emailController) originalKey = 'email';
//   else if (controller == _phoneController) originalKey = 'telephone';
//   // ... autres champs

//   bool isModified = originalKey.isNotEmpty && 
//                    controller.text.trim() != _originalData[originalKey];

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       RichText(
//         text: TextSpan(
//           text: label,
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: AppColors.textPrimary,
//           ),
//           children: [
//             if (isRequired)
//               TextSpan(
//                 text: ' *',
//                 style: TextStyle(color: AppColors.error),
//               ),
//             if (isModified)
//               TextSpan(
//                 text: ' (modifié)',
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//           ],
//         ),
//       ),
//       const SizedBox(height: 8),
//       TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         maxLines: maxLines,
//         onChanged: (value) {
//           // Validation en temps réel si nécessaire
//           _checkForChanges();
          
//           // Effacer l'erreur spécifique si elle existe
//           if (_fieldErrors.containsKey(originalKey)) {
//             setState(() {
//               _fieldErrors.remove(originalKey);
//             });
//           }
//         },
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: AppColors.textPrimary,
//         ),
//         decoration: InputDecoration(
//           hintText: 'Saisir $label',
//           hintStyle: GoogleFonts.poppins(
//             color: AppColors.textSecondary.withOpacity(0.6),
//             fontWeight: FontWeight.w400,
//           ),
//           filled: true,
//           fillColor: AppColors.surfaceVariant,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError 
//                   ? AppColors.error.withOpacity(0.5)
//                   : isModified 
//                       ? AppColors.primary.withOpacity(0.3)
//                       : AppColors.border.withOpacity(0.3)
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError ? AppColors.error : AppColors.primary, 
//               width: 2
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.error, width: 1),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: AppColors.error, width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//         ),
//       ),
//     ],
//   );
// }