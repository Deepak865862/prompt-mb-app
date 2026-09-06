import 'dart:io';
import 'package:image_compressor/image_compressor.dart';

class ImageCompressService {
  // Image ka size kam karne ka function
  static Future<File?> compressImage(File file) async {
    try {
      // Image ko 80% quality par compress karna
      final result = await ImageCompressor.compressAndGetFile(
        file.absolute.path,
        file.parent.path + '/compressed_${file.path.split('/').last}',
        quality: 80,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('Image compression error: $e');
      return file; // Agar compress na ho, toh original file wapas bhej do
    }
  }
}
