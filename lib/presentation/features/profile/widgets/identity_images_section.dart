import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/utils/image_labels.dart';
import 'package:saarciflex_app/presentation/features/profile/widgets/image_upload_field.dart';

class IdentityImagesSection extends StatelessWidget {
  final String? currentIdentityType;
  final String? frontDocumentPath;
  final String? backDocumentPath;
  final bool isUploadingRecto;
  final bool isUploadingVerso;
  final XFile? rectoImage;
  final XFile? versoImage;
  final Function(bool, ImageSource) onPickImage;
  final double screenWidth;
  final double textScaleFactor;

  const IdentityImagesSection({
    super.key,
    required this.currentIdentityType,
    required this.frontDocumentPath,
    required this.backDocumentPath,
    required this.isUploadingRecto,
    required this.isUploadingVerso,
    required this.rectoImage,
    required this.versoImage,
    required this.onPickImage,
    required this.screenWidth,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final fieldSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return _buildFormSection(
      title: ImageLabels.getUploadTitle(currentIdentityType),
      icon: Icons.photo_library_rounded,
      screenWidth: screenWidth,
      textScaleFactor: textScaleFactor,
      children: [
        ImageUploadField(
          label: ImageLabels.getRectoLabel(currentIdentityType),
          imageUrl: frontDocumentPath,
          isUploading: isUploadingRecto,
          onTap: () => _showImageSourceDialog(context, true),
          selectedImage: rectoImage,
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        _buildFileSizeInfo(screenWidth, textScaleFactor),
        SizedBox(height: fieldSpacing),
        ImageUploadField(
          label: ImageLabels.getVersoLabel(currentIdentityType),
          imageUrl: backDocumentPath,
          isUploading: isUploadingVerso,
          onTap: () => _showImageSourceDialog(context, false),
          selectedImage: versoImage,
          screenWidth: screenWidth,
          textScaleFactor: textScaleFactor,
        ),
        _buildFileSizeInfo(screenWidth, textScaleFactor),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context, bool isRecto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  onPickImage(isRecto, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  onPickImage(isRecto, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileSizeInfo(double screenWidth, double textScaleFactor) {
    final infoFontSize = (11.0 / textScaleFactor).clamp(10.0, 12.0);
    final iconSize = screenWidth < 360 ? 14.0 : 16.0;
    final iconSpacing = screenWidth < 360 ? 4.0 : 6.0;
    final topSpacing = screenWidth < 360 ? 4.0 : 6.0;
    final alertColor = Colors.orange[700] ?? const Color.fromARGB(255, 235, 107, 27);
    
    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: iconSize,
            color: alertColor,
          ),
          SizedBox(width: iconSpacing),
          Text(
            'Taille maximale : 5 Mo',
            style: FontHelper.poppins(
              fontSize: infoFontSize,
              color: alertColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required double screenWidth,
    required double textScaleFactor,
  }) {
    final iconSize = screenWidth < 360 ? 18.0 : 20.0;
    final iconPadding = screenWidth < 360 ? 6.0 : 8.0;
    final iconSpacing = screenWidth < 360 ? 10.0 : 12.0;
    final titleFontSize = (18.0 / textScaleFactor).clamp(16.0, 20.0);
    final sectionSpacing = screenWidth < 360 ? 16.0 : 20.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: iconSize),
            ),
            SizedBox(width: iconSpacing),
            Expanded(
              child: Text(
                title,
                style: FontHelper.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: sectionSpacing),
        ...children,
      ],
    );
  }
}
