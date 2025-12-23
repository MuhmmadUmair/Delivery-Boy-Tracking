import 'dart:developer';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image to 80% quality
        maxWidth: 1000, // Resize to a max width of 800px
        maxHeight: 1000, // Resize to a max height of 800px
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      // Optionally, handle or log errors here
      log(e.toString());
      return null;
    }
  }
}
