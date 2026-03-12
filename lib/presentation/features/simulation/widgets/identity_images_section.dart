import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:saarciflex_app/core/utils/image_labels.dart';
import 'package:saarciflex_app/presentation/features/simulation/widgets/image_upload_field.dart';

class IdentityImagesSection extends StatelessWidget {
  final String? identityType;
  final bool isUploadingRecto;
  final bool isUploadingVerso;
  final VoidCallback onPickRecto;
  final VoidCallback onPickVerso;
  final XFile? rectoImage;
  final XFile? versoImage;
  final String? uploadedRectoUrl;
  final String? uploadedVersoUrl;
  bool get _isPasseport =>
      identityType?.toLowerCase().contains('passeport') ?? false;

  const IdentityImagesSection({
    super.key,
    required this.identityType,
    required this.isUploadingRecto,
    required this.isUploadingVerso,
    required this.onPickRecto,
    required this.onPickVerso,
    required this.rectoImage,
    required this.versoImage,
    this.uploadedRectoUrl,
    this.uploadedVersoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final title = ImageLabels.getUploadTitle(identityType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: FontHelper.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: title),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ImageUploadField(
          label: ImageLabels.getRectoLabel(identityType),
          isUploading: isUploadingRecto,
          onTap: onPickRecto,
          selectedImage: rectoImage,
          uploadedImageUrl: uploadedRectoUrl,
        ),
        _buildFileSizeInfo(),
        if (!_isPasseport) ...[
          const SizedBox(height: 20),
          ImageUploadField(
            label: ImageLabels.getVersoLabel(identityType),
            isUploading: isUploadingVerso,
            onTap: onPickVerso,
            selectedImage: versoImage,
            uploadedImageUrl: uploadedVersoUrl,
          ),
          _buildFileSizeInfo(),
        ],
      ],
    );
  }

  Widget _buildFileSizeInfo() {
    final alertColor = Colors.orange[700] ?? const Color.fromARGB(255, 235, 107, 27);
    
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: alertColor,
          ),
          const SizedBox(width: 6),
          Text(
            'Taille maximale : 5 Mo',
            style: FontHelper.poppins(
              fontSize: 11,
              color: alertColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
