import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressService {
  static Future<File?> compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
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
      return file;
    }
  }
}
