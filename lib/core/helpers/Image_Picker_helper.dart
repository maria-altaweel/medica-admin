import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class PickedFileData {
  final String name;
  final Uint8List bytes;
  final String? path; // سيكون متوفراً في الهاتف فقط

  PickedFileData({required this.name, required this.bytes, this.path});
}

class ImagePickerHelper {
  static final ImagePicker picker = ImagePicker();

  // دالة اختيار الصورة المتوافقة مع Web و Mobile
  
  static Future<PickedFileData?> picImageFromGallery() async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        return PickedFileData(
          name: pickedFile.name,
          bytes: bytes,
          path: kIsWeb ? null : pickedFile.path,
        );
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }

  // دالة اختيار المستندات المتوافقة مع Web و Mobile
  static Future<PickedFileData?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // مهم جداً للويب لقرءاة الـ Bytes
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        return PickedFileData(
          name: file.name,
          bytes: file.bytes!,
          path: kIsWeb ? null : file.path,
        );
      }
    } catch (e) {
      print("Error picking document: $e");
    }
    return null;
  }
}
