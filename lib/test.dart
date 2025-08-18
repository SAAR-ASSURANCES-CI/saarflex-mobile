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
//   final _birthDateController = TextEditingController();
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
//     _birthDateController.addListener(_checkForChanges);
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
//       'date_naissance': _birthDateController.text.trim(),
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

//       // Charger la date de naissance si elle existe
//       if (user.dateNaissance != null) {
//         final date = user.dateNaissance!;
//         _birthDateController.text = "${date.day.toString().padLeft(2, '0')}/"
//             "${date.month.toString().padLeft(2, '0')}/"
//             "${date.year}";
//       }

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
//         'date_naissance': _birthDateController.text,
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

//     // Validation de la date de naissance
//     if (_birthDateController.text.trim() != _originalData['date_naissance'] && 
//         _birthDateController.text.trim().isNotEmpty) {
//       final dateError = ErrorHandler.validateBirthDate(_birthDateController.text.trim());
//       if (dateError != null) {
//         errors['date_naissance'] = dateError;
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
//         _buildDateField(
//           controller: _birthDateController,
//           label: 'Date de naissance',
//           hasError: _fieldErrors.containsKey('date_naissance'),
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

//   Widget _buildDateField({
//     required TextEditingController controller,
//     required String label,
//     bool hasError = false,
//   }) {
//     bool isModified = controller.text.trim() != _originalData['date_naissance'];

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
//           readOnly: true,
//           onChanged: (value) {
//             if (_fieldErrors.containsKey('date_naissance')) {
//               setState(() {
//                 _fieldErrors.remove('date_naissance');
//               });
//             }
//           },
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: AppColors.textPrimary,
//           ),
//           decoration: InputDecoration(
//             hintText: 'Sélectionner une date',
//             hintStyle: GoogleFonts.poppins(
//               color: AppColors.textSecondary.withOpacity(0.6),
//               fontWeight: FontWeight.w400,
//             ),
//             suffixIcon: Icon(
//               Icons.calendar_today_rounded,
//               color: AppColors.primary,
//               size: 20,
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
//           onTap: () => _selectDate(controller),
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

//   Future<void> _selectDate(TextEditingController controller) async {
//     try {
//       // Parser la date actuelle dans le controller s'il y en a une
//       DateTime? initialDate = _parseDate(controller.text);
      
//       final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: initialDate ?? DateTime(2000),
//         firstDate: DateTime(1900),
//         lastDate: DateTime.now(),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: ColorScheme.light(
//                 primary: AppColors.primary,
//                 onPrimary: AppColors.white,
//                 surface: AppColors.surface,
//                 onSurface: AppColors.textPrimary,
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );

//       if (picked != null) {
//         controller.text = "${picked.day.toString().padLeft(2, '0')}/"
//             "${picked.month.toString().padLeft(2, '0')}/"
//             "${picked.year}";
//         _checkForChanges();
        
//         // Effacer l'erreur de date si elle existe
//         if (_fieldErrors.containsKey('date_naissance')) {
//           setState(() {
//             _fieldErrors.remove('date_naissance');
//           });
//         }
//       }
//     } catch (e) {
//       // Gestion d'erreur silencieuse
//     }
//   }

//   /// Parse une date au format JJ/MM/AAAA
//   DateTime? _parseDate(String dateString) {
//     try {
//       final parts = dateString.split('/');
//       if (parts.length == 3) {
//         final day = int.parse(parts[0]);
//         final month = int.parse(parts[1]);
//         final year = int.parse(parts[2]);
//         return DateTime(year, month, day);
//       }
//     } catch (e) {
//       // Gestion silencieuse de l'erreur
//     }
//     return null;
//   }

//   Future<void> _saveProfile() async {
//     setState(() {
//       _isLoading = true;
//       _fieldErrors.clear();
//     });

//     try {
//       // Validation des champs modifiés
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

//       // Collecter les modifications
//       if (_firstNameController.text.trim() != _originalData['nom']) {
//         profileData['nom'] = _firstNameController.text.trim();
//       }

//       if (_emailController.text.trim() != _originalData['email']) {
//         profileData['email'] = _emailController.text.trim();
//       }

//       if (_phoneController.text.trim() != _originalData['telephone']) {
//         profileData['telephone'] = _phoneController.text.trim();
//       }

//       if (_birthPlaceController.text.trim() != _originalData['lieu_naissance']) {
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

//       if (_idNumberController.text.trim() != _originalData['numero_piece_identite']) {
//         profileData['numero_piece_identite'] = _idNumberController.text.trim();
//       }

//       if (_selectedGender != _originalData['sexe']) {
//         profileData['sexe'] = _selectedGender.toLowerCase();
//       }

//       if (_selectedIdType != _originalData['type_piece_identite']) {
//         profileData['type_piece_identite'] = _selectedIdType;
//       }
      
//       // Gestion de la date de naissance
//       if (_birthDateController.text.trim() != _originalData['date_naissance']) {
//         if (_birthDateController.text.trim().isNotEmpty) {
//           // Convertir la date du format JJ/MM/AAAA vers DD-MM-YYYY pour l'API
//           final formattedDate = ErrorHandler.formatDateForApi(_birthDateController.text.trim());
//           profileData['date_naissance'] = formattedDate;
//         } else {
//           profileData['date_naissance'] = null;
//         }
//       }

//       // Vérifier s'il y a des modifications
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

//       // Envoyer les modifications
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
//           if (mounted) {
//             Navigator.pop(context);
//           }
//         });
//       } else if (mounted) {
//         final errorMessage = ErrorHandler.analyzeApiError(authProvider.errorMessage);
//         ErrorHandler.showErrorSnackBar(context, errorMessage);
//       }

//     } catch (e) {
//       if (mounted) {
//         ErrorHandler.handleError(context, e);
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
//     // Retirer les listeners
//     _firstNameController.removeListener(_checkForChanges);
//     _birthDateController.removeListener(_checkForChanges);
//     _birthPlaceController.removeListener(_checkForChanges);
//     _nationalityController.removeListener(_checkForChanges);
//     _professionController.removeListener(_checkForChanges);
//     _phoneController.removeListener(_checkForChanges);
//     _emailController.removeListener(_checkForChanges);
//     _addressController.removeListener(_checkForChanges);
//     _idNumberController.removeListener(_checkForChanges);

//     // Disposer les controllers
//     _firstNameController.dispose();
//     _birthDateController.dispose();
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