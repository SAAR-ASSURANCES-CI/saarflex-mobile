import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/profile_helpers.dart';
import 'package:saarciflex_app/data/models/product_model.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/presentation/features/simulation/screens/simulation_screen.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';
import 'package:saarciflex_app/presentation/features/profile/viewmodels/profile_form_controller.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/personal_section.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/contact_section.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/identity_section.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/identity_images_section.dart';

class EditProfileScreenRefactored extends StatefulWidget {
  final VoidCallback? onProfileCompleted;
  final Product? produit;

  const EditProfileScreenRefactored({
    super.key,
    this.onProfileCompleted,
    this.produit,
  });

  @override
  State<EditProfileScreenRefactored> createState() =>
      _EditProfileScreenRefactoredState();
}

class _EditProfileScreenRefactoredState
    extends State<EditProfileScreenRefactored> {
  late ProfileFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = ProfileFormController();
    _formController.loadUserData(context);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _formController,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[600]!,
                  Colors.indigo[700]!,
                ],
              ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded, 
                color: Colors.white,
                size: MediaQuery.of(context).size.width < 360 ? 22 : 26,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            "Édition du profil",
            style: TextStyle(
              fontSize: (22.0 / MediaQuery.of(context).textScaleFactor).clamp(20.0, 26.0),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<ProfileFormController>(
          builder: (context, formController, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final textScaleFactor = MediaQuery.of(context).textScaleFactor;
            final viewInsets = MediaQuery.of(context).viewInsets;
            
            final horizontalPadding = screenWidth < 360 
                ? 16.0 
                : screenWidth < 600 
                    ? 20.0 
                    : (screenWidth * 0.08).clamp(20.0, 48.0);
            final verticalPadding = screenHeight < 600 ? 16.0 : 20.0;
            
            final headerSpacing = screenHeight < 600 ? 32.0 : 40.0;
            final sectionSpacing = screenHeight < 600 ? 24.0 : 32.0;
            final errorSpacing = screenHeight < 600 ? 16.0 : 20.0;
            final buttonSpacing = screenHeight < 600 ? 32.0 : 40.0;
            final bottomSpacing = screenHeight < 600 ? 16.0 : 20.0;
            
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: verticalPadding,
                bottom: bottomSpacing + viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(formController, screenWidth, textScaleFactor),
                  SizedBox(height: headerSpacing),

                  if (formController.fieldErrors.isNotEmpty) ...[
                    ErrorHandler.buildErrorList(
                      formController.fieldErrors.values
                          .where((error) => error != null)
                          .cast<String>()
                          .toList(),
                    ),
                    SizedBox(height: errorSpacing),
                  ],

                  PersonalSection(
                    firstNameController: formController.firstNameController,
                    birthPlaceController: formController.birthPlaceController,
                    nationalityController: formController.nationalityController,
                    professionController: formController.professionController,
                    selectedGender: formController.selectedGender,
                    selectedBirthDate: formController.selectedBirthDate,
                    genderOptions: formController.genderOptions,
                    fieldErrors: formController.fieldErrors,
                    originalData: formController.originalData,
                    onGenderChanged: formController.updateGender,
                    onBirthDateChanged: formController.updateBirthDate,
                    onDropdownChanged: () => formController.checkForChanges(),
                    onDateChanged: () => formController.checkForChanges(),
                    screenWidth: screenWidth,
                    textScaleFactor: textScaleFactor,
                  ),
                  SizedBox(height: sectionSpacing),

                  ContactSection(
                    emailController: formController.emailController,
                    phoneController: formController.phoneController,
                    addressController: formController.addressController,
                    fieldErrors: formController.fieldErrors,
                    originalData: formController.originalData,
                    screenWidth: screenWidth,
                    textScaleFactor: textScaleFactor,
                  ),
                  SizedBox(height: sectionSpacing),

                  IdentitySection(
                    idNumberController: formController.idNumberController,
                    selectedIdType: formController.selectedIdType,
                    selectedExpirationDate:
                        formController.selectedExpirationDate,
                    idTypeOptions: formController.idTypeOptions,
                    fieldErrors: formController.fieldErrors,
                    originalData: formController.originalData,
                    onIdTypeChanged: formController.updateIdType,
                    onExpirationDateChanged:
                        formController.updateExpirationDate,
                    onDropdownChanged: () => formController.checkForChanges(),
                    onDateChanged: () => formController.checkForChanges(),
                    screenWidth: screenWidth,
                    textScaleFactor: textScaleFactor,
                  ),
                  SizedBox(height: sectionSpacing),

                  IdentityImagesSection(
                    currentIdentityType: formController.getBackendIdentityType(
                      formController.selectedIdType,
                    ),
                    frontDocumentPath: context
                        .read<AuthViewModel>()
                        .currentUser
                        ?.frontDocumentPath,
                    backDocumentPath: context
                        .read<AuthViewModel>()
                        .currentUser
                        ?.backDocumentPath,
                    isUploadingRecto: formController.isUploadingRecto,
                    isUploadingVerso: formController.isUploadingVerso,
                    rectoImage: formController.rectoImage,
                    versoImage: formController.versoImage,
                    onPickImage: (isRecto) =>
                        formController.pickImage(isRecto, context),
                    screenWidth: screenWidth,
                    textScaleFactor: textScaleFactor,
                  ),
                  SizedBox(height: buttonSpacing),

                  _buildSaveButton(formController, screenWidth, screenHeight, textScaleFactor),
                  SizedBox(height: bottomSpacing),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileFormController formController, double screenWidth, double textScaleFactor) {
    return Consumer<AuthViewModel>(
      builder: (context, authProvider, child) {
    final padding = screenWidth < 360 ? 16.0 : screenWidth < 600 ? 20.0 : 24.0;
    final avatarSize = screenWidth < 360 ? 70.0 : screenWidth < 600 ? 80.0 : 90.0;
    final iconSize = screenWidth < 360 ? 35.0 : screenWidth < 600 ? 40.0 : 45.0;
    final titleFontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final subtitleFontSize = (14.0 / textScaleFactor).clamp(12.0, 16.0);
    final titleSpacing = screenWidth < 360 ? 12.0 : 16.0;
    final subtitleSpacing = screenWidth < 360 ? 3.0 : 4.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
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
          Consumer<AuthViewModel>(
            builder: (context, authProvider, child) {
              final currentUser = authProvider.currentUser;
              final hasAvatar = ProfileHelpers.isValidImage(currentUser?.avatarUrl);
              final avatarUrl = currentUser?.avatarUrl != null
                  ? ProfileHelpers.buildImageUrl(currentUser!.avatarUrl!, ApiConstants.baseUrl)
                  : null;
              
              final cacheBuster = authProvider.avatarTimestamp ?? 
                  currentUser?.updatedAt?.millisecondsSinceEpoch ?? 
                  DateTime.now().millisecondsSinceEpoch;
              
              final avatarUrlWithCacheBuster = avatarUrl != null 
                  ? '$avatarUrl?t=$cacheBuster&v=${DateTime.now().millisecondsSinceEpoch}'
                  : null;

              return Container(
                width: avatarSize,
                height: avatarSize,
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
                child: ClipOval(
                  child: hasAvatar && avatarUrlWithCacheBuster != null
                      ? Image.network(
                          avatarUrlWithCacheBuster,
                          key: ValueKey('edit_avatar_${currentUser?.id}_$cacheBuster'),
                          fit: BoxFit.cover,
                          cacheWidth: (avatarSize * 3).toInt(),
                          cacheHeight: (avatarSize * 3).toInt(),
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_rounded,
                              color: AppColors.white,
                              size: iconSize,
                            );
                          },
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: AppColors.white,
                          size: iconSize,
                        ),
                ),
              );
            },
          ),
          SizedBox(height: titleSpacing),
          Text(
            "Modifiez vos informations",
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: subtitleSpacing),
          Text(
            "Vous pouvez modifier un ou plusieurs champs",
            style: GoogleFonts.poppins(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      );
      },
    );
  }


  Widget _buildSaveButton(
    ProfileFormController formController,
    double screenWidth,
    double screenHeight,
    double textScaleFactor,
  ) {
    final bool isEnabled =
        formController.hasChanges && !formController.isLoading;
    
    final verticalPadding = screenHeight < 600 ? 16.0 : 18.0;
    final fontSize = (16.0 / textScaleFactor).clamp(14.0, 18.0);
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final iconSpacing = screenWidth < 360 ? 10.0 : 12.0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _saveProfile(formController) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.3),
          foregroundColor: isEnabled
              ? AppColors.white
              : AppColors.textSecondary,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        child: formController.isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: iconSpacing),
                  Flexible(
                    child: Text(
                      "Enregistrement...",
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Text(
                formController.hasChanges
                    ? "Enregistrer les modifications"
                    : "Aucune modification",
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  Future<void> _saveProfile(ProfileFormController formController) async {
    await formController.saveProfile(context);

    if (widget.onProfileCompleted != null) {
      widget.onProfileCompleted!();
    } else {
      final product = widget.produit;
      if (product != null && mounted) {
        final authProvider = context.read<AuthViewModel>();
        await authProvider.loadUserProfile();

        if (authProvider.currentUser?.isProfileComplete == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SimulationScreen(
                produit: product,
                assureEstSouscripteur: true,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Veuillez compléter tous les champs obligatoires pour simuler un devis',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.orange[800],
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          );
        }
      } else {
        if (mounted) Navigator.pop(context);
      }
    }
  }
}
