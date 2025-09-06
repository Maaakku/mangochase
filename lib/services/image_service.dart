import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as devtools;

enum ImageSourceType { camera, gallery }

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({
    required ImageSourceType sourceType,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: sourceType == ImageSourceType.camera 
            ? ImageSource.camera 
            : ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) {
        devtools.log('No image selected');
        return null;
      }

      return File(image.path);
    } on PlatformException catch (e) {
      devtools.log('Platform exception: $e');
      throw ImagePickerException('Failed to pick image: ${e.message}');
    } catch (e) {
      devtools.log('Error picking image: $e');
      throw ImagePickerException('Unexpected error occurred while picking image');
    }
  }

  Future<List<File>?> pickMultipleImages({
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
    // int? limit,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        // limit: limit,
      );

      if (images.isEmpty) {
        devtools.log('No images selected');
        return null;
      }

      return images.map((image) => File(image.path)).toList();
    } on PlatformException catch (e) {
      devtools.log('Platform exception: $e');
      throw ImagePickerException('Failed to pick images: ${e.message}');
    } catch (e) {
      devtools.log('Error picking images: $e');
      throw ImagePickerException('Unexpected error occurred while picking images');
    }
  }

  Future<bool> isImageValid(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return false;
      }

      final int fileSize = await imageFile.length();
      // Check if file size is reasonable (not empty, not too large)
      return fileSize > 0 && fileSize < 50 * 1024 * 1024; // 50MB limit
    } catch (e) {
      devtools.log('Error validating image: $e');
      return false;
    }
  }

  String getImageSizeInfo(File imageFile) {
    try {
      final int bytes = imageFile.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }
}

class ImagePickerException implements Exception {
  final String message;
  ImagePickerException(this.message);

  @override
  String toString() => 'ImagePickerException: $message';
}