class UploadImagesResponse {
  final String rectoPath;
  final String versoPath;

  UploadImagesResponse({required this.rectoPath, required this.versoPath});

  factory UploadImagesResponse.fromJson(Map<String, dynamic> json) {
    return UploadImagesResponse(
      rectoPath: json['recto_path'] ?? '',
      versoPath: json['verso_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'recto_path': rectoPath, 'verso_path': versoPath};
  }

  bool get hasValidPaths => rectoPath.isNotEmpty && versoPath.isNotEmpty;
}
