import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource src) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(
    source: src,
    maxWidth: 1080,
    imageQuality: 85,
  );

  if (file != null) {
    final Uint8List imageBytes = await file.readAsBytes();

    if (kDebugMode) {
      print('In-memory image size: ${imageBytes.lengthInBytes} bytes');
    }

    return imageBytes;
  }

  if (kDebugMode) {
    print('No Image selected');
  }
}

void showSnackBar(String content, BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.clearSnackBars();
  // messenger.hideCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(content: Text(content, style: GoogleFonts.poppins())),
  );
}
