import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/constants/colors.dart';
import 'package:saarflex_app/models/product_model.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import 'package:saarflex_app/screens/simulation/simulation_screen.dart';
import 'package:saarflex_app/utils/error_handler.dart';
import 'package:saarflex_app/profile/controllers/profile_form_controller.dart';
import 'package:saarflex_app/profile/widgets/personal_section.dart';
import 'package:saarflex_app/profile/widgets/contact_section.dart';
import 'package:saarflex_app/profile/widgets/identity_section.dart';
import 'package:saarflex_app/profile/widgets/identity_images_section.dart';

class EditProfileScreenRefactored extends StatefulWidget {
  final VoidCallback? onProfileCompleted;
  final Product? produit;

  const EditProfileScreenRefactored({
    super.key,
    this.onProfileCompleted,
    this.produit,
  });

  @override
  State<EditProfileScreenRefactored> createState() => _EditProfileScreenRefactoredState();
}

class _EditProfileScreenRefactoredState extends State<EditProfileScreenRefactored> {
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
        body: Consumer<ProfileFormController>(
          builder: (context, formController, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 40),

                  if (formController.fieldErrors.isNotEmpty) ...[
                    ErrorHandler.buildErrorList(
                      formController.fieldErrors.values
                          .where((error) => error != null)
                          .cast<String>()
                          .toList(),
                    ),
                    const SizedBox(height: 20),
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
                  ),
                  const SizedBox(height: 32),

                  ContactSection(
                    emailController: formController.emailController,
                    phoneController: formController.phoneController,
                    addressController: formController.addressController,
                    fieldErrors: formController.fieldErrors,
                    originalData: formController.originalData,
                  ),
                  const SizedBox(height: 32),

                  IdentitySection(
                    idNumberController: formController.idNumberController,
                    selectedIdType: formController.selectedIdType,
                    selectedExpirationDate: formController.selectedExpirationDate,
                    idTypeOptions: formController.idTypeOptions,
                    fieldErrors: formController.fieldErrors,
                    originalData: formController.originalData,
                    onIdTypeChanged: formController.updateIdType,
                    onExpirationDateChanged: formController.updateExpirationDate,
                    onDropdownChanged: () => formController.checkForChanges(),
                    onDateChanged: () => formController.checkForChanges(),
                  ),
                  const SizedBox(height: 32),

                  IdentityImagesSection(
                    currentIdentityType: formController.getBackendIdentityType(formController.selectedIdType),
                    frontDocumentPath: context.read<AuthProvider>().currentUser?.frontDocumentPath,
                    backDocumentPath: context.read<AuthProvider>().currentUser?.backDocumentPath,
                    isUploadingRecto: formController.isUploadingRecto,
                    isUploadingVerso: formController.isUploadingVerso,
                    rectoImage: formController.rectoImage,
                    versoImage: formController.versoImage,
                    onPickImage: (isRecto) => formController.pickImage(isRecto, context),
                  ),
                  const SizedBox(height: 40),

                  _buildSaveButton(formController),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
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

  Widget _buildSaveButton(ProfileFormController formController) {
    final bool isEnabled = formController.hasChanges && !formController.isLoading;

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
          padding: const EdgeInsets.symmetric(vertical: 18),
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
                formController.hasChanges
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

  Future<void> _saveProfile(ProfileFormController formController) async {
    await formController.saveProfile(context);

    if (widget.onProfileCompleted != null) {
      widget.onProfileCompleted!();
    } else {
      final product = widget.produit;
      if (product != null && mounted) {
        final authProvider = context.read<AuthProvider>();
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