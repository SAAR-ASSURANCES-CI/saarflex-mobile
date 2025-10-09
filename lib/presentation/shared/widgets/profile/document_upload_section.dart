import 'dart:io';
import 'package:saarflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/core/utils/image_labels.dart';

class DocumentUploadSection extends StatelessWidget {
  final User? user;
  final XFile? rectoImage;
  final XFile? versoImage;
  final bool isUploadingRecto;
  final bool isUploadingVerso;
  final Function(bool isRecto) onImagePicked;
  final Function(bool isRecto) onImageDeleted;
  final String? identityType; // Nouveau paramètre pour la réactivité

  const DocumentUploadSection({
    super.key,
    required this.user,
    required this.rectoImage,
    required this.versoImage,
    required this.isUploadingRecto,
    required this.isUploadingVerso,
    required this.onImagePicked,
    required this.onImageDeleted,
    this.identityType, // Nouveau paramètre
  });

  @override
  Widget build(BuildContext context) {
    // Utiliser identityType en paramètre pour la réactivité, sinon fallback sur user?.identityType
    final currentIdentityType = identityType ?? user?.identityType;

    return _buildSection(
      title: ImageLabels.getUploadTitle(currentIdentityType),
      icon: Icons.photo_library_rounded,
      children: [
        _buildImageUploadField(
          label: ImageLabels.getRectoLabel(currentIdentityType),
          imageUrl: user?.frontDocumentPath,
          isUploading: isUploadingRecto,
          onTap: () => onImagePicked(true),
          selectedImage: rectoImage,
          onDelete: () => onImageDeleted(true),
        ),
        const SizedBox(height: 20),
        _buildImageUploadField(
          label: ImageLabels.getVersoLabel(currentIdentityType),
          imageUrl: user?.backDocumentPath,
          isUploading: isUploadingVerso,
          onTap: () => onImagePicked(false),
          selectedImage: versoImage,
          onDelete: () => onImageDeleted(false),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
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
      ),
    );
  }

  Widget _buildImageUploadField({
    required String label,
    String? imageUrl,
    required bool isUploading,
    required VoidCallback onTap,
    XFile? selectedImage,
    required VoidCallback onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: _buildImageContent(
            imageUrl: imageUrl,
            isUploading: isUploading,
            onTap: onTap,
            selectedImage: selectedImage,
            onDelete: onDelete,
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent({
    String? imageUrl,
    required bool isUploading,
    required VoidCallback onTap,
    XFile? selectedImage,
    required VoidCallback onDelete,
  }) {
    if (isUploading) {
      return _buildUploadingState();
    }

    if (selectedImage != null) {
      return _buildSelectedImageState(selectedImage, onDelete);
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return _buildExistingImageState(imageUrl, onDelete);
    }

    return _buildEmptyState(onTap);
  }

  Widget _buildUploadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Upload en cours...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImageState(XFile selectedImage, VoidCallback onDelete) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(selectedImage.path),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onDelete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImageState(String imageUrl, VoidCallback onDelete) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildEmptyState(() {});
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onDelete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Appuyez pour ajouter une photo',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
