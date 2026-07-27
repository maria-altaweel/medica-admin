import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerHelper {
  static final ImagePicker picker = ImagePicker();
  static Future<File?> picImageFromGallery() async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        return File(pickedFile.path); //بترجع الصورة ك File
      }
    } catch (e) {
      print("Error picking image:$e");
    }
    return null;
  }

  // الدالة الجديدة للملفات (PDF)
  static Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      print("Error picking document: $e");
    }
    return null;
  }
}
