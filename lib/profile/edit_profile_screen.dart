// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:saarflex_app/providers/auth_provider.dart';
// import '../../constants/colors.dart';
// import '../../utils/error_handler.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _birthPlaceController = TextEditingController();
//   final _nationalityController = TextEditingController();
//   final _professionController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _idNumberController = TextEditingController();

//   String _selectedGender = 'Masculin';
//   String _selectedIdType = 'Carte Nationale d\'Identité';

//   final List<String> _genderOptions = ['Masculin', 'Féminin'];
//   final List<String> _idTypeOptions = [
//     'Carte Nationale d\'Identité',
//     'Passeport',
//     'Permis de Conduire',
//     'Carte de Séjour',
//   ];

//   bool _isLoading = false;
//   bool _hasChanges = false;
//   Map<String, dynamic> _originalData = {};

//   Map<String, String?> _fieldErrors = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _addListeners();
//   }

//   void _addListeners() {
//     _firstNameController.addListener(_checkForChanges);
//     _birthPlaceController.addListener(_checkForChanges);
//     _nationalityController.addListener(_checkForChanges);
//     _professionController.addListener(_checkForChanges);
//     _phoneController.addListener(_checkForChanges);
//     _emailController.addListener(_checkForChanges);
//     _addressController.addListener(_checkForChanges);
//     _idNumberController.addListener(_checkForChanges);
//   }

//   void _checkForChanges() {
//     final currentData = {
//       'nom': _firstNameController.text.trim(),
//       'email': _emailController.text.trim(),
//       'telephone': _phoneController.text.trim(),
//       'lieu_naissance': _birthPlaceController.text.trim(),
//       'nationalite': _nationalityController.text.trim(),
//       'profession': _professionController.text.trim(),
//       'adresse': _addressController.text.trim(),
//       'numero_piece_identite': _idNumberController.text.trim(),
//       'sexe': _selectedGender,
//       'type_piece_identite': _selectedIdType,
//     };

//     bool hasChanged = false;
//     for (String key in currentData.keys) {
//       if (currentData[key] != _originalData[key]) {
//         hasChanged = true;
//         break;
//       }
//     }

//     if (_hasChanges != hasChanged) {
//       setState(() {
//         _hasChanges = hasChanged;
//         _fieldErrors.clear();
//       });
//     }
//   }

//   void _onDropdownChanged() {
//     _checkForChanges();
//   }

//   void _loadUserData() {
//     final authProvider = context.read<AuthProvider>();
//     final user = authProvider.currentUser;

//     if (user != null) {
//       _firstNameController.text = user.nom;
//       _emailController.text = user.email;
//       _phoneController.text = user.telephone ?? '';
//       _birthPlaceController.text = user.lieuNaissance ?? '';
//       _nationalityController.text = user.nationalite ?? '';
//       _professionController.text = user.profession ?? '';
//       _addressController.text = user.adresse ?? '';
//       _idNumberController.text = user.numeroPieceIdentite ?? '';

//       if (user.sexe != null) {
//         _selectedGender = user.sexe == 'masculin' ? 'Masculin' : 'Féminin';
//       }

//       if (user.typePieceIdentite != null) {
//         _selectedIdType = _getTypePieceIdentiteLabel(user.typePieceIdentite!);
//       }

//       _originalData = {
//         'nom': user.nom,
//         'email': user.email,
//         'telephone': user.telephone ?? '',
//         'lieu_naissance': user.lieuNaissance ?? '',
//         'nationalite': user.nationalite ?? '',
//         'profession': user.profession ?? '',
//         'adresse': user.adresse ?? '',
//         'numero_piece_identite': user.numeroPieceIdentite ?? '',
//         'sexe': _selectedGender,
//         'type_piece_identite': _selectedIdType,
//       };
//     }
//   }

//   String _getTypePieceIdentiteLabel(String type) {
//     switch (type.toLowerCase()) {
//       case 'cni':
//         return 'Carte Nationale d\'Identité';
//       case 'passport':
//         return 'Passeport';
//       case 'permis':
//         return 'Permis de Conduire';
//       case 'carte_sejour':
//         return 'Carte de Séjour';
//       default:
//         return 'Carte Nationale d\'Identité';
//     }
//   }

//   Map<String, String?> _validateChangedFields() {
//     Map<String, String?> errors = {};

//     if (_firstNameController.text.trim() != _originalData['nom']) {
//       final nameError = ErrorHandler.validateName(_firstNameController.text);
//       if (nameError != null) {
//         errors['nom'] = nameError;
//       }
//     }

//     if (_emailController.text.trim() != _originalData['email']) {
//       final emailError = ErrorHandler.validateEmail(_emailController.text);
//       if (emailError != null) {
//         errors['email'] = emailError;
//       }
//     }

//     if (_phoneController.text.trim() != _originalData['telephone']) {
//       final phoneError = ErrorHandler.validatePhone(_phoneController.text);
//       if (phoneError != null) {
//         errors['telephone'] = phoneError;
//       }
//     }

//     return errors;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: CustomScrollView(
//         slivers: [
//           _buildSliverAppBar(),
//           SliverPadding(
//             padding: const EdgeInsets.all(24),
//             sliver: SliverToBoxAdapter(
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildProfileHeader(),
//                     const SizedBox(height: 40),

//                     if (_fieldErrors.isNotEmpty) ...[
//                       ErrorHandler.buildErrorList(
//                         _fieldErrors.values
//                             .where((error) => error != null)
//                             .cast<String>()
//                             .toList(),
//                       ),
//                       const SizedBox(height: 20),
//                     ],

//                     _buildPersonalSection(),
//                     const SizedBox(height: 32),
//                     _buildContactSection(),
//                     const SizedBox(height: 32),
//                     _buildIdentitySection(),
//                     const SizedBox(height: 40),
//                     _buildSaveButton(),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: false,
//       pinned: true,
//       backgroundColor: AppColors.primary,
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.white),
//         onPressed: () => Navigator.pop(context),
//       ),
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           "Édition du profil",
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: AppColors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     final user = context.read<AuthProvider>().currentUser;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow,
//             spreadRadius: 0,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 width: 90,
//                 height: 90,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.primary.withOpacity(0.3),
//                       spreadRadius: 0,
//                       blurRadius: 15,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: user?.avatarUrl != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(45),
//                         child: Image.network(
//                           user!.avatarUrl!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Icon(
//                               Icons.person_rounded,
//                               color: AppColors.white,
//                               size: 45,
//                             );
//                           },
//                         ),
//                       )
//                     : Icon(
//                         Icons.person_rounded,
//                         color: AppColors.white,
//                         size: 45,
//                       ),
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 0,
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: AppColors.secondary,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: AppColors.white, width: 2),
//                   ),
//                   child: Icon(
//                     Icons.camera_alt_rounded,
//                     color: AppColors.white,
//                     size: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "Modifiez vos informations",
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             "Vous pouvez modifier un ou plusieurs champs",
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPersonalSection() {
//     return _buildFormSection(
//       title: "Informations personnelles",
//       icon: Icons.person_rounded,
//       children: [
//         _buildTextField(
//           controller: _firstNameController,
//           label: 'Nom complet',
//           isRequired: true,
//           hasError: _fieldErrors.containsKey('nom'),
//         ),
//         const SizedBox(height: 20),
//         _buildDropdownField(
//           value: _selectedGender,
//           items: _genderOptions,
//           label: 'Sexe',
//           onChanged: (value) {
//             setState(() => _selectedGender = value!);
//             _onDropdownChanged();
//           },
//         ),
//         const SizedBox(height: 20),
//         _buildTextField(
//           controller: _birthPlaceController,
//           label: 'Lieu de naissance',
//         ),
//         const SizedBox(height: 20),
//         _buildTextField(
//           controller: _nationalityController,
//           label: 'Nationalité',
//         ),
//         const SizedBox(height: 20),
//         _buildTextField(controller: _professionController, label: 'Profession'),
//       ],
//     );
//   }

//   Widget _buildContactSection() {
//     return _buildFormSection(
//       title: "Coordonnées",
//       icon: Icons.contact_phone_rounded,
//       children: [
//         _buildTextField(
//           controller: _emailController,
//           label: 'Adresse email',
//           isRequired: true,
//           keyboardType: TextInputType.emailAddress,
//           hasError: _fieldErrors.containsKey('email'),
//         ),
//         const SizedBox(height: 20),
//         _buildTextField(
//           controller: _phoneController,
//           label: 'Numéro de téléphone',
//           isRequired: true,
//           keyboardType: TextInputType.phone,
//           hasError: _fieldErrors.containsKey('telephone'),
//         ),
//         const SizedBox(height: 20),
//         _buildTextField(
//           controller: _addressController,
//           label: 'Adresse de résidence',
//           maxLines: 3,
//         ),
//       ],
//     );
//   }

//   Widget _buildIdentitySection() {
//     return _buildFormSection(
//       title: "Pièce d'identité",
//       icon: Icons.badge_rounded,
//       children: [
//         _buildDropdownField(
//           value: _selectedIdType,
//           items: _idTypeOptions,
//           label: 'Type de pièce',
//           onChanged: (value) {
//             setState(() => _selectedIdType = value!);
//             _onDropdownChanged();
//           },
//         ),
//         const SizedBox(height: 20),
//         _buildTextField(
//           controller: _idNumberController,
//           label: 'Numéro de pièce',
//         ),
//       ],
//     );
//   }

//   Widget _buildFormSection({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(icon, color: AppColors.primary, size: 20),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     bool isRequired = false,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//     bool hasError = false,
//   }) {
//     String originalKey = '';
//     if (controller == _firstNameController)
//       originalKey = 'nom';
//     else if (controller == _emailController)
//       originalKey = 'email';
//     else if (controller == _phoneController)
//       originalKey = 'telephone';
//     else if (controller == _birthPlaceController)
//       originalKey = 'lieu_naissance';
//     else if (controller == _nationalityController)
//       originalKey = 'nationalite';
//     else if (controller == _professionController)
//       originalKey = 'profession';
//     else if (controller == _addressController)
//       originalKey = 'adresse';
//     else if (controller == _idNumberController)
//       originalKey = 'numero_piece_identite';

//     bool isModified =
//         originalKey.isNotEmpty &&
//         controller.text.trim() != _originalData[originalKey];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textPrimary,
//             ),
//             children: [
//               if (isRequired)
//                 TextSpan(
//                   text: ' *',
//                   style: TextStyle(color: AppColors.error),
//                 ),
//               if (isModified)
//                 TextSpan(
//                   text: ' (modifié)',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: AppColors.primary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           onChanged: (value) {
//             _checkForChanges();

//             if (_fieldErrors.containsKey(originalKey)) {
//               setState(() {
//                 _fieldErrors.remove(originalKey);
//               });
//             }
//           },
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: AppColors.textPrimary,
//           ),
//           decoration: InputDecoration(
//             hintText: 'Saisir $label',
//             hintStyle: GoogleFonts.poppins(
//               color: AppColors.textSecondary.withOpacity(0.6),
//               fontWeight: FontWeight.w400,
//             ),
//             filled: true,
//             fillColor: AppColors.surfaceVariant,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: hasError
//                     ? AppColors.error.withOpacity(0.5)
//                     : isModified
//                     ? AppColors.primary.withOpacity(0.3)
//                     : AppColors.border.withOpacity(0.3),
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: hasError ? AppColors.error : AppColors.primary,
//                 width: 2,
//               ),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.error, width: 1),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.error, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownField({
//     required String value,
//     required List<String> items,
//     required String label,
//     bool isRequired = false,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textPrimary,
//             ),
//             children: [
//               if (isRequired)
//                 TextSpan(
//                   text: ' *',
//                   style: TextStyle(color: AppColors.error),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: value,
//           items: items.map((String item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Text(
//                 item,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: AppColors.surfaceVariant,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.primary, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 16,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSaveButton() {
//     final bool isEnabled = _hasChanges && !_isLoading;

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isEnabled ? _saveProfile : null,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isEnabled
//               ? AppColors.primary
//               : AppColors.textSecondary.withOpacity(0.3),
//           foregroundColor: isEnabled
//               ? AppColors.white
//               : AppColors.textSecondary,
//           padding: const EdgeInsets.symmetric(vertical: 18),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: isEnabled ? 3 : 0,
//         ),
//         child: _isLoading
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         AppColors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     "Enregistrement...",
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               )
//             : Text(
//                 _hasChanges
//                     ? "Enregistrer les modifications"
//                     : "Aucune modification",
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }

//   Future<void> _saveProfile() async {
//     setState(() {
//       _isLoading = true;
//       _fieldErrors.clear();
//     });

//     try {
//       final errors = _validateChangedFields();

//       if (errors.isNotEmpty) {
//         setState(() {
//           _fieldErrors = errors;
//           _isLoading = false;
//         });
//         ErrorHandler.showErrorSnackBar(
//           context,
//           'Veuillez corriger les erreurs ci-dessus',
//         );
//         return;
//       }

//       final authProvider = context.read<AuthProvider>();

//       final Map<String, dynamic> profileData = {};

//       if (_firstNameController.text.trim() != _originalData['nom']) {
//         profileData['nom'] = _firstNameController.text.trim();
//       }

//       if (_emailController.text.trim() != _originalData['email']) {
//         profileData['email'] = _emailController.text.trim();
//       }

//       if (_phoneController.text.trim() != _originalData['telephone']) {
//         profileData['telephone'] = _phoneController.text.trim();
//       }

//       if (_birthPlaceController.text.trim() !=
//           _originalData['lieu_naissance']) {
//         profileData['lieu_naissance'] = _birthPlaceController.text.trim();
//       }

//       if (_nationalityController.text.trim() != _originalData['nationalite']) {
//         profileData['nationalite'] = _nationalityController.text.trim();
//       }

//       if (_professionController.text.trim() != _originalData['profession']) {
//         profileData['profession'] = _professionController.text.trim();
//       }

//       if (_addressController.text.trim() != _originalData['adresse']) {
//         profileData['adresse'] = _addressController.text.trim();
//       }

//       if (_idNumberController.text.trim() !=
//           _originalData['numero_piece_identite']) {
//         profileData['numero_piece_identite'] = _idNumberController.text.trim();
//       }

//       if (_selectedGender != _originalData['sexe']) {
//         profileData['sexe'] = _selectedGender.toLowerCase();
//       }

//       if (_selectedIdType != _originalData['type_piece_identite']) {
//         profileData['type_piece_identite'] = _selectedIdType;
//       }

//       if (profileData.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         ErrorHandler.showWarningSnackBar(
//           context,
//           'Aucune modification détectée',
//         );
//         return;
//       }

//       final success = await authProvider.updateProfile(profileData);

//       if (success && mounted) {
//         ErrorHandler.showSuccessSnackBar(
//           context,
//           'Profil mis à jour avec succès !',
//         );

//         _loadUserData();
//         setState(() {
//           _hasChanges = false;
//         });

//         Future.delayed(const Duration(seconds: 1), () {
//           if (mounted) Navigator.pop(context);
//         });
//       } else if (mounted) {
//         String errorMessage = 'Erreur lors de la mise à jour du profil';

//         if (authProvider.errorMessage != null) {
//           final apiError = authProvider.errorMessage!.toLowerCase();

//           if (apiError.contains('email') && apiError.contains('already')) {
//             errorMessage =
//                 'Cette adresse email est déjà utilisée par un autre compte';
//           } else if (apiError.contains('phone') &&
//               apiError.contains('already')) {
//             errorMessage =
//                 'Ce numéro de téléphone est déjà utilisé par un autre compte';
//           } else if (apiError.contains('validation')) {
//             errorMessage = 'Données invalides, vérifiez vos informations';
//           } else if (apiError.contains('connexion') ||
//               apiError.contains('internet') ||
//               apiError.contains('network')) {
//             errorMessage = 'Problème de connexion, vérifiez votre internet';
//           } else if (apiError.contains('server') ||
//               apiError.contains('serveur')) {
//             errorMessage = 'Erreur du serveur, réessayez plus tard';
//           } else {
//             errorMessage = authProvider.errorMessage!;
//           }
//         }

//         ErrorHandler.showErrorSnackBar(context, errorMessage);
//       }
//     } catch (e) {
//       if (mounted) {
//         ErrorHandler.showErrorSnackBar(
//           context,
//           'Une erreur inattendue s\'est produite. Veuillez réessayer.',
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _firstNameController.removeListener(_checkForChanges);
//     _birthPlaceController.removeListener(_checkForChanges);
//     _nationalityController.removeListener(_checkForChanges);
//     _professionController.removeListener(_checkForChanges);
//     _phoneController.removeListener(_checkForChanges);
//     _emailController.removeListener(_checkForChanges);
//     _addressController.removeListener(_checkForChanges);
//     _idNumberController.removeListener(_checkForChanges);

//     _firstNameController.dispose();
//     _birthPlaceController.dispose();
//     _nationalityController.dispose();
//     _professionController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     _idNumberController.dispose();
//     super.dispose();
//   }
// }




import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import 'package:intl/intl.dart'; // Ajoutez cet import
import '../../constants/colors.dart';
import '../../utils/error_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _professionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();

  String _selectedGender = 'Masculin';
  String _selectedIdType = 'Carte Nationale d\'Identité';
  
  // Ajout des variables pour les dates
  DateTime? _selectedBirthDate;
  DateTime? _selectedExpirationDate;

  final List<String> _genderOptions = ['Masculin', 'Féminin'];
  final List<String> _idTypeOptions = [
    'Carte Nationale d\'Identité',
    'Passeport',
    'Permis de Conduire',
    'Carte de Séjour',
  ];

  bool _isLoading = false;
  bool _hasChanges = false;
  Map<String, dynamic> _originalData = {};

  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _addListeners();
  }

  void _addListeners() {
    _firstNameController.addListener(_checkForChanges);
    _birthPlaceController.addListener(_checkForChanges);
    _nationalityController.addListener(_checkForChanges);
    _professionController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _idNumberController.addListener(_checkForChanges);
  }





void _checkForChanges() {
  // Formatage des dates pour la comparaison
  String? currentBirthDate;
  String? currentExpirationDate;
  
  if (_selectedBirthDate != null) {
    currentBirthDate = DateFormat('dd-MM-yyyy').format(_selectedBirthDate!);
  }
  
  if (_selectedExpirationDate != null) {
    currentExpirationDate = DateFormat('dd-MM-yyyy').format(_selectedExpirationDate!);
  }

  final currentData = {
    'nom': _firstNameController.text.trim(),
    'email': _emailController.text.trim(),
    'telephone': _phoneController.text.trim(),
    'lieu_naissance': _birthPlaceController.text.trim(),
    'nationalite': _nationalityController.text.trim(),
    'profession': _professionController.text.trim(),
    'adresse': _addressController.text.trim(),
    'numero_piece_identite': _idNumberController.text.trim(),
    'sexe': _selectedGender,
    'type_piece_identite': _selectedIdType,
    'date_naissance': currentBirthDate,
    'date_expiration_piece_identite': currentExpirationDate,
  };

  bool hasChanged = false;
  for (String key in currentData.keys) {
    if (currentData[key] != _originalData[key]) {
      hasChanged = true;
      break;
    }
  }

  if (_hasChanges != hasChanged) {
    setState(() {
      _hasChanges = hasChanged;
      _fieldErrors.clear();
    });
  }
}


  // void _checkForChanges() {
  //   final currentData = {
  //     'nom': _firstNameController.text.trim(),
  //     'email': _emailController.text.trim(),
  //     'telephone': _phoneController.text.trim(),
  //     'lieu_naissance': _birthPlaceController.text.trim(),
  //     'nationalite': _nationalityController.text.trim(),
  //     'profession': _professionController.text.trim(),
  //     'adresse': _addressController.text.trim(),
  //     'numero_piece_identite': _idNumberController.text.trim(),
  //     'sexe': _selectedGender,
  //     'type_piece_identite': _selectedIdType,
  //     'date_naissance': _selectedBirthDate?.toIso8601String(),
  //     'date_expiration_piece': _selectedExpirationDate?.toIso8601String(),
  //   };

  //   bool hasChanged = false;
  //   for (String key in currentData.keys) {
  //     if (currentData[key] != _originalData[key]) {
  //       hasChanged = true;
  //       break;
  //     }
  //   }

  //   if (_hasChanges != hasChanged) {
  //     setState(() {
  //       _hasChanges = hasChanged;
  //       _fieldErrors.clear();
  //     });
  //   }
  // }

  void _onDropdownChanged() {
    _checkForChanges();
  }

  void _onDateChanged() {
    _checkForChanges();
  }




void _loadUserData() {
  final authProvider = context.read<AuthProvider>();
  final user = authProvider.currentUser;

  if (user != null) {
    _firstNameController.text = user.nom;
    _emailController.text = user.email;
    _phoneController.text = user.telephone ?? '';
    _birthPlaceController.text = user.lieuNaissance ?? '';
    _nationalityController.text = user.nationalite ?? '';
    _professionController.text = user.profession ?? '';
    _addressController.text = user.adresse ?? '';
    _idNumberController.text = user.numeroPieceIdentite ?? '';

    // Charger les dates
    _selectedBirthDate = user.dateNaissance;
    _selectedExpirationDate = user.dateExpirationPiece;

    if (user.sexe != null) {
      _selectedGender = user.sexe == 'masculin' ? 'Masculin' : 'Féminin';
    }

    if (user.typePieceIdentite != null) {
      _selectedIdType = _getTypePieceIdentiteLabel(user.typePieceIdentite!);
    }

    // Formatage des dates originales en DD-MM-YYYY pour les comparaisons
    String? originalBirthDate;
    String? originalExpirationDate;
    
    if (user.dateNaissance != null) {
      originalBirthDate = DateFormat('dd-MM-yyyy').format(user.dateNaissance!);
    }
    
    if (user.dateExpirationPiece != null) {
      originalExpirationDate = DateFormat('dd-MM-yyyy').format(user.dateExpirationPiece!);
    }

    _originalData = {
      'nom': user.nom,
      'email': user.email,
      'telephone': user.telephone ?? '',
      'lieu_naissance': user.lieuNaissance ?? '',
      'nationalite': user.nationalite ?? '',
      'profession': user.profession ?? '',
      'adresse': user.adresse ?? '',
      'numero_piece_identite': user.numeroPieceIdentite ?? '',
      'sexe': _selectedGender,
      'type_piece_identite': _selectedIdType,
      'date_naissance': originalBirthDate,
      'date_expiration_piece_identite': originalExpirationDate,
    };
  }
}


  // void _loadUserData() {
  //   final authProvider = context.read<AuthProvider>();
  //   final user = authProvider.currentUser;

  //   if (user != null) {
  //     _firstNameController.text = user.nom;
  //     _emailController.text = user.email;
  //     _phoneController.text = user.telephone ?? '';
  //     _birthPlaceController.text = user.lieuNaissance ?? '';
  //     _nationalityController.text = user.nationalite ?? '';
  //     _professionController.text = user.profession ?? '';
  //     _addressController.text = user.adresse ?? '';
  //     _idNumberController.text = user.numeroPieceIdentite ?? '';

  //     // Charger les dates
  //     _selectedBirthDate = user.dateNaissance;
  //     _selectedExpirationDate = user.dateExpirationPiece;

  //     if (user.sexe != null) {
  //       _selectedGender = user.sexe == 'masculin' ? 'Masculin' : 'Féminin';
  //     }

  //     if (user.typePieceIdentite != null) {
  //       _selectedIdType = _getTypePieceIdentiteLabel(user.typePieceIdentite!);
  //     }

  //     _originalData = {
  //       'nom': user.nom,
  //       'email': user.email,
  //       'telephone': user.telephone ?? '',
  //       'lieu_naissance': user.lieuNaissance ?? '',
  //       'nationalite': user.nationalite ?? '',
  //       'profession': user.profession ?? '',
  //       'adresse': user.adresse ?? '',
  //       'numero_piece_identite': user.numeroPieceIdentite ?? '',
  //       'sexe': _selectedGender,
  //       'type_piece_identite': _selectedIdType,
  //       'date_naissance': user.dateNaissance?.toIso8601String(),
  //       'date_expiration_piece': user.dateExpirationPiece?.toIso8601String(),
  //     };
  //   }
  // }

  String _getTypePieceIdentiteLabel(String type) {
    switch (type.toLowerCase()) {
      case 'cni':
        return 'Carte Nationale d\'Identité';
      case 'passport':
        return 'Passeport';
      case 'permis':
        return 'Permis de Conduire';
      case 'carte_sejour':
        return 'Carte de Séjour';
      default:
        return 'Carte Nationale d\'Identité';
    }
  }

  Map<String, String?> _validateChangedFields() {
    Map<String, String?> errors = {};

    if (_firstNameController.text.trim() != _originalData['nom']) {
      final nameError = ErrorHandler.validateName(_firstNameController.text);
      if (nameError != null) {
        errors['nom'] = nameError;
      }
    }

    if (_emailController.text.trim() != _originalData['email']) {
      final emailError = ErrorHandler.validateEmail(_emailController.text);
      if (emailError != null) {
        errors['email'] = emailError;
      }
    }

    if (_phoneController.text.trim() != _originalData['telephone']) {
      final phoneError = ErrorHandler.validatePhone(_phoneController.text);
      if (phoneError != null) {
        errors['telephone'] = phoneError;
      }
    }

    // Validation des dates
    if (_selectedBirthDate != null) {
      final now = DateTime.now();
      final minAge = DateTime(now.year - 120, now.month, now.day);
      final maxAge = DateTime(now.year - 16, now.month, now.day);

      if (_selectedBirthDate!.isAfter(maxAge)) {
        errors['date_naissance'] = 'Vous devez avoir au moins 16 ans';
      } else if (_selectedBirthDate!.isBefore(minAge)) {
        errors['date_naissance'] = 'Date de naissance invalide';
      }
    }

    if (_selectedExpirationDate != null) {
      final now = DateTime.now();
      if (_selectedExpirationDate!.isBefore(now)) {
        errors['date_expiration_piece_identite'] = 'La date d\'expiration ne peut pas être dans le passé';
      }
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Édition du profil",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 40),

              if (_fieldErrors.isNotEmpty) ...[
                ErrorHandler.buildErrorList(
                  _fieldErrors.values
                      .where((error) => error != null)
                      .cast<String>()
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              _buildPersonalSection(),
              const SizedBox(height: 32),
              _buildContactSection(),
              const SizedBox(height: 32),
              _buildIdentitySection(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = context.read<AuthProvider>().currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: user?.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_rounded,
                              color: AppColors.white,
                              size: 45,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size: 45,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Modifiez vos informations",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Vous pouvez modifier un ou plusieurs champs",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection() {
    return _buildFormSection(
      title: "Informations personnelles",
      icon: Icons.person_rounded,
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'Nom complet',
          isRequired: true,
          hasError: _fieldErrors.containsKey('nom'),
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          value: _selectedGender,
          items: _genderOptions,
          label: 'Sexe',
          onChanged: (value) {
            setState(() => _selectedGender = value!);
            _onDropdownChanged();
          },
        ),
        const SizedBox(height: 20),
        _buildDateField(
          selectedDate: _selectedBirthDate,
          label: 'Date de naissance',
          onDateSelected: (date) {
            setState(() => _selectedBirthDate = date);
            _onDateChanged();
          },
          hasError: _fieldErrors.containsKey('date_naissance'),
          isRequired: false,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _birthPlaceController,
          label: 'Lieu de naissance',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _nationalityController,
          label: 'Nationalité',
        ),
        const SizedBox(height: 20),
        _buildTextField(controller: _professionController, label: 'Profession'),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildFormSection(
      title: "Coordonnées",
      icon: Icons.contact_phone_rounded,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Adresse email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          hasError: _fieldErrors.containsKey('email'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          isRequired: true,
          keyboardType: TextInputType.phone,
          hasError: _fieldErrors.containsKey('telephone'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: 'Adresse de résidence',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildIdentitySection() {
    return _buildFormSection(
      title: "Pièce d'identité",
      icon: Icons.badge_rounded,
      children: [
        _buildDropdownField(
          value: _selectedIdType,
          items: _idTypeOptions,
          label: 'Type de pièce',
          onChanged: (value) {
            setState(() => _selectedIdType = value!);
            _onDropdownChanged();
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _idNumberController,
          label: 'Numéro de pièce',
        ),
        const SizedBox(height: 20),
        _buildDateField(
          selectedDate: _selectedExpirationDate,
          label: 'Date d\'expiration de la pièce',
          onDateSelected: (date) {
            setState(() => _selectedExpirationDate = date);
            _onDateChanged();
          },
          hasError: _fieldErrors.containsKey('date_expiration_piece_identite'),
          isRequired: false,
          isExpirationDate: true,
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool hasError = false,
  }) {
    String originalKey = '';
    if (controller == _firstNameController)
      originalKey = 'nom';
    else if (controller == _emailController)
      originalKey = 'email';
    else if (controller == _phoneController)
      originalKey = 'telephone';
    else if (controller == _birthPlaceController)
      originalKey = 'lieu_naissance';
    else if (controller == _nationalityController)
      originalKey = 'nationalite';
    else if (controller == _professionController)
      originalKey = 'profession';
    else if (controller == _addressController)
      originalKey = 'adresse';
    else if (controller == _idNumberController)
      originalKey = 'numero_piece_identite';

    bool isModified =
        originalKey.isNotEmpty &&
        controller.text.trim() != _originalData[originalKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              if (isModified)
                TextSpan(
                  text: ' (modifié)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) {
            _checkForChanges();

            if (_fieldErrors.containsKey(originalKey)) {
              setState(() {
                _fieldErrors.remove(originalKey);
              });
            }
          },
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Saisir $label',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error.withOpacity(0.5)
                    : isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required DateTime? selectedDate,
    required String label,
    required Function(DateTime?) onDateSelected,
    bool isRequired = false,
    bool hasError = false,
    bool isExpirationDate = false,
  }) {
    String originalKey = isExpirationDate ? 'date_expiration_piece_identite' : 'date_naissance';
    String? originalDateStr = _originalData[originalKey];
    DateTime? originalDate = originalDateStr != null ? DateTime.tryParse(originalDateStr) : null;
    
    bool isModified = selectedDate != originalDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
              if (isModified)
                TextSpan(
                  text: ' (modifié)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, selectedDate, onDateSelected, isExpirationDate),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withOpacity(0.5)
                    : isModified
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: hasError ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : 'Sélectionner $label',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError && _fieldErrors[originalKey] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _fieldErrors[originalKey]!,
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

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    bool isRequired = false,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onDateSelected,
    bool isExpirationDate,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = isExpirationDate
        ? now // Pour date expiration, on peut sélectionner à partir d'aujourd'hui
        : DateTime(now.year - 120, now.month, now.day); // Pour naissance, 120 ans max
    final DateTime lastDate = isExpirationDate
        ? DateTime(now.year + 20, now.month, now.day) // Expiration max 20 ans
        : DateTime(now.year - 16, now.month, now.day); // Naissance max il y a 16 ans

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? (isExpirationDate ? now : lastDate),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget _buildSaveButton() {
    final bool isEnabled = _hasChanges && !_isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _saveProfile : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.3),
          foregroundColor: isEnabled
              ? AppColors.white
              : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Enregistrement...",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                _hasChanges
                    ? "Enregistrer les modifications"
                    : "Aucune modification",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _fieldErrors.clear();
    });

    try {
      final errors = _validateChangedFields();

      if (errors.isNotEmpty) {
        setState(() {
          _fieldErrors = errors;
          _isLoading = false;
        });
        ErrorHandler.showErrorSnackBar(
          context,
          'Veuillez corriger les erreurs ci-dessus',
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final Map<String, dynamic> profileData = {};

      // Debug: Afficher les données
      print('=== DEBUG PROFIL ===');
      print('Date naissance originale: ${_originalData['date_naissance']}');
      print('Date expiration originale: ${_originalData['date_expiration_piece_identite']}');
      print('Date naissance sélectionnée: $_selectedBirthDate');
      print('Date expiration sélectionnée: $_selectedExpirationDate');

      // Vérifier chaque champ modifié
      if (_firstNameController.text.trim() != _originalData['nom']) {
        profileData['nom'] = _firstNameController.text.trim();
      }

      if (_emailController.text.trim() != _originalData['email']) {
        profileData['email'] = _emailController.text.trim();
      }

      if (_phoneController.text.trim() != _originalData['telephone']) {
        profileData['telephone'] = _phoneController.text.trim();
      }

      if (_birthPlaceController.text.trim() != _originalData['lieu_naissance']) {
        profileData['lieu_naissance'] = _birthPlaceController.text.trim();
      }

      if (_nationalityController.text.trim() != _originalData['nationalite']) {
        profileData['nationalite'] = _nationalityController.text.trim();
      }

      if (_professionController.text.trim() != _originalData['profession']) {
        profileData['profession'] = _professionController.text.trim();
      }

      if (_addressController.text.trim() != _originalData['adresse']) {
        profileData['adresse'] = _addressController.text.trim();
      }

      if (_idNumberController.text.trim() != _originalData['numero_piece_identite']) {
        profileData['numero_piece_identite'] = _idNumberController.text.trim();
      }

      if (_selectedGender != _originalData['sexe']) {
        profileData['sexe'] = _selectedGender.toLowerCase();
      }

      if (_selectedIdType != _originalData['type_piece_identite']) {
        profileData['type_piece_identite'] = _selectedIdType;
      }

      // Gestion des dates


      if (_selectedBirthDate != null) {
  String newBirthDate = DateFormat('dd-MM-yyyy').format(_selectedBirthDate!);
  print('Date naissance formatée pour API: $newBirthDate');
  
  // Correction : _originalData['date_naissance'] est déjà au format dd-MM-yyyy
  String originalFormatted = _originalData['date_naissance'] ?? '';
  
  if (newBirthDate != originalFormatted) {
    profileData['date_naissance'] = newBirthDate;
    print('Date naissance ajoutée aux données: $newBirthDate');
  }
}

if (_selectedExpirationDate != null) {
  String newExpirationDate = DateFormat('dd-MM-yyyy').format(_selectedExpirationDate!);
  print('Date expiration formatée pour API: $newExpirationDate');
  
  // Correction : _originalData['date_expiration_piece_identite'] est déjà au format dd-MM-yyyy
  String originalFormatted = _originalData['date_expiration_piece_identite'] ?? '';
  
  if (newExpirationDate != originalFormatted) {
    profileData['date_expiration_piece_identite'] = newExpirationDate;
    print('Date expiration ajoutée aux données: $newExpirationDate');
  }
}
//      if (_selectedBirthDate != null) {
//   String newBirthDate = DateFormat('dd-MM-yyyy').format(_selectedBirthDate!);
//   print('Date naissance formatée pour API: $newBirthDate');
  
//   String originalFormatted = _originalData['date_naissance'] != null 
//       ? DateFormat('dd-MM-yyyy').format(DateTime.parse(_originalData['date_naissance']))
//       : '';
  
//   if (newBirthDate != originalFormatted) {
//     profileData['date_naissance'] = newBirthDate;
//     print('Date naissance ajoutée aux données: $newBirthDate');
//   }
// }

// if (_selectedExpirationDate != null) {
//   String newExpirationDate = DateFormat('dd-MM-yyyy').format(_selectedExpirationDate!);
//   print('Date expiration formatée pour API: $newExpirationDate');
  
//   String originalFormatted = _originalData['date_expiration_piece_identite'] != null 
//       ? DateFormat('dd-MM-yyyy').format(DateTime.parse(_originalData['date_expiration_piece_identite']))
//       : '';
  
//   if (newExpirationDate != originalFormatted) {
//     profileData['date_expiration_piece_identite'] = newExpirationDate;
//     print('Date expiration ajoutée aux données: $newExpirationDate');
//   }
// }

      print('Données finales à envoyer: $profileData');

      if (profileData.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ErrorHandler.showWarningSnackBar(
          context,
          'Aucune modification détectée',
        );
        return;
      }

      final success = await authProvider.updateProfile(profileData);

      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Profil mis à jour avec succès !',
        );

        _loadUserData();
        setState(() {
          _hasChanges = false;
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      } else if (mounted) {
        String errorMessage = 'Erreur lors de la mise à jour du profil';

        if (authProvider.errorMessage != null) {
          final apiError = authProvider.errorMessage!.toLowerCase();
          print('Erreur API: $apiError');

          if (apiError.contains('date')) {
            errorMessage = 'Erreur avec les dates. Vérifiez le format.';
          } else if (apiError.contains('email') && apiError.contains('already')) {
            errorMessage = 'Cette adresse email est déjà utilisée par un autre compte';
          } else if (apiError.contains('phone') && apiError.contains('already')) {
            errorMessage = 'Ce numéro de téléphone est déjà utilisé par un autre compte';
          } else if (apiError.contains('validation')) {
            errorMessage = 'Données invalides, vérifiez vos informations';
          } else if (apiError.contains('connexion') || 
                     apiError.contains('internet') || 
                     apiError.contains('network')) {
            errorMessage = 'Problème de connexion, vérifiez votre internet';
          } else if (apiError.contains('server') || apiError.contains('serveur')) {
            errorMessage = 'Erreur du serveur, réessayez plus tard';
          } else {
            errorMessage = authProvider.errorMessage!;
          }
        }

        ErrorHandler.showErrorSnackBar(context, errorMessage);
      }
    } catch (e) {
      print('Exception dans _saveProfile: $e');
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Une erreur inattendue s\'est produite. Veuillez réessayer.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_checkForChanges);
    _birthPlaceController.removeListener(_checkForChanges);
    _nationalityController.removeListener(_checkForChanges);
    _professionController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _emailController.removeListener(_checkForChanges);
    _addressController.removeListener(_checkForChanges);
    _idNumberController.removeListener(_checkForChanges);

    _firstNameController.dispose();
    _birthPlaceController.dispose();
    _nationalityController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }
}
