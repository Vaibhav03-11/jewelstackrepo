import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static const double maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];

  static Future<void> validateImage(XFile imageFile) async {
    // Check file size
    final file = File(imageFile.path);
    final fileSize = await file.length();
    if (fileSize > maxFileSize) {
      throw 'Image size must be less than 5MB';
    }

    // Check file format
    final extension = imageFile.path.split('.').last.toLowerCase();
    if (!allowedFormats.contains(extension)) {
      throw 'Only JPG, JPEG, PNG, and WebP formats are allowed';
    }
  }

  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}